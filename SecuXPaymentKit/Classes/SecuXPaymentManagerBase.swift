//
//  PaymentHandler.swift
//  SecuXPaymentKit
//
//  Created by Maochun Sun on 2020/1/16.
//  Copyright © 2020 SecuX. All rights reserved.
//

import Foundation
import SPManager

import CoreNFC


open class SecuXPaymentManagerBase{
    
    let secXSvrReqHandler = SecuXServerRequestHandler()
    let paymentPeripheralManager = PaymentPeripheralManager.init()
    
    open var delegate: SecuXPaymentManagerDelegate?

    
    
    private func sendInfoToDevice(account: SecuXAccount, storeName: String, paymentInfo: PaymentInfo){
        
        logw("AccountPaymentViewModel sendInfoToDevice")
        
        
        var fromAcc = account.name
        if account.type == .LBR{
            fromAcc = account.theAddress
        }
        
        let param : [String:String] = ["coinType"   : account.type.rawValue,
                                       "from"       : fromAcc,
                                        "txId"      : "P123456789123456",
                                        "to"        : paymentInfo.deviceID,
                                        "amount"    : paymentInfo.amount,
                                        "ivKey"     : paymentInfo.ivKey,
                                        "memo"      : storeName,
                                        "currency"  : account.type.rawValue]
        
        
        print(param)
        

        let (ret, data) = self.secXSvrReqHandler.doPayment(param: param)
        if ret, let payInfo = data {
            //var str = String(decoding: payInfo, as: UTF8.self)
            
            do{
                let json  = try JSONSerialization.jsonObject(with: payInfo, options: []) as! [String : Any]
                print("sendInfoToDevice recv \(json)  \n--------")
                
                //var payRet = true
                //var errorMsg = ""
                if let machineControlParams = json["machineControlParam"] as? [String : Any],
                    let encryptedStr = json["encryptedTransaction"] as? String {
                    
                    let encrypted = Data(base64Encoded: encryptedStr)
                    
                    /*
                    let machineControlParams2 : [String : String] = ["uart":"0","gpio1":"0","gpio2":"0","gpio31":"0","gpio32":"0","gpio4":"0","runStatus":"0","lockStatus":"0","gpio4c":"0","gpio4cInterval":"0","gpio4cCount":"0","gpio4dOn":"0","gpio4dOff":"0","gpio4dInterval":"0"]
                    let encrypted2 = self.genEncryptCode(devID: devID, ivKey: ivKey)
                    
                    */
                    logw("AccountPaymentViewModel doPaymentVerification")
                   
                    self.handlePaymentStatus(status: "Device verifying ...")
                    
                    
                    
                    self.paymentPeripheralManager.doPaymentVerification(encrypted, machineControlParams: machineControlParams){ (result, error) in
                     
                        logw("AccountPaymentViewModel doPaymentVerification done")
                        if (error != nil) {
                         
                            var msgStr:String = "\(String(describing: error))"
                            if let responseCode = result?["responseCode"] as? NSData {
                                msgStr += " ,responeCode:\(responseCode)"
                            }
                            
                            self.handlePaymentDone(ret: false, errorMsg: msgStr)
                            
                            
                            return

                        }else{
                            print("payment verification done!")
                            
                            self.handlePaymentDone(ret: true, errorMsg: "")
                            
                            
                            return
                        }
                        
                    }

                    
                }else{
                    
                    logw("sendInfoToDevice failed \(param)")
                    
                    if let code = json["statusCode"] as? Int{
                        logw("sendInfoToDevice failed \(code)")
                    }
                    
                    if let error = json["statusDesc"] as? String{
                        logw("sendInfoToDevice failed \(error)")
                    }
                    
                    self.handlePaymentDone(ret: false, errorMsg: "Get payment data from server failed.")
                    
                }
                
            
                
            }catch{
                print("doPayment error: " + error.localizedDescription)
                self.handlePaymentDone(ret: false, errorMsg: error.localizedDescription)
                
                return
            }
            
           
        }else{
            print("doPayment failed!!")
            self.handlePaymentDone(ret: false, errorMsg: "Send request to server failed.")
            
            
        }
        
        

    }
    
