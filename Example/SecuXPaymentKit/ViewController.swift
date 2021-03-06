//
//  ViewController.swift
//  SecuXPaymentKit
//
//  Created by maochuns on 01/22/2020.
//  Copyright (c) 2020 maochuns. All rights reserved.
//

import UIKit

// Import SecuXPasymentKit module
import SecuXPaymentKit

class ViewController: UIViewController {
    
    var decentAccount: SecuXAccount?
    var accountMgr: SecuXAccountManager?
    var coinToUSDRateDict: [CoinType:Double] = [:]
    
    var paymentMgr: SecuXPaymentManager?
    var paymentInfo = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //New SecsuXAccount
        self.decentAccount = SecuXAccount(name: "ifun-886-936105934-6", type: .IFC, path: "", address: "", key: "")
        
        //Use SecuXAccountManager to get account balance and history
        self.accountMgr = SecuXAccountManager()
        self.getAccountBalance(account: self.decentAccount!)
        self.getAccountHistory(account: self.decentAccount!)

        
        //User SecuXPaymentManager to get store info. and do payment
        self.paymentMgr = SecuXPaymentManager()
        
        //Must set the delegate of the SecuXPaymentManager
        self.paymentMgr!.delegate = self
         
        //Payment information JSON: {"amount":"10", "coinType":"IFC", "deviceID":"4ab10000726b"}
        self.paymentInfo = "{\"amount\":\"100\", \"coinType\":\"DCT\", \"deviceID\":\"4ab10000726b\"}"
        self.paymentMgr!.getStoreInfo(paymentInfo: self.paymentInfo)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAccountBalance(account: SecuXAccount){
        DispatchQueue.global(qos: .default).async{
            
            self.coinToUSDRateDict = self.accountMgr!.getCoinUSDRate()
            
            let (ret, balance) = self.accountMgr!.getAccountBalance(account: account)
            if ret, let balance = balance{
                
                var usdBalance = balance.balance_usd
                if usdBalance == 0, balance.formattedBalance > 0, let rate = self.coinToUSDRateDict[account.type]{
                    usdBalance = balance.formattedBalance * rate
                }
                
                print("Get account balance succssfully! \(balance.balance) USD Balance = \(usdBalance) Balance = \(balance.formattedBalance)")

                
            }else{
                print("Get account balance failed!")
                
                
            }
            
        }
    }
    
    func getAccountHistory(account: SecuXAccount){
        DispatchQueue.global(qos: .default).async {
            
            let (ret, historyArr) = self.accountMgr!.getAccountHistory(account: account)
            if ret{
                print("Get account history successfully!")
                
                for item in historyArr{
                    print("\(item.timestamp) \(item.tx_type) \(item.formatted_amount) \(item.amount_symbol ?? "") \(item.amount_usd) \(item.detailsUrl)")
                }
                
            }else{
                print("Get account history failed!")
               
            }
            
        }
    }


}

//MARK: SecuXPaymentManagerDelegate implementation
extension ViewController: SecuXPaymentManagerDelegate{
    
    //Called when payment is completed. Returns payment result and error message.
    func paymentDone(ret: Bool, errorMsg: String) {
        print("paymentDone \(ret) \(errorMsg)")
        
        if ret{
            showMessage(title: "Payment success!", message: "")
        }else{
            showMessage(title: "Payment fail!", message:errorMsg)
        }
    }
    
    //Called when payment status is changed. Payment status are: "Device connecting...", "DCT transferring..." and "Device verifying..."
    func updatePaymentStatus(status: String) {
        print("updatePaymentStatus \(status)")
    }
    
    
    //Called when get store information is completed. Returns store name and store logo.
    func getStoreInfoDone(ret: Bool, storeName: String, storeLogo: UIImage) {
        print("getStoreInfoDone")
        
        if ret{
            paymentMgr!.doPayment(account: decentAccount!, storeName: storeName, paymentInfo: self.paymentInfo)
        }else{
            print("Get store info. faied!")
        }
    }
    
    
}
