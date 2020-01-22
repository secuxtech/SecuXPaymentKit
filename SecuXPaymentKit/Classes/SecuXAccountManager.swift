//
//  SecuXAccountManager.swift
//  Pods-SecuXPaymentKit_Example
//
//  Created by Maochun Sun on 2020/1/22.
//

import Foundation

open class SecuXAccountManager{
    
    let secXSvrReqHandler = SecuXServerRequestHandler()
    
    public init(){
        
    }
    
    open func getAccountBalance(account: SecuXAccount) -> (Bool, SecuXAccountBalance?){
        
        switch account.type{
        case .BTC:
            if account.theKey.count == 0{
                return self.getBTCAccountBalanceByAddr(account: account)
            }else{
                return self.getBTCAccountBalance(account: account)
            }
            //break
            
        case .LBR:
            return self.getLBRAccountBalance(account: account)
            //break
            
        case .DCT:
            return self.getDCTAccountBalance(account: account)
            //break
            
        
        default:
            break
        }
        
        return (false, nil)
    }
    
    
    open func getAccountHistory(account: SecuXAccount) -> (Bool, [SecuXAccountHistory]){
        
        switch account.type{
        case .BTC:
            if account.theKey.count == 0{
                return self.getBTCAccountHistoryByAddr(account: account)
            }else{
                return self.getBTCAccountHistory(account: account)
            }
            //break
            
        case .LBR:
            return self.getLBRAccountHistory(account: account)
            //break
            
        case .DCT:
            return self.getDCTAccountHistory(account: account)
            //break
            
        default:
            break
        }
        
        return (false, [])
    }
    
    
    
    private func getDCTAccountBalance(account: SecuXAccount) -> (Bool, SecuXAccountBalance?){
        logw("getDCTAccountBalance \(account.name)")
        
        if account.name.count == 0{
           return (false, nil)
        }
        
        let param = ["coinType": account.type.rawValue, "pubKey":"\(account.name)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountBalance(param: param)
        if ret, let balInfo = data{
        
            return self.handleAccountBalanceData(account: account, accInfo: balInfo)
            
        }else{
            logw("getDCTAccountBalance \(account.name) failed")
        }
        
        return (false, nil)
    }
    
    private func getDCTAccountHistory(account: SecuXAccount) -> (Bool, [SecuXAccountHistory]){
        logw("getDCTAccountHistory \(account.name)")
        if account.name.count == 0{
           return (false, [])
        }

        let param = ["coinType": "DCT", "pubKey":"\(account.name)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountHistory(param: param)
        if ret, let accInfo = data{
        
            return self.handleAccountHistoryData(account: account, accInfo: accInfo)
        }else{
            logw("getDCTAccountHistory \(account.name) failed")
        }
        return (false, [])
    }
    
    private func getLBRAccountBalance(account: SecuXAccount) -> (Bool, SecuXAccountBalance?){
        logw("getLBRAccountBalance \(account.name)")
        
        if account.name.count == 0{
           return (false, nil)
        }
        

        let param = ["coinType": "LBR", "pubKey":"\(account.theAddress)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountBalance(param: param)
        if ret, let accInfo = data{
        
            return self.handleAccountBalanceData(account: account, accInfo: accInfo)
            
        }else{
            logw("getLBRAccountBalance \(account.name) failed")
        }
        
        return (false, nil)
    }
    
    private func getLBRAccountHistory(account: SecuXAccount) -> (Bool, [SecuXAccountHistory]){
        logw("getDCTAccountHistory \(account.name)")
        if account.name.count == 0{
           return (false, [])
        }

        let param = ["coinType": "LBR", "pubKey":"\(account.theAddress)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountHistory(param: param)
        if ret, let accInfo = data{
        
            return self.handleAccountHistoryData(account: account, accInfo: accInfo)
        }else{
            logw("getDCTAccountHistory \(account.name) failed")
        }
        return (false, [])
    }
    
    
    private func getBTCAccountBalance(account: SecuXAccount) -> (Bool, SecuXAccountBalance?){
        logw("getBTCAccountBalance \(account.name)")
        
    
        if account.theKey.count == 0{
            print("No account key get account history abort!!!")
            return (false, nil)
        }
        
    
        
        let param = ["coinType": "\(account.type.rawValue)", "pubKey":"\(account.theKey)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountBalance(param: param)
        
        if ret, let accInfo = data{
            return self.handleAccountBalanceData(account: account, accInfo: accInfo)
        }else{
            logw("getBTCAccountBalance \(account.name) failed")
        }
        
        return (false, nil)
    }
    
    private func getBTCAccountBalanceByAddr(account: SecuXAccount) -> (Bool, SecuXAccountBalance?){
        logw("getBTCAccountBalanceByAddr \(account.name)")
        

        
        if account.theAddress.count == 0{
            print("No account address get account balance abort!!!")
            return (false, nil)
        }
        
        let param = ["coinType": "\(account.type.rawValue)", "addr":"\(account.theAddress)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountBalanceByAddr(param: param)
        
        if ret, let accInfo = data{
            return self.handleAccountBalanceData(account: account, accInfo: accInfo)
        }else{
            logw("getBTCAccountBalance \(account.name) failed")
        }
        
        return (false, nil)
    }
    
    private func getBTCAccountHistory(account: SecuXAccount) -> (Bool, [SecuXAccountHistory]){
        
        logw("getBTCAccountHistory \(account.name)")
        
        
    
        if account.theKey.count == 0{
            logw("No account key get account history abort!!!")
            return (false, [])
        }
        
        let param = ["coinType": "\(account.type.rawValue)", "pubKey":"\(account.theKey)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountHistory(param: param)
        if ret, let accInfo = data{
            return self.handleAccountHistoryData(account: account, accInfo: accInfo)
            
        }else{
            logw("getBTCAccountHistory \(account.name) failed")
        }
        
        return (false, [])

    }
    
    private func getBTCAccountHistoryByAddr(account: SecuXAccount) -> (Bool, [SecuXAccountHistory]){
        logw("getBTCAccountHistoryByAddr \(account.name)")
        
       
    
        if account.theAddress.count == 0{
            logw("No account key get account history abort!!!")
            return (false, [])
        }
        
        let param = ["coinType": "\(account.type.rawValue)", "addr":"\(account.theAddress)"]
        let (ret, data) = self.secXSvrReqHandler.getAccountHistoryByAddr(param: param)
        if ret, let accInfo = data{
            return self.handleAccountHistoryData(account: account, accInfo: accInfo)
            
        }else{
            logw("getBTCAccountHistory \(account.name) failed")
            
            //account.updateAccHistory.value = true
        }

        return (false, [])
    }
    
    private func handleAccountBalanceData(account: SecuXAccount, accInfo: Data) -> (Bool, SecuXAccountBalance?){
        
        let decoder = JSONDecoder()
        do{
            
            let balance = try decoder.decode(SecuXAccountBalance.self, from: accInfo)
            return (true, balance)
            
            
        }catch{
            logw("handleAccountBalanceData error: " + error.localizedDescription)
        }
        
        return (false, nil)
    }
    
    private func handleAccountHistoryData(account: SecuXAccount, accInfo: Data) -> (Bool, [SecuXAccountHistory]){
        let decoder = JSONDecoder()
   
        do {
            
            let accHistory = try decoder.decode([SecuXAccountHistory].self, from: accInfo)
            return (true, accHistory)
            
            
            
        } catch let e {
            logw("handleAccountHistoryData error: " + e.localizedDescription)
        }
        
        //account.updateAccHistory.value = true
        
        return (false, [])
    }
}
