//
//  HttpServer.swift
//  GoldenPassport
//
//  Created by StanZhai on 2017/3/4.
//  Copyright © 2017年 StanZhai. All rights reserved.
//

import Foundation
import Swifter


var globalConstant: String = ""


public func httpServer() -> HttpServer {
    
    
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d \"addr:\""]
    let pipe = Pipe()
    task.standardOutput = pipe

    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        print(output)
        globalConstant = output
    }

    
    
    let server = HttpServer()
//    server.listenAddressIPv4 = "127.0.0.1"
    server.listenAddressIPv4 = globalConstant
    
    server["/"] = scopes {
        html {
            body {
                h3 { inner = "Verification code list:" }
                
                ul(DataManager.shared.allAuthCode()) { code in
                    li {
                        a { href = "/code/\(code.key)"; inner = "\(code.key) -> \(code.value)" }
                    }
                }
            }
        }
    }
    
    server["/code/:key"] = { r in
        let key = r.params[":key"]
        let allCodes = DataManager.shared.allAuthCode()
        for authInfo in allCodes {
            if authInfo.key == key! {
                return HttpResponse.ok(.text(authInfo.value))
            }
        }
        return HttpResponse.ok(.text("key does not exists!"))
    }
    
    return server
}
