import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:zabor/app_localizations/app_localizations.dart';
import 'package:zabor/constants/constants.dart';
import 'package:zabor/screens/basket_screen_module/taxes_response_model.dart';
import 'package:zabor/screens/food_list_module/cart_model.dart';
import 'package:zabor/screens/order_now_module/order_now_screen.dart';
import 'package:zabor/screens/order_now_module/order_advanced_screen.dart';
import 'package:zabor/screens/food_list_module/menu_response_model.dart';
import 'package:zabor/screens/login_signup/model/model.dart';
import 'package:zabor/constants/app_utils.dart';
import 'dart:convert';

import 'package:zabor/constants/apis.dart';
import 'package:zabor/screens/login_signup/login_signup.dart';
import 'package:zabor/utils/k3webservice.dart';
import 'package:zabor/utils/utils.dart';
import 'package:zabor/screens/order_now_module/food_card_response_model.dart';
import 'package:zabor/screens/order_now_module/food_create_response_model.dart';

class FoodCardConfirm extends StatefulWidget {
  final CartModel cartModel;
  final Tax tax;
  final bool isWithoutLogin;
  const FoodCardConfirm(
      {Key key,
        @required this.cartModel,
        @required this.tax,
        this.isWithoutLogin = false}): super(key: key);
  @override
  _FoodCardConfirmState createState() => _FoodCardConfirmState();
}

class TypeItem {
  TypeItem(this.cardNumber,this.shortNumber,this.icon,this.cardAccount,this.order);
  String cardNumber;
  String shortNumber;
  String cardAccount;
  Icon icon;
  int order;
}

class _FoodCardConfirmState extends State<FoodCardConfirm> {

  bool _isLoading = false;
  final _key = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _ctrlName = TextEditingController();
  TextEditingController _ctrlCardNumber = TextEditingController();

  TypeItem selectedType;
  bool cardNumberType = false;///false:new number:///true: exist card.
  String cardNumber = "";
  String shortNumber = "";
  List<TypeItem> planType = <TypeItem>[
    TypeItem("Tarjeta nueva","Tarjeta nueva", Icon(Icons.android, color: const Color(0xFF167F67)), "Tarjeta nueva", 0),

  ];

