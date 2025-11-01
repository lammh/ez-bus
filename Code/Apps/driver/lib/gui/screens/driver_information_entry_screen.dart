import 'package:flutter/material.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:im_stepper/stepper.dart';
import 'package:provider/provider.dart';

import '../../services/service_locator.dart';
import '../../view_models/this_application_view_model.dart';
import '../languages/language_constants.dart';
import '../widgets/animated_app_bar.dart';
import '../widgets/form_error.dart';
import 'add_edit_document_screen.dart';

class DriverInformationEntryScreen extends StatefulWidget {
  const DriverInformationEntryScreen({super.key});

  @override
  DriverInformationEntryScreenState createState() => DriverInformationEntryScreenState();
}

class DriverInformationEntryScreenState extends State<DriverInformationEntryScreen> {

  ThisApplicationViewModel thisApplicationViewModel =  serviceLocator<ThisApplicationViewModel>();
  int activeStep = 0;
  int upperBound = 1;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  TextEditingController? _firstNameController,
      _lastNameController, _emailController,
      _phoneNumberController, _addressController, _licenseController;

  List<String> errors = [];

  String? responseMessage;

  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _licenseController = TextEditingController();

    loadDriverDataToGui(thisApplicationViewModel);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
        builder: (context, thisAppModel, child) {
          if(thisAppModel.saveDriverDataLoadingState.loadError == 1) {
            errors.clear();
            if(thisAppModel.saveDriverDataLoadingState.error != null) {
              errors.add(
                  thisAppModel.saveDriverDataLoadingState.error!);
            }
          }
          return Scaffold(
            appBar: AnimatedAppBar(
              translation(context)?.driverInformation ?? 'Driver Information',
              false,
              addPadding: false,
            ),
            floatingActionButton: activeStep == upperBound ?
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: FloatingActionButton(
                onPressed: () {
                  //navigate to AddDocumentScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEditDocumentScreen(thisAppModel)),
                  );
                },
                backgroundColor: AppTheme.darkPrimary,
                child: const Icon(Icons.add),
              ),
            ) : null,
            body: Column(
              children: [
                NumberStepper(
                  numbers: const [
                    1,
                    2,
                  ],
                  numberStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  backgroundColor: AppTheme.darkPrimary,
                  enableNextPreviousButtons: false,
                  activeStepBorderWidth: 2,
                  activeStepBorderColor: AppTheme.primary,
                  activeStep: activeStep,

                  // This ensures step-tapping updates the activeStep.
                  onStepReached: (index) {
                    setState(() {
                      activeStep = index;
                    });
                  },
                ),
                header(),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: wizardBody(thisAppModel),
                    )
                ),
                errors.isNotEmpty ? FormError(errors: errors) : Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      activeStep != 0 ?
                      previousButton(): saveButton(thisAppModel),
                      activeStep == 0 && responseMessage != null && responseMessage!.isNotEmpty ?
                      showMessageButton(responseMessage!) : Container(),
                      nextButton(thisAppModel),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
    );
  }


  /// Returns the next button.
  Widget nextButton(ThisApplicationViewModel thisAppModel) {
    return ElevatedButton(
        onPressed: () {
          // Increment activeStep, when the next button is tapped. However, check for upper bound.
          if (activeStep < upperBound) {
            setState(() {
              errors.clear();
            });
            if (_formKeys[activeStep].currentState == null ||
                _formKeys[activeStep].currentState!.validate()) {
              updateDriverData(thisAppModel);
              setState(() {
                activeStep++;
              });
            }
          }
          else if (activeStep == upperBound) {
            updateDriverData(thisAppModel);
            //call saveDriverDataEndpoint
            thisAppModel.saveDriverDataEndpoint(1);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.darkPrimary,
          alignment: AlignmentDirectional.centerEnd,
        ),
        child: activeStep != upperBound ?
        Align(
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(translation(context)?.next ?? 'Next'),
              Icon(Icons.arrow_forward),
            ],
          ),
        ) :
        (thisAppModel.saveDriverDataLoadingState.inLoading() ?
        const CircularProgressIndicator(
          color: Colors.white,
        ) :
        Align(
          alignment: Alignment.center,
          child: Row(
            children: [
              Text(translation(context)?.submit ?? 'Submit'),
              Icon(Icons.arrow_forward),
            ],
          ),
        ))
    );
  }

  /// Returns the save and exit button.
  Widget saveButton(ThisApplicationViewModel thisAppModel) {
    return activeStep < upperBound ? ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.darkPrimary,
      ),
      onPressed: () {
        setState(() {
          errors.clear();
        });
        if (_formKeys[activeStep].currentState == null || _formKeys[activeStep].currentState!.validate()) {
          // Increment activeStep, when the next button is tapped. However, check for upper bound.
          if (activeStep < upperBound) {
            updateDriverData(thisAppModel);
            //call saveDriverDataEndpoint
            thisAppModel.saveDriverDataEndpoint(0);
          }
        }
      },
      child: thisAppModel.saveDriverDataLoadingState.inLoading() ?
      const CircularProgressIndicator(
        color: Colors.white,
      ) :
      Center(
          child: Text(translation(context)?.save ?? 'Save')
      ),
    ) : Container();
  }

  /// Returns the previous button.
  Widget previousButton() {
    return activeStep == 0 ?
    Container() :
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.darkPrimary,
      ),
      onPressed: () {
        // Decrement activeStep, when the previous button is tapped. However, check for lower bound i.e., must be greater than 0.
        if (activeStep > 0) {
          setState(() {
            activeStep--;
          });
        }
      },
      child: Center(
          child: Text(translation(context)?.previous ?? 'Previous')
      ),
    );
  }

  Widget wizardBody(ThisApplicationViewModel thisAppModel) {
    switch (activeStep) {
      case 0:
        return driverInformation(thisAppModel);

      case 1:
        return legalDocuments(thisAppModel);
    }
    return Container();
  }

  /// Returns the header wrapping the header text.
  Widget header() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              headerText(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Returns the header text based on the activeStep.
  String headerText() {
    switch (activeStep) {
      case 0:
        return translation(context)?.basicInformation ?? 'Basic Information';

      case 1:
        return translation(context)?.legalDocuments ?? 'Legal Documents';

    }
    return '';
  }

  Widget driverInformation(ThisApplicationViewModel thisAppModel) {
    // contains name, address, phone number, email, and password
    return SingleChildScrollView(
      child: Form(
        key: _formKeys[activeStep],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.firstName ?? "First Name",
                  ),
                  validator: (value) {
                    return validateText(value!, translation(context)?.firstName ?? "first name");
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.lastName ?? "Last Name",
                  ),
                  validator: (value) {
                    return validateText(value!, translation(context)?.lastName ?? "last name");
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.address ?? "Address",
                  ),
                  validator: (value) {
                    return validateText(value!, translation(context)?.address ?? "address");
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.email ?? "Email",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    //validate email
                    if (value == null || value.isEmpty) {
                      return translation(context)?.pleaseEnterYourEmail ?? 'Please enter email';
                    }
                    if (!value.contains('@') || !value.contains('.') ||
                        value.length < 5) {
                      return translation(context)?.pleaseEnterValidEmail ?? 'Please enter a valid email';
                    }
                    return null;
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: translation(context)?.phoneNumber ?? "Phone Number",
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  //validate phone number
                  if (value == null || value.isEmpty) {
                    return validateText(value!, translation(context)?.phoneNumber ?? 'phone number');
                  }
                  if (value.length <= 5 || int.tryParse(value) == null) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  controller: _licenseController,
                  decoration: InputDecoration(
                    labelText: translation(context)?.driversLicenseNumber ?? "Driver's License Number",
                  ),
                  validator: (value) {
                    return validateText(value!, translation(context)?.driversLicenseNumber ?? "driver's license number");
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget legalDocuments(ThisApplicationViewModel thisAppModel) {
    // table that contains the legal documents
    return Padding(
      padding: const EdgeInsets.only(bottom: 64.0),
      child: ListView.builder(
          itemCount: thisAppModel.driverData.documents?.length ?? 0,
          itemBuilder: (context, index) {
            return InkWell(
              child: Card(
                child: ListTile(
                  title: Text(
                      thisAppModel.driverData.documents?[index].documentName ??
                          ""),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(thisAppModel.driverData.documents?[index]
                          .documentNumber ?? ""),
                      Text(thisAppModel.driverData.documents?[index]
                          .documentExpiryDate ?? ""),
                    ],
                  ),
                ),
              ),
              onTap: () {
                //open AddEditDocumentScreen with the document data
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditDocumentScreen(
                      thisAppModel,
                      document: thisAppModel.driverData.documents?[index],
                      documentIndex: index,
                    ),
                  ),
                );
              },
            );
          }
      ),
    );
  }

  Widget finalizeAndSubmit() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Vehicle Inspection',
          ),
        ),
      ],
    );
  }

  String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return (translation(context)?.pleaseEnter ?? "Please enter") + " " + fieldName;
    }
    return null;
  }

  void updateDriverData(ThisApplicationViewModel thisAppModel) {
    thisAppModel.driverData.firstName = _firstNameController!.text;
    thisAppModel.driverData.lastName = _lastNameController!.text;
    thisAppModel.driverData.email = _emailController!.text;
    thisAppModel.driverData.phoneNumber = _phoneNumberController!.text;
    thisAppModel.driverData.licenseNumber = _licenseController!.text;
    thisAppModel.driverData.address = _addressController!.text;
  }

  void loadDriverDataToGui(ThisApplicationViewModel thisAppModel) {
    _firstNameController!.text = thisAppModel.driverData.firstName ?? "";
    _lastNameController!.text = thisAppModel.driverData.lastName ?? "";
    _emailController!.text = thisAppModel.driverData.email ?? "";
    _phoneNumberController!.text = thisAppModel.driverData.phoneNumber ?? "";
    _addressController!.text = thisAppModel.driverData.address ?? "";
    _licenseController!.text = thisAppModel.driverData.licenseNumber ?? "";
    responseMessage = thisAppModel.driverData.responseMessage ?? "";
  }

  showMessageButton(String s) {
    //button when clicked show message s
    return ElevatedButton(
      onPressed: () {
        //show dialog with message s
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(translation(context)?.response ?? 'Response'),
              content: Text(s),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(translation(context)?.ok ?? 'OK'),
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        alignment: Alignment.center,
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          children: [
            Text(translation(context)?.response ?? 'Response'),
          ],
        ),
      ),
    );
  }
}