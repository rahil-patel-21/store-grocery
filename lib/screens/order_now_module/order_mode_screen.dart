import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:zabor/app_localizations/app_localizations.dart';
import 'package:zabor/constants/constants.dart';
import 'package:zabor/screens/basket_screen_module/taxes_response_model.dart';
import 'package:zabor/screens/food_list_module/cart_model.dart';
import 'package:zabor/screens/order_now_module/order_now_screen.dart';
import 'package:zabor/screens/order_now_module/order_advanced_screen.dart';
import 'package:zabor/screens/order_now_module/food_card_confirm.dart';

class OrderModeScreen extends StatefulWidget {
  final CartModel cartModel;
  final Tax tax;
  final bool isWithoutLogin;

  const OrderModeScreen(
      {Key key,
      @required this.cartModel,
      @required this.tax,
      this.isWithoutLogin = false})
      : super(key: key);

  @override
  _OrderModeScreenState createState() => _OrderModeScreenState();
}

class _OrderModeScreenState extends State<OrderModeScreen> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  String deliverString = 'Deliver at home';
  String pickupString = 'Pickup from store';
  String paymentMode;

  List<String> arrPaymentOptions = [];

  @override
  void initState() {
    super.initState();
    // setPaymentOptions();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: 500,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>FoodCardConfirm(
                            cartModel: widget.cartModel,tax: widget.tax,isWithoutLogin: widget.isWithoutLogin,
                          )));
                      // paymentMode = "FamilyCart";
                      // widget.cartModel.stamp_paid = 1;
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => OrderAdvancedScreen(
                      //           Payment:paymentMode,
                      //           cartModel: widget.cartModel,
                      //           tax: widget.tax,
                      //           isWithoutLogin: widget.isWithoutLogin,
                      //         )));
                    },
                    child: Container(
                      width: 200,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/foodstamp.png'),
                            fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      paymentMode = "MasterCard";
                      widget.cartModel.stamp_paid = 0;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderNowScreen(
                                paymentMode:paymentMode,
                                    cartModel: widget.cartModel,
                                    tax: widget.tax,
                                    isWithoutLogin: widget.isWithoutLogin,
                                  )));
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 320,
                          height: 100,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/images/ath logo.png'),
                                fit: BoxFit.cover),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  )
                ]),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        // AppLocalizations.of(context).translate('ORDER MODE'),
        "Modo de pago"
      ),
      backgroundColor: AppColors().kWhiteColor,
      iconTheme: IconThemeData(color: AppColors().kBlackColor),
      textTheme: TextTheme(
        title: TextStyle(
            color: AppColors().kBlackColor,
            fontSize: 20,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