    private func handleDeviceAuthenicationResult(account: SecuXAccount, storeName: String, paymentInfo: PaymentInfo, ivKey: String?, error: Error?){
        if error != nil || ivKey == nil || ivKey?.count == 0 { // there is an error from SDK
            print("error: \(String(describing: error))")
            
            if let theError = error{
                let code = (theError as NSError).code
                if code == 25 || ivKey == nil || ivKey?.count == 0{
                     self.handlePaymentDone(ret: false, errorMsg: "No payment device")
                     return
                 }
                 //self.showMessage(title: "Error", message: msg)
                
                self.handlePaymentDone(ret: false, errorMsg: theError.localizedDescription)
            }else{
                self.handlePaymentDone(ret: false, errorMsg: "Device authentiation failed")
            }
            
           
        }else{  // get ivKey for data encryption
            self.paymentPeripheralManager.doGetIvKey { result, error in
                
               logw("AccountPaymentViewModel doGetIvKey done")
               
               
                if ((error) != nil) {
                   logw("error: \(String(describing: error))")
                   self.handlePaymentDone(ret: false, errorMsg: String(describing: error))
                   
                }else if let ivKey = result, ivKey.count > 0{
                    logw("ivKey: \(String(describing: ivKey))")
                    
                    self.handlePaymentStatus(status: "\(account.type.rawValue) transferring...")
                    
                   //DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                       
                    DispatchQueue.global(qos: .default).async{
                    
                        var paymentInfoWithIVkey = paymentInfo
                        paymentInfoWithIVkey.ivKey = ivKey
                        self.sendInfoToDevice(account: account, storeName: storeName, paymentInfo: paymentInfoWithIVkey)
                   
                   }
                   

                }else{
                   self.handlePaymentDone(ret: false, errorMsg: "No ivkey")
               }
            }
        }
    }
    
    internal func doPayment(account: SecuXAccount, storeName: String, paymentInfo: PaymentInfo) {
        
        //logw("AccountPaymentViewModel doPayment \(account.name) \(devID) \(amount)")
        
        let scanInterval = 3.0  //Put your scan interval value as you wish, here is  3.0 seconds.
        let rssiValueToCheck = -90 //Put your rssi value for range scan, here is -90 (far distanc
        
        self.handlePaymentStatus(status: "Device connecting...")
        
        
        paymentPeripheralManager.discoverNearbyPeripherals(scanInterval,
            checkRSSI: Int32(rssiValueToCheck)) { result, error in
                     
            logw("result was \(String(describing: result)), and error was \(String(describing: error))")
                                                        
                     
            if let error = error{
                self.handlePaymentDone(ret: false, errorMsg: error.localizedDescription)
                return
            }
                
            if result?.count == 0{
                self.handlePaymentDone(ret: false, errorMsg: "No payment device")
                return
            }
    
        
            self.paymentPeripheralManager.doPeripheralAuthenticityVerification(3, connectDeviceId: paymentInfo.deviceID, checkRSSI: (Int32(-80)), connectionTimeout: 5) { result, error in
        
                
                logw("AccountPaymentViewModel doPeripheralAuthenticityVerification done \(result ?? "")")
                self.handleDeviceAuthenicationResult(account: account, storeName:storeName, paymentInfo: paymentInfo, ivKey: result, error: error)
                
            }
        }
    }
    
