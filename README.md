# Setting up CashierApp (beta)
---
To run and develop the CashierApp at this time you need to place the needed connect sdk on the same file system level as the CashierApp.

1. So you run from a folder of your preferred workspace:  

    * `git clone git@github.com:secucard/secucard-connect-ios-sdk.git SecucardConnectClient`
    * `git clone ssh://git@stash.webhaus.de:7999/sma/secucard-cashierdemo-ios-app.git CashierApp`
    
2. cd into `CashierApp`

3. run `pod install`

4. run `open CashierApp.xcworkspace`

5. Build or run the CashierApp Scheme