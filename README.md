# SecuXPaymentKit

[![CI Status](https://img.shields.io/travis/maochuns/SecuXPaymentKit.svg?style=flat)](https://travis-ci.org/maochuns/SecuXPaymentKit)
[![Version](https://img.shields.io/cocoapods/v/SecuXPaymentKit.svg?style=flat)](https://cocoapods.org/pods/SecuXPaymentKit)
[![License](https://img.shields.io/cocoapods/l/SecuXPaymentKit.svg?style=flat)](https://cocoapods.org/pods/SecuXPaymentKit)
[![Platform](https://img.shields.io/cocoapods/p/SecuXPaymentKit.svg?style=flat)](https://cocoapods.org/pods/SecuXPaymentKit)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory

Add privacy in the plist

Import the the module

```swift 
 import SecuXPaymentKit
```

Get account balance and history

```swift
 let account = SecuXAccount(name: "xxxx", type: .DCT, path: "", address: "", key: "")
 let accountMgr = SecuXAccountManager()
 let (ret, balance) = accountMgr!.getAccountBalance(account: account)
 if ret{
     print("Get account balance succssfully! \(balance?.balance ?? 0) USD Balance = \(balance?.balance_usd ?? 0) Balance = \(balance?.formattedBalance ?? 0)")
 }
 
 let (ret, historyArr) = accountMgr!.getAccountHistory(account: account)
 if ret{
     for item in historyArr{
         print("\(item.timestamp) \(item.tx_type) \(item.formatted_amount) \(item.amount_usd) \(item.detailsUrl)")
     }
     
 }
```

Get store info.

Do payment

## Requirements

Deployment target of iOS 12.0 or higher

## Installation

SecuXPaymentKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SecuXPaymentKit'
```

## Author

SecuX, maochunsun@secuxtech.com

## License

SecuXPaymentKit is available under the MIT license. See the LICENSE file for more info.
