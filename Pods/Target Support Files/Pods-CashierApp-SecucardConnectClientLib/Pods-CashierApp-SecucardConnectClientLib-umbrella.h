#import <UIKit/UIKit.h>

#import "MTLModel+Secucard.h"
#import "NSArray+NullStripper.h"
#import "NSDictionary+NullStripper.h"
#import "SCGlobals.h"
#import "SCAccountManager.h"
#import "SCLogManager.h"
#import "SCPersistenceManager.h"
#import "SCRestServiceManager.h"
#import "SCServiceManager.h"
#import "SCStompManager.h"
#import "SCAnnotationProductInfo.h"
#import "SCAuthDeviceAuthCode.h"
#import "SCAuthSession.h"
#import "SCAuthToken.h"
#import "SCAuthTokenNew.h"
#import "SCDocumentUploadsDocument.h"
#import "SCGeneralComponentsAddressComponent.h"
#import "SCGeneralComponentsAssign.h"
#import "SCGeneralComponentsDayTime.h"
#import "SCGeneralComponentsGeometry.h"
#import "SCGeneralComponentsMetaData.h"
#import "SCGeneralComponentsOpenHours.h"
#import "SCGeneralAccount.h"
#import "SCGeneralAccountDevice.h"
#import "SCGeneralAddress.h"
#import "SCGeneralAssignment.h"
#import "SCGeneralBeaconEnvironment.h"
#import "SCGeneralContact.h"
#import "SCGeneralEvent.h"
#import "SCGeneralLocation.h"
#import "SCGeneralMerchant.h"
#import "SCGeneralMerchantDetail.h"
#import "SCGeneralMerchantList.h"
#import "SCGeneralNews.h"
#import "SCGeneralNotification.h"
#import "SCGeneralPublicMerchant.h"
#import "SCGeneralStore.h"
#import "SCGeneralStoreSetDefault.h"
#import "SCGeneralTransaction.h"
#import "SCLoyaltyBonus.h"
#import "SCLoyaltyCard.h"
#import "SCLoyaltyCardGroup.h"
#import "SCLoyaltyCondition.h"
#import "SCLoyaltyCustomer.h"
#import "SCLoyaltyMerchantCard.h"
#import "SCLoyaltyProgram.h"
#import "SCLoyaltySale.h"
#import "SCPaymentContainer.h"
#import "SCPaymentContract.h"
#import "SCPaymentCustomer.h"
#import "SCPaymentData.h"
#import "SCPaymentSecupayDebit.h"
#import "SCPaymentSecupayPrepay.h"
#import "SCPaymentTransaction.h"
#import "SCPaymentTransferAccount.h"
#import "SCGeoQuery.h"
#import "SCMediaResource.h"
#import "SCObjectList.h"
#import "SCQueryParams.h"
#import "SCSecuObject.h"
#import "SCServiceCallWrapper.h"
#import "SCServiceEventObject.h"
#import "SCServicesIdRequestPerson.h"
#import "SCServicesIdResultAddress.h"
#import "SCServicesIdResultAttachment.h"
#import "SCServicesIdResultContactData.h"
#import "SCServicesIdResultCustomData.h"
#import "SCServicesIdResultIdentificationDocument.h"
#import "SCServicesIdResultIdentificationProcess.h"
#import "SCServicesIdResultPerson.h"
#import "SCServicesIdResultUserData.h"
#import "SCServicesIdResultValue.h"
#import "SCServicesContract.h"
#import "SCServicesIdentRequest.h"
#import "SCServicesIdentResult.h"
#import "SCSmartBasket.h"
#import "SCSmartBasketInfo.h"
#import "SCSmartCashierDisplay.h"
#import "SCSmartCheckin.h"
#import "SCSmartDevice.h"
#import "SCSmartIdent.h"
#import "SCSmartProduct.h"
#import "SCSmartProductGroup.h"
#import "SCSmartReceiptLine.h"
#import "SCSmartText.h"
#import "SCSmartTransaction.h"
#import "SCSmartTransactionResult.h"
#import "SCTransportMessage.h"
#import "SCTransportResult.h"
#import "SCTransportStatus.h"
#import "SCClientConfiguration.h"
#import "SCConnectClient.h"
#import "SCUploadService.h"
#import "SCSecuAppService.h"
#import "SCAccountDevicesService.h"
#import "SCAccountService.h"
#import "SCMerchantService.h"
#import "SCNewsService.h"
#import "SCPublicMerchantService.h"
#import "SCStoreService.h"
#import "SCTransactionService.h"
#import "SCCardsService.h"
#import "SCLoyaltyCustomerService.h"
#import "SCMerchantCardsService.h"
#import "SCContainerService.h"
#import "SCCustomerService.h"
#import "SCSecupayDebitService.h"
#import "SCSecupayPrepayService.h"
#import "SCAbstractService.h"
#import "SCIdentService.h"
#import "SCCheckinService.h"
#import "SCDeviceService.h"
#import "SCSmartIdentService.h"
#import "SCSmartTransactionService.h"
#import "StompKit.h"

FOUNDATION_EXPORT double SecucardConnectClientLibVersionNumber;
FOUNDATION_EXPORT const unsigned char SecucardConnectClientLibVersionString[];