    internal func getStoreInfo(coinType: String, devID: String) -> (Bool, String, String){
        
        logw("getAccountInfo \(coinType) \(devID)")
        
        /*
         {
            "coinType" : "IFC",
            "type" : "Device",
         "id":"4ab10000726b"
         }
         */
        
        let param = ["coinType": coinType, "id" : devID, "type" : "Device",]
        let (ret, data) = self.secXSvrReqHandler.getAccountInfo(param: param)
        if ret, let accInfo = data{
            
            do{
                
                let json  = try JSONSerialization.jsonObject(with: accInfo, options: []) as! [String : Any]
                //print(json)
                
                /*
                 {
                     "coinType": "IFC",
                     "type": "Device",
                     "id": "4ab10000726b",
                     "name": "Secux-Maochu",
                     "icon": ""
                 }
                 */
                
                if let name = json["name"] as? String, let img = json["icon"] as? String{
                    return (true, name, img)
                }else{
                    logw("getAccountInfo no name/img  \(json)")
                }
                
            }catch{
                logw("getAccountInfo error: " + error.localizedDescription)
            }
            
        }
        
        return (false, "", "")
    }
    
    internal func getPaymentInfo(paymentJson: String) -> (Bool, PaymentInfo){
        
        var ret = false
        var payInfo = PaymentInfo(coinType: "", amount: "", deviceID: "", ivKey: "")
        
        if let data = paymentJson.data(using: String.Encoding.utf8){
    
            do{
                //let decoder = JSONDecoder()
                //let payInfo = try decoder.decode(PaymentInfo.self, from: data)
                
                let json  = try JSONSerialization.jsonObject(with: data, options: []) as! [String : String]
                print(json)
                
                
                if let devID = json["deviceID"], let amount = json["amount"], let type = json["coinType"]{
                    payInfo.amount = amount
                    payInfo.deviceID = devID
                    payInfo.coinType = type
                    payInfo.ivKey = ""
                    
                    if let _ = CoinType(rawValue: type){
                        ret = true
                    }else{
                        logw("Invalid coin type")
                    }
                
                }
                
            }catch{
                logw("Serialize payment json data exception")
            }
        }
        
        return (ret, payInfo)
    }
    
    @available(iOS 11.0, *)
    internal func getPaymentInfo(nfcData: [NFCNDEFPayload]) -> (Bool, PaymentInfo){
        var ret = false
        var payInfo = PaymentInfo(coinType: "", amount: "", deviceID: "", ivKey: "")
        
        var findAmount=false, findDevID=false, findCoinType = false
        for record in nfcData {
            if let strData = String(data: record.payload, encoding: .ascii) {
                //logw(strData)

                
                if strData.contains("amount:"),
                    let sepIdx = strData.firstIndex(of: ":"){
                    
                    let startIdx = strData.index(after: sepIdx)
                    payInfo.amount = String(strData[startIdx...])

                    findAmount = true
                    logw("amount = \(payInfo.amount)")

                }else if strData.contains("DevID:"),
                    let sepIdx = strData.firstIndex(of: ":"){
                    
                    let startIdx = strData.index(after: sepIdx)
                    payInfo.deviceID = String(strData[startIdx...])
                    
                    findDevID = true
                    logw("devID = \(payInfo.deviceID)")
                    
                }else if strData.contains("CoinType:"),
                    let sepIdx = strData.firstIndex(of: ":"){
                    
                    let startIdx = strData.index(after: sepIdx)
                    payInfo.coinType = String(strData[startIdx...])
                    
                    findCoinType = true
                    logw("coinType = \(payInfo.coinType)")
                    
                }
                
            
            }

        }
        
        if findDevID, findAmount, findCoinType{
            
            if let _ = CoinType(rawValue: payInfo.coinType){
                ret = true
            }else{
                logw("Invalid coin type")
            }
        }
        
        return (ret, payInfo)
    }
    
    internal func handlePaymentDone(ret: Bool, errorMsg: String){
        DispatchQueue.main.async {
            self.delegate?.paymentDone(ret: ret, errorMsg: errorMsg)
        }
    }
    
    internal func handlePaymentStatus(status: String){
        DispatchQueue.main.async {
            self.delegate?.updatePaymentStatus(status: status)
        }
    }
    
    internal func handleStoreInfo(ret: Bool, storeName: String, storeLogo: UIImage){
        DispatchQueue.main.async {
            self.delegate?.getStoreInfoDone(ret: ret, storeName: storeName, storeLogo: storeLogo)
        }
    }

}
