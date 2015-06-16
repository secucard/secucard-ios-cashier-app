platform :ios, '8.0'
use_frameworks!

target 'CashierApp', :exclusive => true do
  pod "SecucardConnectClientLib", :git => "git@github.com:secucard/secucard-connect-objc-client-lib.git", :branch => "segmentation_error"

  pod 'SwiftyJSON', '~> 2.2'
  pod 'SnapKit', '~> 0.10.0'
  pod 'Alamofire', '~> 1.2'
  pod 'TFBarcodeScanner'

end

target 'CashierAppTests' do
  pod "SecucardConnectClientLib", :git => "git@github.com:secucard/secucard-connect-objc-client-lib.git", :branch => "segmentation_error"

  pod 'Specta'
  pod 'Expecta'
end

