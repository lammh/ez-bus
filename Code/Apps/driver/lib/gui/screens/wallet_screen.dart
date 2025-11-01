
import 'package:ezbusdriver/gui/widgets/tab_choice_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ezbusdriver/services/service_locator.dart';
import 'package:ezbusdriver/utils/app_theme.dart';
import 'package:ezbusdriver/view_models/this_application_view_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';


import '../../utils/tools.dart';
import '../../widgets.dart';
import '../languages/language_constants.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen> {

  ThisApplicationViewModel thisAppModel = serviceLocator<
      ThisApplicationViewModel>();

  PageController? _pageController;
  int? paymentTabIdx=0;

  TabController? _controller;


  @override
  void initState() {
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _refreshData();
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
    return PageView(
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
              child: displayPayments(thisApplicationViewModel, index),
            ),
          );
        })
    );
  }

  Widget displayPayments(ThisApplicationViewModel thisApplicationViewModel, int index) {
    if (thisApplicationViewModel.paymentsLoadingState.inLoading()) {
      return loadingScreen(context);
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
            SizedBox(height: 50.h),
            Image.asset(
              "assets/images/walletImage.png",
              height: 100.h,
            ),
            const SizedBox(height: 30),
            Text(
              translation(context)?.myWalletBalance ?? "My wallet balance ",
              style: const TextStyle(
                color: AppTheme.darkGrey,
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
                    ?.toStringAsFixed(2) ?? ''} ${thisApplicationViewModel.settings?.currencyCode}",
                style: const TextStyle(
                  fontSize: 36,
                  fontFamily: 'Open Sans',
                  fontWeight: FontWeight.w700,
                  color: AppTheme.colorSecondary,
                ),
              ),
            ),
            SizedBox(height: 10.h), //add pay button
          ],
        ));
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
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    Text(translation(context)?.noTransactionsYet ?? "No transactions",
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

  List<Widget> paymentsListScreen(ThisApplicationViewModel thisApplicationViewModel) {
    return
      List.generate(thisApplicationViewModel.payments.length, (i) {
        IconData paymentIcon = thisApplicationViewModel.payments[i].amount! < 0
            ? FontAwesomeIcons.arrowCircleDown
            : FontAwesomeIcons.arrowCircleUp;
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
                paymentIcon,
                color: thisApplicationViewModel.payments[i].amount! >= 0 ? AppTheme.primary : AppTheme.colorSecondary,
                size: 35,
              ),
            ),
            title: Padding(
              padding: EdgeInsets.only(top: 8.0.h),
              child: Text(
                thisApplicationViewModel.payments[i].date.toString(),
                style: AppTheme.textDarkestBlueMedium,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(left: 20.0.w, top: 10.0.h, bottom: 10.0),
              child: Text(
                Tools.formatPrice(thisApplicationViewModel, thisApplicationViewModel.payments[i].amount!),
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
  // List<Widget> paymentsListScreen(ThisApplicationViewModel thisApplicationViewModel) {
  //   return
  //     List.generate(thisApplicationViewModel.payments.length, (i) {
  //       return Card(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.0),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //                 children: [
  //                   Text("Payment Date"),
  //                   Text(thisApplicationViewModel.payments[i].date.toString()),
  //                   SizedBox(height: 10),
  //                   Text("Amount"),
  //                   Text(thisApplicationViewModel.payments[i].amount.toString()),
  //                   SizedBox(height: 10),
  //                 ]
  //             ),
  //           )
  //       );
  //     });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThisApplicationViewModel>(
      builder: (context, thisApplicationViewModel, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Center(
                child: TabChoiceWidget(
                  color: AppTheme.primary,
                  choices: [
                    translation(context)?.balance ?? "Balance",
                    translation(context)?.history ?? "History"
                  ],
                  pageController: _pageController,
                ),
              ),
              SizedBox(
                height: 600.h,
                child: displayAllPayments(thisApplicationViewModel)
              ),
            ],
          ),
        );
      },
    );
  }
}