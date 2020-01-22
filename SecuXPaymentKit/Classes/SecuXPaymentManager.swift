//
//  SecuXPaymentManager.swift
//  SecuXPaymentKit
//
//  Created by Maochun Sun on 2020/1/16.
//  Copyright © 2020 SecuX. All rights reserved.
//

import Foundation
import CoreNFC
import SPManager

struct PaymentInfo {
    var coinType: String
    var amount: String
    var deviceID: String
    var ivKey: String
}

public protocol SecuXPaymentManagerDelegate{
    func paymentDone(ret: Bool, errorMsg: String)
    func updatePaymentStatus(status: String)
    func getStoreInfoDone(ret: Bool, storeName: String, storeLogo: UIImage)
}

open class SecuXPaymentManager: SecuXPaymentManagerBase {
    
    public override init() {
        super.init()
    
    }

    open func doPayment(account:SecuXAccount, storeName: String, paymentInfo: String){
        let (ret, pinfo) = self.getPaymentInfo(paymentJson: paymentInfo)
        if !ret{
            self.handlePaymentDone(ret: false, errorMsg: "Invalid payment information!")
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            self.doPayment(account: account, storeName: storeName, paymentInfo: pinfo)
        }
    }
    
    @available(iOS 11.0, *)
    open func doPayment(account: SecuXAccount, storeName: String, nfcData: [NFCNDEFPayload]){
        let (ret, pinfo) = self.getPaymentInfo(nfcData: nfcData)
        if !ret{
            self.handlePaymentDone(ret: false, errorMsg: "Invalid payment information!")
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            self.doPayment(account: account, storeName: storeName, paymentInfo: pinfo)
        }
    }
    
    
    open func getStoreInfo(paymentInfo:String){
        let (ret, pinfo) = self.getPaymentInfo(paymentJson: paymentInfo)
        if !ret{
            self.handleStoreInfo(ret: false, storeName: "", storeLogo: UIImage())
            return
            
        }
        
        DispatchQueue.global(qos: .default).async {
            self.getStoreInfo(paymentInfo: pinfo)
        }
    }
    
    @available(iOS 11.0, *)
    open func getStoreInfo(nfcData: [NFCNDEFPayload]){
        let (ret, pinfo) = self.getPaymentInfo(nfcData: nfcData)
        if !ret{
            self.handleStoreInfo(ret: false, storeName: "", storeLogo: UIImage())
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            self.getStoreInfo(paymentInfo: pinfo)
        }
    }
    
    private func getStoreInfo(paymentInfo: PaymentInfo){
        
        let (ret, name, imgStr) = self.getStoreInfo(coinType: paymentInfo.coinType, devID: paymentInfo.deviceID)
        if !ret{
            self.handleStoreInfo(ret: false, storeName: "", storeLogo: UIImage())
            return
        }
        
        var storeLogoImg = UIImage()
        if let url = URL(string: imgStr),let data = try? Data(contentsOf: url),let image = UIImage(data: data) {
            storeLogoImg = image
        }
        
        self.handleStoreInfo(ret: true, storeName: name, storeLogo: storeLogoImg)
        
    }
    
    
    
    
}
