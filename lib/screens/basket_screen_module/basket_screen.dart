import 'package:flutter/material.dart';
import 'package:zabor/app_localizations/app_localizations.dart';
import 'package:zabor/constants/apis.dart';
import 'package:zabor/constants/app_utils.dart';
import 'package:zabor/constants/constants.dart';
import 'package:zabor/screens/basket_screen_module/taxes_response_model.dart';
import 'package:zabor/screens/food_list_module/cart_model.dart';
import 'package:zabor/screens/food_list_module/menu_response_model.dart';
import 'package:zabor/screens/login_signup/login_signup.dart';
import 'package:zabor/screens/login_signup/model/model.dart';
import 'package:zabor/screens/order_now_module/order_now_screen.dart';
import 'package:zabor/screens/order_now_module/order_mode_screen.dart';
import 'package:zabor/screens/share_feedback/share_feedback_screen.dart';
import 'package:zabor/utils/k3webservice.dart';
import 'package:zabor/utils/utils.dart';
import 'dart:convert';
import 'basket_response_model.dart';
import 'package:zabor/screens/basket_screen_module/clearCart.dart';
import 'package:zabor/constants/apis.dart';

class BasketScreen extends StatefulWidget {
  final CartModel cartModel;
  final bool isFromSettings;
  final bool isWithoutLogin;

  const BasketScreen({Key key,
    this.cartModel,
    @required this.isFromSettings,
    this.isWithoutLogin = false})
      : super(key: key);

  @override
  _BasketScreenState createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  bool _isLoading = false;
  bool _loadingPlaceOrderState = false;
  BasketModel _basketModel;
  Cart _cart;
  CartModel _cartModel;
  bool _isAuthError = false;
  bool _noData = false;
  Tax _tax;