  accountValidate(value,name){
    if (value.length == 0) {
      return "Se requiere Dueño de la tarjeta";
      // } else if (!regExp.hasMatch(value)) {
      //   return "Email Invalid";
    } else {
      return null;
    }
  }
  cardValidate(value,name,int count){
    String pattern = count==19?r'(^(?:[+0]9)?[0-9]{19}$)':r'(^(?:[+0]9)?[0-9]{4}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length != count) {
      return 'El número de tarjeta es requerido por ${count} números digitales.';
    }
    else if (!regExp.hasMatch(value)) {
      return 'Entre un número de tarjeta validó';
    }
    else if(count!=19 && value!=selectedType.shortNumber)
      return 'Entre un número de tarjeta validó';
    return null;
  }

  InputDecoration inputBoxDecoration(value){
    return InputDecoration(
        hintText: value,
        contentPadding: EdgeInsets.fromLTRB(10,5, 5, 5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            borderSide: BorderSide.none
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(3.0)),
            borderSide: BorderSide(color: Colors.blue)
        ),
        fillColor: Color(0xfff3f3f4),
        filled: true);
  }

  Future<void> callCardApi()async{
    setState(() {
      _isLoading = true;
    });

    User user = await AppUtils.getUser();

    if (user == null || user.id == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginSignupScreen()));
    } else {
      ApiResponse<FoodCardResponseModel> apiResponse =
      await K3Webservice.postMethod<FoodCardResponseModel>(
          apisToUrls(Apis.getFoodstampCards),
          { "user_id": "${user.id}"},
          null);
      if (apiResponse.error) {
        showSnackBar(_scaffoldKey, apiResponse.message, null);
      } else {
        if(apiResponse.data.data!=null){
          for(var i=0;i<apiResponse.data.data.length;i++){
            print(["cardNumber:",apiResponse.data.data[i].cardNumber]);
            cardNumber = apiResponse.data.data[i].cardNumber;
            shortNumber = apiResponse.data.data[i].cardNumber.split("").sublist(15,19).join("");
            Icon icon = Icon(Icons.android, color: const Color(0xFF167F67));
            String cardAccount = apiResponse.data.data[i].cardAccount;
            int order = 1;
            planType.add(TypeItem(cardNumber, shortNumber, icon, cardAccount, order));
          }
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> goNext()async{
    if(!cardNumberType){
      if (!widget.isWithoutLogin) {
        User user = await AppUtils.getUser();
        dynamic token = await AppUtils.getToken();
        if (user == null || user.id == null) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LoginSignupScreen()));
        } else {
        ApiResponse<FoodCreateResponseModel> apiResponse;
        apiResponse = await K3Webservice.postMethod<FoodCreateResponseModel>(
            apisToUrls(Apis.createFoodstampCard),
            jsonEncode({
              "user_id": user.id,
              "card_account": _ctrlName.text,
              "card_number": _ctrlCardNumber.text
            }),
            {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json"
            });
        if (apiResponse.error) {
          if (apiResponse.message == sessionExpiredText){
            showSnackBar(_scaffoldKey, apiResponse.message, SnackBarAction(label: 'Login', onPressed: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginSignupScreen()));
            }));
            return;
          }
          showSnackBar(_scaffoldKey, apiResponse.message, null);
        } else {
          String paymentMode = "FamilyCart";
          widget.cartModel.stamp_paid = 1;
          String cardNumber = _ctrlCardNumber.text;
          String shortNumber = _ctrlCardNumber.text.split("").sublist(15,19).join("");
          print(["cardNumber:",cardNumber,shortNumber]);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderAdvancedScreen(
                    cardNumber: cardNumber,
                    shortNumber: shortNumber,
                    Payment:paymentMode,
                    cartModel: widget.cartModel,
                    tax: widget.tax,
                    isWithoutLogin: widget.isWithoutLogin,
                  )));
        }
        }
      }
    }
    else{
      String paymentMode = "FamilyCart";
      widget.cartModel.stamp_paid = 1;
      String cardNumber=selectedType.cardNumber;
      String shortNumber = selectedType.shortNumber;
      if(!cardNumberType)
      {cardNumber = _ctrlCardNumber.text;
      shortNumber = _ctrlCardNumber.text.split("").sublist(15,19).join("");}
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => OrderAdvancedScreen(
                cardNumber: cardNumber,
                shortNumber: shortNumber,
                Payment:paymentMode,
                cartModel: widget.cartModel,
                tax: widget.tax,
                isWithoutLogin: widget.isWithoutLogin,
              )));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callCardApi();
    selectedType = planType[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('FoodCardConfirm')),
          backgroundColor: AppColors().kWhiteColor,
          iconTheme: IconThemeData(color: AppColors().kBlackColor),
          textTheme: TextTheme(
            title: TextStyle(
                color: AppColors().kBlackColor,
                fontSize: 20,
                fontWeight: FontWeight.w600),
          ),
        ),
        body: _isLoading ? Center(child: CircularProgressIndicator()) :  SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/foodstamp.png'),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                    key: _key,
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.grey,width: 1)
                          ),
                          child: DropdownButton<TypeItem>(
                            underline: Divider(color: Colors.transparent),
                            dropdownColor: Color(0xffffffff),
                            iconEnabledColor: Colors.black,
                            hint: Text(
                              "Plant Type",
                              style: TextStyle(color: Colors.black),
                            ),
                            value: selectedType,
                            onChanged: (TypeItem Value) {
                              setState(() {
                                selectedType = Value;
                                if(Value != planType[0]){
                                  _ctrlName.text = Value.cardAccount;
                                  cardNumberType = true;
                                }
                                else{
                                  _ctrlName.text = "";
                                  cardNumberType = false;
                                }
                              });
                            },
                            items: planType.map((TypeItem planType) {
                              return DropdownMenuItem<TypeItem>(
                                value: planType,
                                child: Container(
                                  width:MediaQuery.of(context).size.width-46,
                                  child: Row(
                                    children: <Widget>[
                                      //user.icon,
                                      SizedBox(width: 10),
                                      Text(
                                        planType.cardAccount,
                                        style: TextStyle(color: Colors.black, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            child: TextFormField(
                              controller: _ctrlName,
                              validator: (value){
                                return accountValidate(value, "Card account");
                              },
                              decoration: InputDecoration(
                                  labelText: "Nombre de la cuenta",
                                  // labelText: "Account",
                                  // hintText: "Card account",
                                  fillColor: Colors.white,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  contentPadding: EdgeInsets.only(top: 5,bottom: 5,left: 15,right: 15)
                              ),
                              // decoration: inputBoxDecoration("Card account"),
                            )
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            child: TextFormField(
                                controller: _ctrlCardNumber,
                                validator: (value){
                                  if(cardNumberType)
                                  return cardValidate(value, "Card Number",4);
                                  else
                                    return cardValidate(value, "Card Number",19);
                                },
                                decoration: InputDecoration(
                                  // hintText: "Card Number",
                                  labelText: cardNumberType?"Entre los últimos 4 dígitos de la tarjeta de la Familia":"Número de cuenta",
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.only(top: 5,bottom: 5,left: 15,right: 15),
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ))
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        // Container(
                        //   child: ,
                        // )
                      ],
                    )
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
        bottomSheet: _isLoading ? Container() : Container(
          color: Colors.white,
          height: 130,width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 130,height: 50,
                    child: RaisedButton(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey,width: 1),
                          borderRadius: BorderRadius.circular(30)
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        // _showModalOrderFailed(context);
                      },
                      child: Container(
                        height: 50,
                        child: Center(child: Text("Cancel",style: TextStyle(color: Colors.black))),
                      ),
                    ),
                  ),
                  Container(
                    width: 130,height: 50,
                    child: RaisedButton(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      textColor: Colors.white,
                      onPressed: (){
                        FocusScope.of(context).requestFocus(FocusNode());
                        if(_key.currentState.validate()){
                          goNext();
                        }
                        // Navigator.pop(context);
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderConfirmed()));
                      },
                      child: Container(
                        height: 50,
                        child: Center(child: Text("Confirm Order",style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.only(left: 20,right: 20),
                child: Text("Al continuar este número se salvará para futuras compras en su cuenta",textAlign: TextAlign.center),
              )
            ],
          ),
        )
    );
  }
}
