//
//  SecuXServerRequestHandler.swift
//  SecuXWallet
//
//  Created by Maochun Sun on 2019/12/2.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import Foundation


class SecuXServerRequestHandler: RestRequestHandler {
    
    let balanceSvrUrl = "https://pmsweb.secuxtech.com/Account/GetAccountBalance"
    let addrBalanceSvrUrl = "https://pmsweb.secuxtech.com/Account/GetAccountBalanceByAddr"
    
    let historySvrUrl = "https://pmsweb.secuxtech.com/Transaction/GetTxHistory"
    let addrHistorySvrUrl = "https://pmsweb.secuxtech.com/Transaction/GetTxHistoryByAddr"
    
    let currencySvrUrl = "https://pmsweb.secuxtech.com/Common/GetCryptocurrencySetting"
    
    let networkFeeSvrUrl = "https://pmsweb.secuxtech.com/Common/GetNetworkFee"
    
    let paymentSvrUrl = "https://pmsweb.secuxtech.com/Transaction/Payment"
    
    let swTransDataSvrUrl = "https://pmsweb.secuxtech.com/Transaction/GetSWTransactionData"
    let hwTransDataSvrUrl = "https://pmsweb.secuxtech.com/Transaction/GetHWTransactionData"
    let broadcastTransSvrUrl = "https://pmsweb.secuxtech.com/Transaction/Transfer"
    
    let getAccountInfoSvrUrl = "https://pmsweb.secuxtech.com/Account/GetAccountInfo"
    
    
    func getCoinCurrency() -> (Bool, Data?){
        return self.postRequestSync(urlstr: currencySvrUrl, param: nil)
    }
    
    func getAccountBalanceByAddr(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: addrBalanceSvrUrl, param: param)
    }
    
    func getAccountBalance(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: balanceSvrUrl, param: param)
    }
    
    func getAccountHistoryByAddr(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: addrHistorySvrUrl, param: param)
    }
    
    func getAccountHistory(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: historySvrUrl, param: param)
    }
    
    func doPayment(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: paymentSvrUrl, param: param)
    }
    
    func getSWTransactionData(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: swTransDataSvrUrl, param: param)
    }
    
    func getHWTransactionData(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: hwTransDataSvrUrl, param: param)
    }
    
    func broadcastTransactionSign(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: broadcastTransSvrUrl, param: param)
    }
    
    func getNetworkFee() -> (Bool, Data?){
        return self.postRequestSync(urlstr: networkFeeSvrUrl, param: nil)
    }
    
    func getAccountInfo(param: Any) -> (Bool, Data?){
        return self.postRequestSync(urlstr: getAccountInfoSvrUrl, param: param)
    }
}
