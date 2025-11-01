import 'package:ezbusdriver/gui/widgets/app_bar.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../view_models/this_application_view_model.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  PaymentMethodsScreenState createState() => PaymentMethodsScreenState();
}
class PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final GlobalKey<FormState> _bankAccountKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _paypalKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _instantTransferKey = GlobalKey<FormState>();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _routingNumberController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _paypalEmailController = TextEditingController();
  final TextEditingController _instantTransferMobileNoController = TextEditingController();
  final TextEditingController _instantTransferMobileNetworkController = TextEditingController();
  String? _accountNumber = '';
  String? _routingNumber = '';
  String? _accountHolderName = '';
  String? _bankName = '';
  String? _paypalEmail = '';
  String? _instantTransferMobileNo = '';
  String? _instantTransferMobileNetwork = '';
  int preferredMethod = 1;
  bool validationProblems = false;

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      thisAppModel.getPreferredPaymentMethodEndpoint();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: buildAppBar(
        context,
        'Payment Methods',
        left: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<ThisApplicationViewModel>(
            builder: (context, thisApplicationViewModel, child) {
              if (thisApplicationViewModel.preferredPaymentMethodLoadingState
                  .loadingFinished()) {
                updateData(thisApplicationViewModel);
              }
              return displayPaymentMethods(context)!;
            },
          )),
    );
  }

  //displayPaymentMethods
  Widget? displayPaymentMethods(BuildContext context) {
    if (thisAppModel.preferredPaymentMethodLoadingState.inLoading()) {
      // loading. display animation
      return loadingPaymentMethods();
    } else
    if (thisAppModel.preferredPaymentMethodLoadingState.loadingFinished()) {
      if (kDebugMode) {
        print("network call finished");
      }
      //network call finished.
      if (thisAppModel.preferredPaymentMethodLoadingState.loadError != null) {
        if (kDebugMode) {
          print("page loading error. Display the error");
        }
        // page loading error. Display the error
        return failedScreen(
            context,
            thisAppModel.preferredPaymentMethodLoadingState.failState!);
      }
      else {
        return ListView(
          children: [
            ExpansionTile(
              leading: const Icon(
                FontAwesomeIcons.building, color: AppTheme.primary,),
              title: Text(translation(context)?.bankAccount ?? 'Bank Account', style: AppTheme.bold16DarkBlue),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _bankAccountKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _accountNumberController,
                          decoration: InputDecoration(
                            labelText: translation(context)?.accountNumber ?? 'Account Number',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return translation(context)?.pleaseEnterYourAccountNumber ?? 'Please enter your account number';
                            }
                            //Only accept numbers
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return translation(context)?.pleaseEnterValidAccountNumber ?? 'Please enter a valid account number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _routingNumberController,
                          decoration: InputDecoration(
                            labelText: translation(context)?.routingNumber ?? 'Routing Number',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return translation(context)?.pleaseEnterYourRoutingNumber ?? 'Please enter your routing number';
                            }
                            //Only accept numbers
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return translation(context)?.pleaseEnterValidRoutingNumber ?? 'Please enter a valid routing number';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _accountHolderNameController,
                          decoration: InputDecoration(
                            labelText: translation(context)?.accountHolderName ?? 'Account Holder Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return translation(context)?.pleaseEnterYourAccountName ?? 'Please enter your account holder name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _bankNameController,
                          decoration: InputDecoration(
                            labelText: translation(context)?.bankName ?? 'Bank Name',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return translation(context)?.pleaseEnterYourBankName ?? 'Please enter your bank name';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_bankAccountKey.currentState!.validate()) {
                                _accountHolderName =
                                    _accountHolderNameController.text;
                                _accountNumber = _accountNumberController.text;
                                _routingNumber = _routingNumberController.text;
                                _bankName = _bankNameController.text;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.colorSecondary,
                            ),
                            child: Text(translation(context)?.saveBankAccount ?? 'Save Bank Account'),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            ExpansionTile(
              leading: const Icon(
                FontAwesomeIcons.paypal, color: AppTheme.primary,),
              title: Text('Paypal', style: AppTheme.bold16DarkBlue),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _paypalKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _paypalEmailController,
                          decoration: const InputDecoration(
                            labelText: 'Paypal Email',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your paypal email';
                            }
                            if (!RegExp(
                                r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                                .hasMatch(value)) {
                              return translation(context)?.pleaseEnterValidEmail ?? 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_paypalKey.currentState!.validate()) {
                                _paypalEmail = _paypalEmailController.text;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                            ),
                            child: const Text('Save'),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            ExpansionTile(
              leading: const Icon(
                FontAwesomeIcons.mobileAlt, color: AppTheme.primary,),
              title: Text(
                  'Mobile Money Transfer', style: AppTheme.bold16DarkBlue),
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                      key: _instantTransferKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _instantTransferMobileNoController,
                            decoration: InputDecoration(
                              labelText: translation(context)?.instantTransferMobileNumber ?? 'Instant transfer mobile number',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your instant transfer mobile number';
                              }
                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return translation(context)?.pleaseEnterValidMobileNumber ?? 'Please enter a valid mobile number';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _instantTransferMobileNetworkController,
                            decoration: InputDecoration(
                              labelText: translation(context)?.instantTransferMobileNetwork ?? 'Instant transfer mobile network',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return translation(context)?.pleaseEnterYourInstantTransferMobileNetwork ?? 'Please enter your instant transfer mobile network';
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_instantTransferKey.currentState!
                                    .validate()) {
                                  _instantTransferMobileNo =
                                      _instantTransferMobileNoController.text;
                                  _instantTransferMobileNetwork =
                                      _instantTransferMobileNetworkController
                                          .text;
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                              ),
                              child: Text(translation(context)?.save ?? 'Save'),
                            ),
                          )
                        ],
                      )
                  ),
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: 50.h,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                  translation(context)?.preferredPaymentMethod ?? 'Preferred Payment Method:',
                  style: AppTheme.bold16DarkBlue),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    value: preferredMethod,
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Text(translation(context)?.cash ?? 'Cash'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text(translation(context)?.bankAccount ?? 'Bank Account'),
                      ),
                      const DropdownMenuItem(
                        value: 3,
                        child: Text('Paypal'),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Text(translation(context)?.mobileMoneyTransfer ?? 'Mobile Money Transfer'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        thisAppModel.currentUser!.preferredPaymentMethod =
                        value as int;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h,),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 100.w,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      validationProblems = false;
                      if (preferredMethod == 2) {
                        if (_accountHolderName == null ||
                            _accountHolderName!.isEmpty ||
                            _accountNumber == null ||
                            _accountNumber!.isEmpty ||
                            _routingNumber == null ||
                            _routingNumber!.isEmpty ||
                            _bankName == null ||
                            _bankName!.isEmpty) {
                          validationProblems = true;
                        }
                      }
                      else if (preferredMethod == 3) {
                        if (_paypalEmail == null || _paypalEmail!.isEmpty) {
                          validationProblems = true;
                        }
                      }
                      else if (preferredMethod == 4) {
                        if (_instantTransferMobileNo!.isEmpty) {
                          validationProblems = true;
                        }
                      }
                    });
                    if(validationProblems == false) {
                      thisAppModel.updatePreferredPaymentMethodEndpoint(
                          preferredMethod,
                          _accountNumber,
                          _routingNumber,
                          _accountHolderName,
                          _bankName,
                          _paypalEmail,
                          _instantTransferMobileNo,
                          _instantTransferMobileNetwork,
                          context);
                    }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          AppTheme.primary)
                  ),
                  child:
                  thisAppModel.updatePreferredPaymentMethodLoadingState.inLoading() ?
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ) :
                  SizedBox(
                    height: 35.h,
                    child: const Center(
                      child: Text(
                        'Submit', style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: validationProblems,
                child: Text(
                  translation(context)?.preferredPaymentMethodHasValidationProblems ??
                      "The preferred payment method has validation problems",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          ],
        );
      }
    }
    return null;
  }

  Widget loadingPaymentMethods() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }

  void updateData(ThisApplicationViewModel thisApplicationViewModel) {
    if (thisApplicationViewModel.currentUser != null &&
        thisApplicationViewModel.currentUser!.preferredPaymentMethod != null) {
      preferredMethod =
      thisApplicationViewModel.currentUser!.preferredPaymentMethod!;

      _accountNumber =
          thisApplicationViewModel.currentUser!.bankAccount?.accountNumber;
      _routingNumber =
          thisApplicationViewModel.currentUser!.bankAccount?.routingNumber;
      _accountHolderName =
          thisApplicationViewModel.currentUser!.bankAccount?.beneficiaryName;
      _bankName =
          thisApplicationViewModel.currentUser!.bankAccount?.bankName;

      _paypalEmail =
      thisApplicationViewModel.currentUser!.payPalAccount?.email!;

      _instantTransferMobileNo =
      thisApplicationViewModel.currentUser!.mobileMoneyAccount?.phoneNumber!;

      _instantTransferMobileNetwork =
      thisApplicationViewModel.currentUser!.mobileMoneyAccount?.network!;

      if (_accountNumber != null) {
        _accountNumberController.text = _accountNumber!;
      }
      if (_routingNumber != null) {
        _routingNumberController.text = _routingNumber!;
      }
      if (_accountHolderName != null) {
        _accountHolderNameController.text = _accountHolderName!;
      }
      if (_bankName != null) {
        _bankNameController.text = _bankName!;
      }
      if (_paypalEmail != null) {
        _paypalEmailController.text = _paypalEmail!;
      }

      if (_instantTransferMobileNo != null) {
        _instantTransferMobileNoController.text = _instantTransferMobileNo!;
      }

      if (_instantTransferMobileNetwork != null) {
        _instantTransferMobileNetworkController.text =
        _instantTransferMobileNetwork!;
      }
    }
  }
}