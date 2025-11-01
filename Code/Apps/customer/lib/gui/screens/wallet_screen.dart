
import 'dart:ffi';

import 'package:ezbus/gui/widgets/tab_choice_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/services/service_locator.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:ezbus/view_models/this_application_view_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkTransactionType.dart';
import 'package:flutterwave_standard_smart/core/flutterwave.dart';
import 'package:flutterwave_standard_smart/models/requests/customer.dart';
import 'package:flutterwave_standard_smart/models/requests/customizations.dart';
import 'package:flutterwave_standard_smart/models/responses/charge_response.dart';

import 'package:flutter_paytabs_bridge/BaseBillingShippingInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkConfigurationDetails.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkLocale.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkTokenFormat.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkTokeniseType.dart';
import 'package:flutter_paytabs_bridge/flutter_paytabs_bridge.dart';
import 'package:flutter_paytabs_bridge/IOSThemeConfiguration.dart';
import 'package:flutter_paytabs_bridge/PaymentSDKSavedCardInfo.dart';
import 'package:flutter_paytabs_bridge/PaymentSdkTransactionClass.dart';
import 'package:flutter_paytabs_bridge/PaymentSDKQueryConfiguration.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../utils/config.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';
import '../widgets/form_error.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  PageController? _pageController;
  int? paymentTabIdx = 0;

  TabController? _controller;

  final List<String> errors = [];

  TextEditingController? paymentAmountController;

  String? paymentAmount;

  void removeAllErrors() {
    setState(() {
      errors.clear();
    });
  }

  @override
  void initState() {
    _pageController = PageController();
    paymentAmountController = TextEditingController();
    paymentAmountController!.text = "100.00";
    paymentAmount = paymentAmountController!.text;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        removeAllErrors();
        thisAppModel.getPaymentsEndpoint();
      });
    });
    super.initState();
  }

  Future<void> _refreshData() {
    return Future(
            () {
          thisAppModel.getPaymentsEndpoint();
        }
    );
  }

  Widget displayAllPayments(ThisApplicationViewModel thisApplicationViewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10.h),
          TabChoiceWidget(
            color: AppTheme.primary,
            choices: [
              translation(context)?.deposit ?? "Deposit",
              translation(context)?.history ?? "History"
            ],
            pageController: _pageController,
          ),
          SizedBox(
            height: 600.h,
            child: PageView(
                controller: _pageController,
                onPageChanged: (pageIndex) {
                  if (kDebugMode) {
                    print("pageIndex $pageIndex");
                  }
                  setState(() {
                    paymentTabIdx = pageIndex;
                  });
                  _controller?.animateTo(pageIndex);
                },
                children: List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: Stack(
                        children: [
                          displayPayments(thisApplicationViewModel, index),
                        ],
                      ),
                    ),
                  );
                })
            ),
          ),
        ],
      ),
    );
  }

  Widget displayPayments(ThisApplicationViewModel thisApplicationViewModel,
      int index) {
    if (thisApplicationViewModel.isLoggedIn != true) {
      return signInOut(context, widget);
    }
    if (thisApplicationViewModel.paymentsLoadingState.inLoading()) {
      return loadingScreen();
    }
    else {
      if (thisApplicationViewModel.paymentsLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(context,
            thisApplicationViewModel.paymentsLoadingState.failState);
      }
      List<Widget> a = [];

      if (index == 0) {
        a.add(Column(
          children: [
            const SizedBox(height: 30),
            Image.asset(
              "assets/images/walletImage.png",
              height: 100.h,
            ),
            const SizedBox(height: 30),
            Text(
              translation(context)?.myWalletBalance ?? 'My wallet balance ',
              style: const TextStyle(
                color: Color(0xFF3F3F3F),
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                //show in two digits
                "${thisApplicationViewModel.currentUser?.wallet
                    ?.toStringAsFixed(2) ?? ''} ${thisApplicationViewModel
                    .settings?.currencyCode}",
                style: const TextStyle(
                  fontSize: 48,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colorSecondary,
                ),
              ),
            ),
            //add payment amount

            thisApplicationViewModel.settings?.paymentMethod != "none" ?
            Padding(
              padding: EdgeInsets.only(
                  left: 20.0.w, right: 20.0.w, top: 20.0.h),
              child: TextField(
                controller: paymentAmountController,
                decoration: InputDecoration(
                  //border: OutlineInputBorder(),
                  labelText: translation(context)?.addMoney ?? 'Add money',
                  labelStyle: const TextStyle(
                    color: Color(0xFF909090),
                    fontSize: 24,
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w500,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                //numeric
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (String? value) {
                  setState(() {
                    paymentAmount = value;
                  });
                },
              ),
            ): Container(),
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  getPaymentButton(thisApplicationViewModel),
                ],
              ),
            ),
            //add pay button
          ],
        ));
        displayErrors(a, thisApplicationViewModel);
      }
      else {
        if (thisApplicationViewModel.payments.isNotEmpty) {
          a.addAll(paymentsListScreen(thisApplicationViewModel));
        }
        else {
          a.add(Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30.h),
              Image.asset("assets/images/no_transaction.png", height: MediaQuery
                  .of(context)
                  .orientation == Orientation.landscape ? 150 : 250,),
              Padding(
                padding: EdgeInsets.only(top: 30.h),
                child: Column(
                  children: [
                    Text(translation(context)?.noTransactionsYet ??
                        "Oops... No transactions.",
                      style: AppTheme.caption,
                      textAlign: TextAlign.center,),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ));
        }
      }
      return ListView(
          children: a
      );
    }
  }

  List<Widget> paymentsListScreen(
      ThisApplicationViewModel thisApplicationViewModel) {
    return
      List.generate(thisApplicationViewModel.payments.length, (i) {
        IconData payementIcon = thisApplicationViewModel.payments[i]
            .paymentMethod == "PayPal"
            ? FontAwesomeIcons.paypal
            : FontAwesomeIcons.creditCard;
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          child: ListTile(
            trailing: SizedBox(
              width: 50.w,
              height: 60.h,
              child: Icon(
                payementIcon,
                color: AppTheme.primary,
                size: 35,
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: 8.0.h),
              child: Text(
                thisApplicationViewModel.payments[i].date.toString(),
                style: AppTheme.textlightPrimaryMedium,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(left: 20.0.w, top: 10.0.h, bottom: 10.0),
              child: Text(
                thisApplicationViewModel.payments[i].amount.toString(),
                style: const TextStyle(
                  color: AppTheme.colorSecondary,
                  fontSize: 24,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        return displayAllPayments(thisApplicationViewModel);
      },
    );
  }

  getPaymentButton(ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.settings == null) {
      return Container();
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "braintree") {
      return ElevatedButton(
        onPressed: () async {
          if (paymentAmount!.isNotEmpty) {
            removeAllErrors();
            final request = BraintreeDropInRequest(
              clientToken: Config.braintreeTokenizationKey,
              collectDeviceData: true,
              vaultManagerEnabled: true,
              googlePaymentRequest: BraintreeGooglePaymentRequest(
                totalPrice: paymentAmount!,
                currencyCode: thisApplicationViewModel.settings!.currencyCode!,
                billingAddressRequired: false,
              ),
              paypalRequest: BraintreePayPalRequest(
                amount: paymentAmount!,
                displayName: Config.systemCompany,
                currencyCode: thisApplicationViewModel.settings!.currencyCode!,
              ),
            );
            BraintreeDropInResult? result = await BraintreeDropIn
                .start(request);
            if (result != null) {
              if (kDebugMode) {
                print('Nonce: ${result.paymentMethodNonce
                    .nonce}');
              }
              //sendNonceForTripEndpoint
              thisApplicationViewModel
                  .sendNonceForTripEndpoint(
                  result.paymentMethodNonce.nonce,
                  paymentAmount!);
            } else {
              if (kDebugMode) {
                print('Selection was canceled.');
              }
            }
          }
        },
        style: ButtonStyle(
          backgroundColor:
          paymentAmount!.isNotEmpty ?
          MaterialStateProperty.all<Color>(
              AppTheme.primary) : MaterialStateProperty.all<Color>(
              Colors.grey),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.fromLTRB(30, 15, 30, 15)),
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              )),
        ),
        child: thisApplicationViewModel.sendNonceForTripLoadingState
            .inLoading() ? const CircularProgressIndicator(
          color: AppTheme.backgroundColor,
        ) :
        Text(
          translation(context)?.addMoney ?? 'Add',
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.backgroundColor,
          ),
        ),
      );
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "razorpay") {
      return ElevatedButton(
        onPressed: () async {
          if (paymentAmount!.isNotEmpty) {
            removeAllErrors();
            Razorpay razorpay = Razorpay();
            double payAmount = double.tryParse(paymentAmount!) ?? 0;
            payAmount = payAmount * 100;
            if (payAmount == 0) {
              return;
            }
            var options = {
              'key': Config.razorpayKey,
              'amount': payAmount,
              'name': Config.systemCompany,
              'description': translation(context)?.addMoneyToWallet ??
                  'Add money to wallet',
              'retry': {'enabled': true, 'max_count': 1},
              'prefill': {
                'contact': thisAppModel.currentUser?.telNumber ?? '',
                'email': thisAppModel.currentUser?.email ?? ''
              },
            };
            razorpay.on(
                Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
            razorpay.on(
                Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
            razorpay.open(options);
          }
        },
        style: ButtonStyle(
          backgroundColor:
          paymentAmount!.isNotEmpty ?
          MaterialStateProperty.all<Color>(
              AppTheme.primary) : MaterialStateProperty.all<Color>(
              Colors.grey),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.fromLTRB(30, 15, 30, 15)),
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              )),
        ),
        child: thisApplicationViewModel.sendRazorPayPaymentIDLoadingState
            .inLoading() ? const CircularProgressIndicator(
          color: AppTheme.backgroundColor,
        ) :
        Text(
          translation(context)?.addMoney ?? 'Add',
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.backgroundColor,
          ),
        ),
      );
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "flutterwave") {
      return ElevatedButton(
        onPressed: () async {
          if (paymentAmount!.isNotEmpty) {
            removeAllErrors();
            final Customer customer = Customer(
                phoneNumber: thisAppModel.currentUser?.telNumber ?? '',
                email: thisAppModel.currentUser?.email ?? '',
                name: thisAppModel.currentUser?.name ?? ''
            );
            final Flutterwave flutterwave = Flutterwave(
                context: context,
                publicKey: Config.flutterwaveKey,
                currency: thisApplicationViewModel.settings!.currencyCode!,
                redirectUrl: "https://www.google.com/",
                //generate unique references per transaction
                txRef: DateTime.now().toIso8601String(),
                amount: paymentAmount!,
                customer: customer,
                paymentOptions: "card",
                customization: Customization(
                    title: translation(context)?.addMoneyToWallet ??
                        'Add money to wallet'),
                isTestMode: false);
            flutterwave.charge().then((ChargeResponse response) =>
            {
              if(response.status!.toLowerCase() == "successful"){
                //sendFlutterWavePaymentIDEndpoint
                thisApplicationViewModel.sendFlutterwaveTransactionIDEndpoint(
                    response.transactionId)
              }
            });
          }
        },
        style: ButtonStyle(
          backgroundColor:
          paymentAmount!.isNotEmpty ?
          MaterialStateProperty.all<Color>(
              AppTheme.primary) : MaterialStateProperty.all<Color>(
              Colors.grey),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.fromLTRB(30, 15, 30, 15)),
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              )),
        ),
        child:
        thisApplicationViewModel.sendFlutterwaveTransactionIDLoadingState
            .inLoading() ? const CircularProgressIndicator(
          color: AppTheme.backgroundColor,
        ) :
        Text(
          translation(context)?.addMoney ?? 'Add',
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.backgroundColor,
          ),
        ),
      );
    }
    //paytabs
    else if (thisApplicationViewModel.settings?.paymentMethod == "paytabs") {
      return ElevatedButton(
        onPressed: () async {
          if (paymentAmount!.isNotEmpty) {
            removeAllErrors();
            double payAmount = double.tryParse(paymentAmount!) ?? 0;
            // payAmount = payAmount * 100;
            if (payAmount == 0) {
              return;
            }
            var billingDetails = BillingDetails(
                thisApplicationViewModel.currentUser?.name ?? '',
                thisApplicationViewModel.currentUser?.email ?? '',
                thisApplicationViewModel.currentUser?.telNumber ?? '',
                thisApplicationViewModel.currentUser?.address ?? '',
                Config.paytabsMerchantCountryCode,
                "",
                "",
                "");
            var configuration = PaymentSdkConfigurationDetails(
                profileId: Config.paytabsProfileId,
                serverKey: Config.paytabsServerKey,
                clientKey: Config.paytabsClientKey,
                merchantCountryCode: Config.paytabsMerchantCountryCode,
                billingDetails: billingDetails,
                showBillingInfo: true,
                cartId: 'Add money to wallet',
                cartDescription: translation(context)?.addMoneyToWallet ??
                    'Add money to wallet',
                merchantName: Config.systemCompany,
                screentTitle: "Pay with Card",
                locale: PaymentSdkLocale.EN,
                amount: payAmount,
                currencyCode: thisApplicationViewModel.settings!.currencyCode!);

            FlutterPaytabsBridge.startCardPayment(configuration, (event) {
              setState(() {
                if (event["status"] == "success") {
                  // Handle transaction details here.
                  var transactionDetails = event["data"];
                  print(transactionDetails);

                  if (transactionDetails["isSuccess"]) {
                    print("successful transaction");
                    //sendPayTabsPaymentIDEndpoint
                    //get transactionReference inside paymentResult
                    String transactionReference = transactionDetails["transactionReference"];
                    thisApplicationViewModel.sendPaytabsTransRefEndpoint(transactionReference);
                  } else {
                    print("failed transaction");
                  }
                } else if (event["status"] == "error") {
                  showAlertDialog(context, "Payment Failed", event["message"]);
                  // Handle error here.
                } else if (event["status"] == "event") {
                  // Handle cancel events here.
                }
              });
            });
          }
        },
        style: ButtonStyle(
          backgroundColor:
          paymentAmount!.isNotEmpty ?
          MaterialStateProperty.all<Color>(
              AppTheme.primary) : MaterialStateProperty.all<Color>(
              Colors.grey),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.fromLTRB(30, 15, 30, 15)),
          shape: MaterialStateProperty.all<
              RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              )),
        ),
        child:
        thisApplicationViewModel.sendPaytabsTransRefLoadingState
            .inLoading() ? const CircularProgressIndicator(
          color: AppTheme.backgroundColor,
        ) :
        Text(
          translation(context)?.addMoney ?? 'Add',
          style: const TextStyle(
            fontSize: 20,
            color: AppTheme.backgroundColor,
          ),
        ),
      );
    }
    else {
      return Container();
    }
  }

  handlePaymentErrorResponse(PaymentFailureResponse response) {
    thisAppModel.sendRazorPayPaymentIDLoadingState.error = response.message;
    thisAppModel.sendRazorPayPaymentIDLoadingState.setError(1);
    //display error
    // showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    //display paymentId, orderId, signature;
    // showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
    //sendRazorPayPaymentIDEndpoint
    thisAppModel.sendRazorPayPaymentIDEndpoint(response.paymentId);
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: Text(translation(context)?.continueText ?? "Continue"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true)
            .pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void displayErrors(List<Widget> a,
      ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.settings == null) {
      return;
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "braintree") {
      if (thisApplicationViewModel.sendNonceForTripLoadingState.loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.sendNonceForTripLoadingState.error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.sendNonceForTripLoadingState.loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "razorpay") {
      if (thisApplicationViewModel.sendRazorPayPaymentIDLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.sendRazorPayPaymentIDLoadingState.error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.sendRazorPayPaymentIDLoadingState.loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "flutterwave") {
      if (thisApplicationViewModel.sendFlutterwaveTransactionIDLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.sendFlutterwaveTransactionIDLoadingState
                .error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.sendFlutterwaveTransactionIDLoadingState
            .loadError =
        null;
      }
    }
    else if (thisApplicationViewModel.settings?.paymentMethod == "paytabs") {
      if (thisApplicationViewModel.sendPaytabsTransRefLoadingState
          .loadError !=
          null) {
        errors.add(
            thisApplicationViewModel.sendPaytabsTransRefLoadingState
                .error!);
        a.add(FormError(errors: errors));
        thisApplicationViewModel.sendPaytabsTransRefLoadingState
            .loadError =
        null;
      }
    }
  }
}