  bool _orderPlaced = false;
  bool _isRestAvailable = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print(
        'widget.cartModel****************************************************************');
    print(jsonEncode(widget.cartModel).toString());
    print(["widget.isWithoutLogin:", widget.isWithoutLogin,"\n",widget.isWithoutLogin]);
    if (widget.isWithoutLogin) {
      _cartModel = widget.cartModel;
      callGetTaxesApi();
    } else {
      // _cartModel = CartModel();
      _cartModel = widget.cartModel;
      callGetTaxesApi();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isAuthError
          ? buildAuthWigdet(context)
          : _noData
          ? buildNoDataWigdet(context)
          : buildBody(),
    );
  }

  Column buildBody() {
    List<Cart> lstCart = _cartModel.cart;
    return Column(children: [
      // SizedBox(
      //   height: 40,
      // ),
      Container(
        height: MediaQuery.of(context).size.height-210,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children:[
              Container(
                height: 60,
                child: TabBar(
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: "Food",),
                    Tab(text: "Non foods"),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height-310,
                child: TabBarView(
                  children: [
                    // Expanded(
                    //     child: ListView.builder(
                    //       itemBuilder: (context, index) =>
                    //       _cartModel.cart[index].is_stamp?
                    //           buildBasketItemRow(index):Container(),
                    //       itemCount: _cartModel.cart.length,
                    //     )),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ...lstCart.asMap().map((key, value) {
                            return MapEntry(key,
                                lstCart[key].is_stamp?
                                buildBasketItemRow(key)
                                :Container());}).values.toList()
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          ...lstCart.asMap().map((key, value) {
                            return MapEntry(key,
                                lstCart[key].is_stamp?
                                Container():buildBasketItemRow(key)
                            );}).values.toList(),
                          buildPriceColumn()
                        ],
                      ),
                    ),
                    // Expanded(
                    //     child: ListView.builder(
                    //       itemBuilder: (context, index) =>
                    //       index == _cartModel.cart.length
                    //           ? buildPriceColumn()
                    //           : _cartModel.cart[index].is_stamp?
                    //             Container():buildBasketItemRow(index),
                    //       itemCount: _cartModel.cart.length + 1,
                    //     )),
                  ],
                ),
              ),
            ]
          ),
        )
      ),
      // Expanded(
      //     child: ListView.builder(
      //       itemBuilder: (context, index) =>
      //       index == _cartModel.cart.length
      //           ? buildPriceColumn()
      //           : buildBasketItemRow(index),
      //       itemCount: _cartModel.cart.length + 1,
      //     )),
      Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FlatButton(
          child: Text(
            // "CONTINUE",
            "Continuar",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            if(calCorePrice()<50)
              showPriceDialog();
            else
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OrderModeScreen(
                          cartModel: _cartModel,
                          tax: _tax,
                          isWithoutLogin: widget.isWithoutLogin,
                        )));
          },
        ),
      ),
      SizedBox(
        height: 10.0,
      ),
      Container(
        width: 300,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FlatButton(
          child: Text(
            // "Clear Cart",
            "Vaciar carrito",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          onPressed: () {
            showAlerDialog();
            // _onSubmit(message) {
            //   if (message.isNotEmpty) {
            //     showDialog(
            //       context: context,
            //       barrierDismissible: false,
            //       builder: (BuildContext context) {
            //         return AlertDialog(
            //           title: Center(child: Text('Alert')),
            //           content: Row(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             children : <Widget>[
            //               Expanded(
            //                 child: Text(
            //                   message,
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                     color: Colors.red,
            //
            //                   ),
            //                 ),
            //               )
            //             ],
            //           ),
            //           actions: <Widget>[
            //             FlatButton(
            //                 child: Text('Cancel'),
            //                 onPressed: () {
            //                   Navigator.of(context).pop();
            //                 }),
            //             FlatButton(
            //                 child: Text('Ok'),
            //                 onPressed: () {
            //                   // _inputTextController.clear();
            //                   Navigator.of(context).pop();
            //                 })
            //           ],
            //         );
            //       },
            //     );
            //   }
            // }
            // showAlertDialog(BuildContext context) {
            //   // set up the button
            //   Widget okButton = FlatButton(
            //     child: Text("OK"),
            //     onPressed: () { },
            //   );
            //   // set up the AlertDialog
            //   AlertDialog alert = AlertDialog(
            //     title: Text("My title"),
            //     content: Text("This is my message."),
            //     actions: [
            //       okButton,
            //     ],
            //   );
            //   // show the dialog
            //   showDialog(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return alert;
            //     },
            //   );
            // }
            //   AlertDialog(
            //   title: Text('Alert Dialog Title Text.'),
            //   content: Text("Are You Sure Want To Delet Cart ?"),
            //   actions: <Widget>[
            //     FlatButton(
            //       child: Text("YES"),
            //       onPressed: () {
            //         //Put your code here which you want to execute on Yes button click.
            //         Navigator.pushReplacement(context,
            //             MaterialPageRoute(builder: (context) => ClearCart()));
            //       },
            //     ),
            //
            //     FlatButton(
            //       child: Text("NO"),
            //       onPressed: () {
            //         //Put your code here which you want to execute on No button click.
            //         Navigator.of(context).pop();
            //       },
            //     ),
            //
            //     FlatButton(
            //       child: Text("CANCEL"),
            //       onPressed: () {
            //         //Put your code here which you want to execute on Cancel button click.
            //         Navigator.of(context).pop();
            //       },
            //     ),
            //   ],
            // );
            //
            // Navigator.pushReplacement(context,
            //     MaterialPageRoute(builder: (context) => ClearCart()));
            setState(() async {
              // setState(() {
              //   _loadingPlaceOrderState = true;
              //   setState(() {
              //     _orderPlaced = true;
              //   });
              // });

              dynamic token = await AppUtils.getToken();
              User user = await AppUtils.getUser();
              ApiResponse<CommonResponseModel> apiResponse =
              await K3Webservice.getMethod(
                  apisToUrls(Apis.clearCart) + '?user_id=${user.id}', {
                "Authorization": "Bearer $token",
                "Content-Type": "application/json"
              });
              setState(() {
                _loadingPlaceOrderState = false;
              });

              if (apiResponse.error) {
                showSnackBar(_scaffoldKey, apiResponse.message, null);
                if (apiResponse.message == sessionExpiredText) {
                  setState(() {
                    _isAuthError = true;
                  });
                }
                return;
              } else {}
            });
          },
        ),
      ),
      SizedBox(
        height: 15,
      )
    ]);
  }

  Widget buildPriceColumn() =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${(_cartModel.getTotal() -
                      (_cartModel.getCityTax() + _cartModel.getStateTax()))
                      .toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '+ City Tax',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  '\$${_cartModel.getCityTax().toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '+ State Tax',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                Text(
                  '\$${_cartModel.getStateTax().toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('Payable amount'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${_cartModel.getTotal().toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ]),
        ),
      );

  Widget buildBasketItemRow(int index) {
    return GestureDetector(
      onTap: widget.isFromSettings ? null : () => {Navigator.pop(context)},
      child: Container(
        color: Colors.indigo[50],
        child: Padding(
          padding:
          const EdgeInsets.only(top: 12, bottom: 0, left: 16, right: 8),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                    spreadRadius: 3)
                              ],
                              borderRadius: BorderRadius.circular(5)),
                          child: Center(
                              child: Text(
                                '${_cartModel.cart[index].quantity}x',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _cartModel.cart[index].itemName,
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(width: 10),
                              Text(
                                '\$ ${_cartModel.cart[index]
                                    .itemPrice} ${_cartModel.cart[index]
                                    .customization == null
                                    ? ''
                                    : 'Customized'}',
                                style:
                                TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  widget.isFromSettings ? Container() : buildIncDecButton(index)
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Divider()
            ],
          ),
        ),
      ),
    );
  }

  IconButton buildIconButton() {
    return IconButton(
        icon: Container(
          child: Icon(
            Icons.mode_edit,
            size: 14,
          ),
          decoration:
          BoxDecoration(border: Border.all(color: Colors.grey, width: 2)),
        ),
        onPressed: null);
  }

  AppBar buildAppBar() {
    print(["_cartModel.getTotal():",_cartModel.getTotal()]);
    print(["_cartModel.getTotal():",_cartModel.getCityTax()]);
    print(["_cartModel.getTotal():",_cartModel.getStateTax()]);
    return AppBar(
      title: Text(
        // AppLocalizations.of(context).translate('YOUR BASKET'),
        "Tú carrito"
      ),
      actions: [
        Icon(
          Icons.shopping_cart_rounded,
          size: 30,
        ),
        Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  '\$${(_cartModel.getTotal() -
                      (_cartModel.getCityTax() + _cartModel.getStateTax())).toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
            )),
        SizedBox(
          width: 10,
        ),
      ],
      backgroundColor: AppColors().kWhiteColor,
      iconTheme: IconThemeData(color: AppColors().kBlackColor),
      textTheme: TextTheme(
          title: TextStyle(
              color: AppColors().kBlackColor,
              fontSize: 20,
              fontWeight: FontWeight.w600)),
    );
  }

  Future<void> callBasketApi() async {
    if (widget.isWithoutLogin) {
      setState(() {});
      return;
    }

    setState(() {
      _isLoading = true;
      _isAuthError = false;
    });
    dynamic token = await AppUtils.getToken();
    User user = await AppUtils.getUser();
    ApiResponse<BasketResponseModel> apiResponse = await K3Webservice.getMethod(
        apisToUrls(Apis.myBasket) + '?user_id=${user.id}',
        {"Authorization": "Bearer $token", "Content-Type": "application/json"});
    setState(() {
      _isLoading = false;
    });
    if (apiResponse.error) {
      showSnackBar(_scaffoldKey, apiResponse.message, null);
      if (apiResponse.message == sessionExpiredText) {
        setState(() {
          _isAuthError = true;
        });
      }
      return;
    } else {
      setState(() {
        _basketModel = apiResponse.data.data;
        print(["_basketModel----------apiResponse:",_basketModel.toJson()]);
        if (apiResponse.data.data == null) {
          _noData = true;
          return;
        }

        _isRestAvailable = checkifResAvailable(apiResponse.data.data.toJson());
        final cart = json.decode(_basketModel.cart);
        print(cart);
        List<Cart> tempCartList = [];
        for (int i = 0; i < cart.length; i++) {
          tempCartList.add(cartModelfromJson(cart[i]));
        }
        _cartModel.id = _basketModel.id;
        _cartModel.cart = tempCartList;
        _cartModel.longitude = _basketModel.longitude;
        _cartModel.latitude = _basketModel.latitude;
        // _cartModel.drinkTax = 0.0;
        // _cartModel.foodTax = 0.0;
        // _cartModel.cityTax = double.parse(_basketModel.cityTax.toString());
        // _cartModel.stateTax = double.parse(_basketModel.stateTax.toString());
        _cartModel.resId = _basketModel.resId;
        // _cartModel.subtotal = _basketModel.total;
        // _cartModel.tax = _basketModel.tax ?? 0.0;
        // _cartModel.total = _basketModel.total;
        _cartModel.userId = _basketModel.userId;
        _cartModel.cod = _basketModel.cod;
        print(_cartModel.cart.first.itemName);
      });
    }
  }

  callGetTaxesApi() async {
    setState(() {
      _isLoading = true;
      _isAuthError = false;
    });

    ApiResponse<TaxesResponseModel> apiResponse =
    await K3Webservice.getMethod(apisToUrls(Apis.getTaxes), null);
    setState(() {
      _isLoading = false;
    });

    if (apiResponse.error) {
      showSnackBar(_scaffoldKey, apiResponse.message, null);
      if (apiResponse.message == sessionExpiredText) {
        setState(() {
          _isAuthError = true;
        });
      }
      return;
    } else {
      _tax = apiResponse.data.data;
      print(["_tax---------apiResponse:",_tax.toJson()]);
      callBasketApi();
    }
  }

  cartModelfromJson(Map<String, dynamic> json) =>
      Cart(
        itemId: json["itemId"] == null ? null : json["itemId"],
        itemName: json["itemName"] == null ? null : json["itemName"],
        itemPrice:
        json["itemPrice"] == null ? null : json["itemPrice"].toDouble(),
        cityTax: json["city_tax"] == null ? null : json["city_tax"].toDouble(),
        stateTax:
        json["state_tax"] == null ? null : json["state_tax"].toDouble(),
        customization: json["customization"] == null
            ? null
            : List<CartCustomization>.from(json["customization"]
            .map((x) => CartCustomization.fromJson(x))),
        quantity: json["quantity"] == null ? null : json["quantity"],
        min_qty: json["min_qty"] == null ? null : json["min_qty"],
        is_stamp: json["is_stamp"] == null ? null : json["is_stamp"],
        taxtype: json["taxtype"] == null ? null : json["taxtype"],
        taxvalue: json["taxvalue"] == null ? null : json["taxvalue"].toDouble(),
        customQunatity: json["custom_qua"] == null ? null : json["custom_qua"],
        citytaxvalue: double.tryParse(_tax.cityTax) == null
            ? null
            : double.tryParse(_tax.cityTax),
        statetaxvalue: double.tryParse(_tax.stateTax) == null
            ? null
            : double.tryParse(_tax.stateTax),
      );

  Widget buildAuthWigdet(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => LoginSignupScreen()));
        callBasketApi();
      },
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error,
              color: AppColors().kPrimaryColor,
              size: 50,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              sessionExpiredText,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Widget buildNoDataWigdet(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
      },
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.shopping_basket,
              color: AppColors().kPrimaryColor,
              size: 150,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "No item added to the basket.",
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  bool checkifResAvailable(Map<String, dynamic> value) {
    var days = ['mon', 'tue', 'wed ', 'thu', 'fri', 'sat', 'sun'];
    var d = DateTime.now();
    var day = days[d.weekday - 1];
    //get open and close time of day of restaurant

    if (value[day + 'open_time'] == null && value[day + 'close_time'] == null) {
      return false;
    }

    if (value[day + 'open_time'] != '' && value[day + 'close_time'] != '') {
      if (d.compareTo(DateTime(
          d.year,
          d.month,
          d.day,
          int.parse(value[day + 'open_time'].split(':')[0]),
          int.parse(value[day + 'open_time'].split(':')[1]))) >
          0 &&
          d.compareTo(DateTime(
              d.year,
              d.month,
              d.day,
              int.parse(value[day + 'close_time'].split(':')[0]),
              int.parse(value[day + 'close_time'].split(':')[1]))) <
              0) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  convertDateFromString(String strDate) {
    DateTime todayDate = DateTime.parse(strDate);
    print(todayDate);
  }

  Opacity buildIncDecButton(int index) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        decoration: BoxDecoration(
            color: AppColors().kPrimaryColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: AppColors().kBlackColor54,
                  blurRadius: 5,
                  spreadRadius: 0.5)
            ]),
        child: Column(children: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _increaseQunatity(index);
            },
          ),
          Text(_cartModel.cart[index].quantity.toString()),
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              _decreaseQunatity(index);
            },
          )
        ]),
      ),
    );
  }

  _increaseQunatity(int index) {
    if (_cartModel.cart[index].customQunatity == 1) {
      if (_cartModel.cart[index].quantity == 0) {
        _cartModel.cart[index].quantity += 1;
      } else {
        _cartModel.cart[index].quantity += 0.25;
      }
    } else {
      _cartModel.cart[index].quantity += 1;
    }
    setState(() {});
    // _calculateAmount();
  }

  _decreaseQunatity(int index) {
    if (_cartModel.cart[index].quantity <= _cartModel.cart[index].min_qty) {
      _cartModel.cart.removeAt(index);
    } else {
      if (_cartModel.cart[index].customQunatity == 1) {
        if (_cartModel.cart[index].quantity == 1) {
          _cartModel.cart[index].quantity -= 1;
        } else {
          _cartModel.cart[index].quantity -= 0.25;
        }
      } else {
        _cartModel.cart[index].quantity -= 1;
      }
    }
    setState(() {});
    // _calculateAmount();
  }

  showAlerDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Cart'),
            content: Text("Sure Want to delete"),
            actions: [
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ClearCart(),),
                  );
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  double calCorePrice(){
    double sum = 0.0;
    for(var i=0;i<_cartModel.cart.length;i++){
      sum += _cartModel.cart[i].itemPrice*_cartModel.cart[i].quantity;
    }
    return sum;
  }
  showPriceDialog() {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: Text('Limit Price'),
            content: Text("Total price without tax has to be more than \$50",textAlign: TextAlign.center,),
            actions: [
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ClearCart(),),
                  // );
                },
              ),
            ],
          );
        });
  }
}
