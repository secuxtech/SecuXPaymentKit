//
//  RestServerHandler.swift
//  shippingassistant
//
//  Created by Maochun Sun on 2019/7/14.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import Foundation




class RestRequestHandler {
    
   
    func postRequestSync(urlstr: String, param: Any?) -> (Bool, Data?){
        guard let url = URL(string: urlstr) else
        {
            print("postRequestSync invalid url")
            return (false, nil)
        }
        var request : URLRequest = URLRequest(url: url)
        
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 2000
      
        if let param = param{
            guard let httpBody = try? JSONSerialization.data(withJSONObject: param, options: []) else{
                print("postRequestSync invalid httpBody")
                return (false, nil)
            }
            
            request.httpBody = httpBody
        }

        return processURLRequestSync(request: request)
    }
  
    
    func postRequestSync(urlstr: String, param: Any, cookie:String="") -> (Bool, Data?){
        guard let url = URL(string: urlstr) else
        {
            print("postRequestSync invalid url")
            return (false, nil)
        }
        var request : URLRequest = URLRequest(url: url)
        
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 2000
        
        if cookie.count > 0 {
            request.addValue(cookie, forHTTPHeaderField: "Cookie")
        }
        
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: param, options: []) else{
            print("postRequestSync invalid httpBody")
            return (false, nil)
        }
        
        
        request.httpBody = httpBody
        
        
        return processURLRequestSync(request: request)
    }
    
    
   
    
    func processURLRequestSync(request: URLRequest) -> (Bool, Data?){
        
        var dataRet: Data?
        var taskRet = false
        
        let taskDG = DispatchGroup()
        taskDG.enter()
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            
            if let response = response as? HTTPURLResponse{
                if response.statusCode == 200{
                    //print(response)
                    

                    dataRet = data
                    taskRet = true
                    
                }else{
                    logw("url request response \(request) \(response.statusCode)")
                    if let bodyData = request.httpBody,

                        let dataStr = String(data: bodyData, encoding: String.Encoding.utf8){
                        logw("\(dataStr)")
                    }
                    
                }

            }
  
            taskDG.leave()
            return
        }
        
        
        task.resume()
        taskDG.wait()
        
        return (taskRet, dataRet)
    }
    
    
}
