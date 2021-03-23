import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zabor/app_localizations/app_localizations.dart';
import 'package:zabor/constants/apis.dart';
import 'package:zabor/constants/app_utils.dart';
import 'package:zabor/constants/constants.dart';
import 'package:zabor/screens/food_list_module/menu_response_model.dart';
import 'package:zabor/screens/login_signup/login_signup.dart';
import 'package:zabor/screens/login_signup/model/model.dart';
import 'package:zabor/screens/share_feedback/share_feedback_screen.dart';
import 'package:zabor/utils/k3webservice.dart';
import 'package:zabor/utils/utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
// import 'package:http/http.dart' as http;
import 'package:expandable/expandable.dart';
import 'package:zabor/screens/basket_screen_module/clearCart.dart';

import 'cart_model.dart';
import 'food_list_provider.dart';

class FoodListScreen extends StatefulWidget {
  final String restName;
  final int restId;

  const FoodListScreen(
      {Key key, @required this.restName, @required this.restId})
      : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  bool _isLoading = false;
  // List<ItemHeader> _itemHeaders = [];
  List<ItemCountHeader> _itemHeaders = [];
  // List<ItemHeader> _itemHeadersFull = [];
  List<ItemCountHeader> _itemHeadersFull = [];
  List<Customization> _customizations = [];
  Set<String> _itemCats = Set<String>();
  MenuQtyModel _menuQtyModel;
  List<Cart> _arrCartItem = [];
  List<CartCustomization> _arrCartCustomization = [];
  FoodListProvider foodListprovider;
  MenulResponseModel _menulResponseModel;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double totalPrice = 0.0;
  String headerImageUrl = null;
  int selectedCategory=0;

  @override
  void initState() {
    super.initState();
    _menuQtyModel = MenuQtyModel();
    callMenuApi();
  }

  @override
  void dispose() {
    super.dispose();
    foodListprovider.cartModel = CartModel();
    foodListprovider.isLoading = false;
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
                  Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    foodListprovider = Provider.of<FoodListProvider>(context, listen: false);
    foodListprovider.cartModel.resId = widget.restId;
    return Scaffold(
      key: _scaffoldKey,
      appBar: buildAppBar(),
      body:
      _isLoading ? Center(child: CircularProgressIndicator()) : buildBody(),
    );
  }

  Padding buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 10),
          buildCategoryContainer(),
          GestureDetector(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
            child: Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                    color: AppColors().kGreyColor100,
                    border:
                    Border.all(color: AppColors().kGreyColor200, width: 1),
                    borderRadius: BorderRadius.circular(40)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        // GestureDetector(
                        //   child: Image.asset('assets/images/gps.png'),
                        //   onTap: () {},
                        // ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    Container(
                      child: Expanded(
                          child: TextField(
                            onChanged: (text) {
                              searchViaGroup(text);
                            },
                            onSubmitted: (text) {
                              searchViaGroup(text);
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: AppLocalizations.of(context)
                                    .translate('Search here...')),
                          )),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      color: AppColors().kPrimaryColor,
                      onPressed: () {
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: getHeaders(),
            ),
          ),
          Consumer<FoodListProvider>(
            builder: (context, flp, child) => flp.isLoading
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            )
                : ButtonWidget(
              // title:AppLocalizations.of(context).translate('VIEW BASKET'),
              title:("Ver carrito"),
              onPressed: () {
                _addToCartPressed();
              },
            ),
          ),
        ],
      ),
    );
  }

  double calculateTotalItemPrice() {
    double price = 0.0;
    for (int i = 0; i < _arrCartItem.length; i++) {
      price += (_arrCartItem[i].itemPrice * _arrCartItem[i].quantity);
    }
    return price;
  }

  Container buildCategoryContainer() {
    return Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _itemHeadersFull.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                selectedCategory = index;
                sortViaGroup(index);

                //sortViaCategory(_itemCats.toList()[index]);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: AppColors().kPrimaryColor,
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: Text(_itemHeadersFull[index].name.toString(),
                          style: TextStyle(color: AppColors().kWhiteColor)),
                    )),
              ),
            )));
  }

  _addToCartPressed() async {
    User userModel = await AppUtils.getUser();
    if (foodListprovider.cartModel.cart == null ||
        foodListprovider.cartModel.cart.length == 0) return;
    if (userModel == null || userModel.id == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginSignupScreen()));
    } else {
      print(["_menulResponseModel.taxes.grandTax:",_menulResponseModel.taxes.grandTax]);
      foodListprovider.cartModel.userId = userModel.id;
      foodListprovider.cartModel.appendTax = double.parse(_menulResponseModel.taxes.grandTax);
      foodListprovider.callAddToCartApi(_scaffoldKey, context, false);
    }
  }

  List<Widget> getHeaders() {
    List<Widget> arr = [];
    for (int i = 0; i < _itemCats.length; i++) {
      arr.add(buildItemHeader(i));
    }
    return arr;
  }

  List<Widget> getCustomizationHeaders(
      List<Customization> customizations, int itemId) {
    List<Widget> arr = [];
    for (int i = 0; i < customizations.length; i++) {
      arr.add(buildCustomizationHeader(i, customizations, itemId));
    }
    return arr;
  }

  List<Widget> getItems(int index) {
    List<Widget> arr = [];
    for (int i = 0; i < _itemHeaders[index].items.length; i++) {
      arr.add(buildFoodItemRow(index, i));
    }
    return arr;
  }

  List<Widget> getCustomizationItems(
      int index, List<Customization> customizations, int itemId) {
    List<Widget> arr = [];
    for (int i = 0; i < customizations[index].items.length; i++) {
      arr.add(buildCustomizationItem(index, i, customizations, itemId));
    }
    return arr;
  }

  Widget buildItemHeader(int index) {
    return Container(
      child: ExpandableNotifier(
        child: ScrollOnExpand(
          scrollOnCollapse: false,
          scrollOnExpand: true,
          child: ExpandablePanel(
            header: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(padding: EdgeInsets.only(left: 10),
                        child: Text(
                          _itemCats.toList()[index].toString(),
                          //_itemHeaders[index].name,
                          style: TextStyle(
                            // color: Colors.red,
                              color: AppColors().kBlackColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),),
                    ),
                    Text(
                      '',
                      style: TextStyle(
                        color: Colors.red,
                        // color: AppColors().kGrey,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
            expanded: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.only(bottom: 20),
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 0.4,
                children: new List<Widget>.generate(
                    _itemHeaders[index].items.length, (ind) {
                  return buildFoodItemRow(index, ind);
                }),
              ),
            ),
            builder: (_, collapsed, expanded) {
              return Padding(
                padding: EdgeInsets.only(
                    left: 10, right: 10, bottom: 10),
                child: Expandable(
                  collapsed: collapsed,
                  expanded: expanded,
                  theme: const ExpandableThemeData(
                      crossFadePoint: 0),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildCustomizationHeader(
      int index, List<Customization> customizations, int itemId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            customizations[index].name,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 10),
        Column(children: getCustomizationItems(index, customizations, itemId))
      ],
    );
  }

  Widget buildCustomizationItem(int outerIndex, int innerIndex,
      List<Customization> customizations, int itemId) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer<FoodListProvider>(
        builder: (context, flistProvider, child) => ListTile(
            leading: Image.asset(
              flistProvider.isCustomizationExists(itemId,
                  _customizations[outerIndex].items[innerIndex].ciId)
                  ? 'assets/images/3.0x/check.png'
                  : 'assets/images/3.0x/uncheck.png',
              height: 22,
            ),
            title: new Text(
                customizations[outerIndex].items[innerIndex].optionName),
            trailing: Text(
                '\$${customizations[outerIndex].items[innerIndex].optionPrice}'),
            onTap: () => {
              flistProvider.isCustomizationExists(itemId,
                  _customizations[outerIndex].items[innerIndex].ciId)
                  ? removeCartCustomization(outerIndex, innerIndex, itemId)
                  : addItemToCartCustomizationArray(
                  outerIndex, innerIndex, itemId)
            }),
      ),
    );
  }

  Widget buildFoodItemRow(int outerIndex, int innerIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _itemHeaders[outerIndex].items[innerIndex].sp == null
              ? Container(
            width: MediaQuery.of(context).size.width / 5,
            child: Row(children: <Widget>[
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ImageDialog(
                                imgUrl: baseUrl +
                                    (_itemHeaders[outerIndex]
                                        .items[innerIndex]
                                        .itemPic ==
                                        null
                                        ? ""
                                        : _itemHeaders[outerIndex]
                                        .items[innerIndex]
                                        .itemPic),
                                name: _itemHeaders[outerIndex]
                                    .items[innerIndex]
                                    .itemName ??
                                    "",
                                description: _itemHeaders[outerIndex]
                                    .items[innerIndex]
                                    .itemDes ??
                                    ""));
                      },
                      child: CachedNetworkImage(
                          imageUrl: baseUrl +
                              (_itemHeaders[outerIndex].items[innerIndex].itemPic == null
                                  ? "": _itemHeaders[outerIndex].items[innerIndex].itemPic),
                          imageBuilder: (context, imageProvider) =>
                              Container(
                                  width: double.infinity,
                                  height:
                                  MediaQuery.of(context).size.width / 4,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  child: (Container(
                                      width: 10,
                                      height: 10,
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _itemHeaders[outerIndex].items[innerIndex].is_stamp
                                                ? (Image.asset(
                                                'assets/images/foodstamp.png',
                                                width: 30,
                                                height: 30))
                                                : Container()
                                          ])))),
                          placeholder: (context, url) => Container(
                              width: double.infinity,
                              height:
                              MediaQuery.of(context).size.width / 4,
                              child: Center(
                                  child: CircularProgressIndicator())),
                          errorWidget: (context, url, error) => Container(
                              width: double.infinity,
                              height:
                              MediaQuery.of(context).size.width / 4,
                              decoration: new BoxDecoration(
                                image: new DecorationImage(
                                  image: new AssetImage(
                                      'assets/images/dish_placeholder.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                              child: (Container(
                                  width: 10,
                                  height: 10,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    _itemHeaders[outerIndex]
                                        .items[innerIndex]
                                        .is_stamp
                                        ? (Image.asset(
                                        'assets/images/foodstamp.png',
                                        width: 30,
                                        height: 30))
                                        : Container()
                                  ]))))),
                    ),
                    Text(
                        _itemHeaders[outerIndex]
                            .items[innerIndex]
                            .itemName ??
                            "",
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 2),
                  ],
                ),
              ),
              SizedBox(width: 0),
              Container()
            ]),
          )
              : Banner(
            message: 'Special',
            location: BannerLocation.topEnd,
            child: Container(
              width: MediaQuery.of(context).size.width / 5,
              // width: 400,
              child: Row(children: <Widget>[
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (_) => ImageDialog(
                                  imgUrl: baseUrl +
                                      (_itemHeaders[outerIndex].items[innerIndex].itemPic == null
                                          ? "" : _itemHeaders[outerIndex].items[innerIndex].itemPic),
                                  name: _itemHeaders[outerIndex].items[innerIndex].itemName ?? "",
                                  description: _itemHeaders[outerIndex].items[innerIndex].itemDes ?? ""));
                        },
                        child: CachedNetworkImage(
                            imageUrl: baseUrl +
                                (_itemHeaders[outerIndex].items[innerIndex].itemPic == null
                                    ? "" : _itemHeaders[outerIndex].items[innerIndex].itemPic),
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.width / 4,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) => Container(
                                width: double.infinity,
                                height:
                                MediaQuery.of(context).size.width / 4,
                                child: Center(
                                    child: CircularProgressIndicator())),
                            errorWidget: (context, url, error) =>
                                Image.asset(
                                  'assets/images/dish_placeholder.png',
                                  width: double.infinity,
                                  height:
                                  MediaQuery.of(context).size.width /
                                      3,
                                  fit: BoxFit.contain,
                                )),
                      ),
                      Text(
                          _itemHeaders[outerIndex]
                              .items[innerIndex]
                              .itemName ??
                              "",
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                          maxLines: 2),
                    ],
                  ),
                ),
                SizedBox(width: 0),
                Container()
              ]),
            ),
          ),
          RichText(
            text: new TextSpan(
              text: '',
              children: <TextSpan>[
                new TextSpan(
                  text: _itemHeaders[outerIndex].items[innerIndex].sp == null
                      ? ''
                      : '\$${double.parse(_itemHeaders[outerIndex].items[innerIndex].itemPrice.toString()).toStringAsFixed(2) ?? 0.0}',
                  style: new TextStyle(
                    color: AppColors().kGrey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                new TextSpan(
                  text: _itemHeaders[outerIndex].items[innerIndex].sp == null
                      ? '\$${double.parse(_itemHeaders[outerIndex].items[innerIndex].itemPrice.toString()).toStringAsFixed(2) ?? 0.0}'
                      : ' \$${double.parse(_itemHeaders[outerIndex].items[innerIndex].sp.toString()).toStringAsFixed(2) ?? 0.0}',
                  style: new TextStyle(color: Colors.red, fontSize: 14),
                )
              ],
            ),
          ),
          Container(
            // alignment: Alignment.center,
            child: Text("${_itemHeaders[outerIndex].items[innerIndex].itemDes}",
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,fontSize: 14),),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Text((_itemHeaders[outerIndex].items[innerIndex].itemQuantity ==
                //             null ||
                //         int.parse((_itemHeaders[outerIndex]
                //                             .items[innerIndex]
                //                             .itemQuantity ==
                //                         "null" ||
                //                     _itemHeaders[outerIndex]
                //                             .items[innerIndex]
                //                             .itemQuantity ==
                //                         "")
                //                 ? "0"
                //                 : _itemHeaders[outerIndex]
                //                     .items[innerIndex]
                //                     .itemQuantity
                //                     .toString()) ==
                //             0)
                //     ? 'Out of Stock'
                //     : '${_itemHeaders[outerIndex].items[innerIndex].itemQuantity} in Stock'),
                // InkWell(
                //   onTap: () {
                //     List<String> arrIntCustomization = _itemHeaders[outerIndex]
                //         .items[innerIndex]
                //         .customizations
                //         .toString()
                //         .split(',')
                //         .toList();
                //     List<Customization> arrItemCustomization = [];
                //     for (int i = 0; i < _customizations.length; i++) {
                //       for (int j = 0; j < arrIntCustomization.length; j++)
                //         if ("${_customizations[i].cusid}" ==
                //             arrIntCustomization[j]) {
                //           arrItemCustomization.add(_customizations[i]);
                //         }
                //     }
                //     _settingModalBottomSheet(
                //         context,
                //         outerIndex,
                //         innerIndex,
                //         arrItemCustomization,
                //         getCustomizationHeaders(arrItemCustomization,
                //             _itemHeaders[outerIndex].items[innerIndex].itemId));
                //   },
                //   child: Text(
                //     (_itemHeaders[outerIndex].items[innerIndex].customizations == null ||
                //         _itemHeaders[outerIndex].items[innerIndex].customizations == "null" ||
                //         _itemHeaders[outerIndex].items[innerIndex].customizations == "")
                //         ? 'test' : 'Customizable',
                //     style: TextStyle(
                //       color: AppColors().kGrey,
                //       fontSize: 11,
                //     ),
                //   ),
                // ),///"test" or "customize" text
                Container(
                  // color: Colors.red,
                    padding: EdgeInsets.all(1),
                    child: Column(children: <Widget>[
                      IconButton(
                          padding : EdgeInsets.all(1.0),
                          icon: Icon(
                            _itemHeaders[outerIndex].items[innerIndex].is_fav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.lightBlue,
                            size: 30,
                          ),
                          color: Colors.lightBlue,
                          iconSize: 30,
                          onPressed: () => {
                            this.toggleFavorite(
                                _itemHeaders[outerIndex].items[innerIndex])
                          })
                    ])),///select favourite product
                // SizedBox(height: 0),
                buildIncDecrContainer(outerIndex, innerIndex)
              ]),
        ],
      ),
    );
  }

  Widget buildIncDecrContainer(int outerIndex, int innerIndex) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ]
      ),
      width: MediaQuery.of(context).size.width/4,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: (){
              if(_itemHeaders[outerIndex].items[innerIndex].selectedCount>0)
                setState(() {
                  removeItemFromCartArray(
                      outerIndex,
                      innerIndex,
                      _itemHeaders[outerIndex].items[innerIndex].itemId);
                  totalPrice = calculateTotalItemPrice();
                });
            },
            child: Container(
              child: Icon(Icons.remove,size: 20,color: Colors.black),
            ),
          ),
          Container(
            // child: Text("add"),
            child: Text("${_itemHeaders[outerIndex].items[innerIndex].selectedCount}"),
          ),
          InkWell(
            onTap:(){
              setState(() {
                addItemToCartArray(
                  outerIndex,
                  innerIndex,
                  _itemHeaders[outerIndex].items[innerIndex].min_qty,
                  // _arrCartItem.length + 1,
                  _itemHeaders[outerIndex].items[innerIndex].itemId,
                  _itemHeaders[outerIndex].items[innerIndex].is_stamp,
                );
                totalPrice = calculateTotalItemPrice();
              });
            },
            child: Container(
              child: Icon(Icons.add,size: 20,color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(
        widget.restName,
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: (){
          showAlerDialog();
          // Navigator.pop(context);
        },
      ),
      backgroundColor: AppColors().kWhiteColor,
      iconTheme: IconThemeData(color: AppColors().kBlackColor),
      textTheme: TextTheme(
          title: TextStyle(
              color: AppColors().kBlackColor,
              fontSize: 20,
              fontWeight: FontWeight.w600)),
      actions: [
        Icon(Icons.shopping_cart),
        Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: AppColors().kBlackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)
              ),
            )
        )
      ],
    );
  }

  Future<void> callMenuApi() async {
    setState(() {
      _isLoading = true;
    });

    User user = await AppUtils.getUser();

    if (user == null || user.id == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginSignupScreen()));
    } else {
      ApiResponse<MenulResponseModel> apiResponse =
      await K3Webservice.postMethod<MenulResponseModel>(
          apisToUrls(Apis.menu),
          {"res_id": "${widget.restId}", "user_id": "${user.id}"},
          null);
      setState(() {
        _isLoading = false;
      });
      if (apiResponse.error) {
        showSnackBar(_scaffoldKey, apiResponse.message, null);
      } else {
        // setState(() {
        _menulResponseModel = apiResponse.data;
        // _itemHeaders = apiResponse.data.data;

        // _itemHeadersFull = apiResponse.data.data;
        for(var i=0;i<apiResponse.data.data.length;i++){
          ItemCountHeader tmpData = ItemCountHeader.fromJson(apiResponse.data.data[i].toJson());
          _itemHeadersFull.add(tmpData);
          _itemHeaders.add(tmpData);
        }
        if (_itemHeaders == null || _itemHeaders.isEmpty) return;
        _itemCats = Set<String>();
        _itemCats.add('All');
        _customizations = apiResponse.data.customizations;
        for (int i = 0; i < _customizations.length; i++) {
          List<CheckUncheckCustomizationInnerModel>
          checkUncheckCustomizationInnerModel = [];
          for (int j = 0; j < _customizations[i].items.length; j++) {
            checkUncheckCustomizationInnerModel
                .add(CheckUncheckCustomizationInnerModel(isExits: false));
          }
          foodListprovider.addData(CheckUncheckCustomizationOuterModel(
              id: _customizations[i].cusid,
              checkUncheckCustomizationInnerModel:
              checkUncheckCustomizationInnerModel));
        }
        List<FoodGroup> arrFoodGroup = [];
        for (int i = 1; i < _itemHeaders.length; i++) {
          List<ItemQtyModel> arrItemQtyModel = [];
          for (int j = 0; j < _itemHeaders[i].items.length; j++) {
            arrItemQtyModel.add(
                ItemQtyModel(itemId: _itemHeaders[i].items[j].itemId, qty: 0));
            _itemCats.add(_itemHeaders[i].items[j].itemCat.toString());
          }
          arrFoodGroup.add(FoodGroup(
              groupID: _itemHeaders[i].groupid, itemQtyModel: arrItemQtyModel));
        }
        _menuQtyModel.foodGroup = arrFoodGroup;
        if (_itemHeadersFull.isNotEmpty) sortViaGroup(selectedCategory);
        // });
      }
    }
  }

  void _settingModalBottomSheet(context, int outerIndex, int innerIndex,
      List<Customization> customizations, List<Widget> widgets) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    color: AppColors().kPrimaryColor,
                    child: Center(
                        child: Text(
                          _itemHeaders[outerIndex].items[innerIndex].itemName ?? "",
                          style: TextStyle(fontSize: 20),
                        ))),
                Column(children: widgets),
              ],
            ),
          );
        });
  }

  addItemToCartArray(
      int outerIndex, int innerIndex, int quantity, int itemId, bool isStamp)async {
    print(["minQuantity:",quantity]);

    for (int i = 0; i < _arrCartItem.length; i++) {
      print(["_arrCartItem[i]:",_arrCartItem[i].toJson()]);
      if (_arrCartItem[i].itemId == itemId) {
        _itemHeaders[outerIndex].items[innerIndex].selectedCount += 1;
        _arrCartItem[i].quantity += 1;
        foodListprovider.cartModel.cart = _arrCartItem;
        return;
      }
    }

    if (_itemHeaders[outerIndex].items[innerIndex].is_stamp.toString().toLowerCase() == "true") {
      _itemHeaders[outerIndex].items[innerIndex].cityTax = 0;
      _itemHeaders[outerIndex].items[innerIndex].stateTax = 0;
    }
    print(["---------00"]);
    for(var i=0;i<_itemHeadersFull.length;i++){
      for(var j=0;j<_itemHeadersFull[i].items.length;j++){
        if(_itemHeadersFull[i].items[j].itemId==itemId){
          if(_itemHeadersFull[i].items[j].itemWarn!=null){
            await _showAlcohol(i,j,outerIndex,innerIndex,isStamp);
            return;
          }
          _itemHeadersFull[i].items[j].selectedCount++;
          print(["inserted _itemHeaderFull[i--:",_itemHeadersFull[i].items[j].toJson()]);
          break;
        }
      }
    }
    _arrCartItem.add(Cart(
        itemId: _itemHeaders[outerIndex].items[innerIndex].itemId,
        itemName: _itemHeaders[outerIndex].items[innerIndex].itemName,
        itemPrice: _itemHeaders[outerIndex].items[innerIndex].sp == null
            ? double.parse(
            _itemHeaders[outerIndex].items[innerIndex].itemPrice.toString())
            : double.parse(
            _itemHeaders[outerIndex].items[innerIndex].sp.toString()),
        sp: _itemHeaders[outerIndex].items[innerIndex].sp == null
            ? null
            : double.parse(
            _itemHeaders[outerIndex].items[innerIndex].sp.toString()),
        quantity: quantity,
        taxtype: _itemHeaders[outerIndex].items[innerIndex].taxtype,
        cityTax: _itemHeaders[outerIndex].items[innerIndex].cityTax,
        stateTax: _itemHeaders[outerIndex].items[innerIndex].stateTax,
        customQunatity:
        _itemHeaders[outerIndex].items[innerIndex].customQunatity,
        taxvalue: 0.0,
        min_qty: quantity,
        citytaxvalue: _itemHeaders[outerIndex].items[innerIndex].cityTax != 0
            ? double.parse(_menulResponseModel.taxes.cityTax)
            : double.parse("0.0"),
        statetaxvalue: _itemHeaders[outerIndex].items[innerIndex].stateTax != 0
            ? double.parse(_menulResponseModel.taxes.stateTax)
            : double.parse("0.0"),
        is_stamp: isStamp));
    print(["inserted _itemHeaderFull[i--:------",_arrCartItem]);
    foodListprovider.cartModel.cart = _arrCartItem;
  }

  removeItemFromCartArray(int outerIndex, int innerIndex, int itemId){
    for(var i=0;i<_itemHeadersFull.length;i++){
      bool exitFor=false;
      for(var j=0;j<_itemHeadersFull[i].items.length;j++){
        if(_itemHeadersFull[i].items[j].itemId==itemId){
          exitFor=true;
          _itemHeadersFull[i].items[j].selectedCount--;
          break;
        }
      }
      if(exitFor)break;
    }
    for (int i = 0; i < _arrCartItem.length; i++) {
      if (_arrCartItem[i].itemId == itemId) {
        _arrCartItem[i].quantity -= 1;
        if(_arrCartItem[i].quantity==0){
          _arrCartItem.removeAt(i);
        }
        foodListprovider.cartModel.cart = _arrCartItem;
        return;
      }
    }

  }

  addItemToCartCustomizationArray(int outerIndex, int innerIndex, int itemId) {
    if (foodListprovider.cartModel.cart == null) return;
    for (int i = 0; i < foodListprovider.cartModel.cart.length; i++) {
      if (foodListprovider.cartModel.cart[i].itemId == itemId) {
        _arrCartCustomization.add(CartCustomization(
            optionId: _customizations[outerIndex].items[innerIndex].ciId,
            optionName:
            _customizations[outerIndex].items[innerIndex].optionName,
            optionPrice:
            _customizations[outerIndex].items[innerIndex].optionPrice));
        if (foodListprovider.cartModel.cart[i].customization == null) {
          foodListprovider.cartModel.cart[i].customization = [
            CartCustomization(
                optionId: _customizations[outerIndex].items[innerIndex].ciId,
                optionName:
                _customizations[outerIndex].items[innerIndex].optionName,
                optionPrice:
                _customizations[outerIndex].items[innerIndex].optionPrice)
          ];
        } else {
          foodListprovider.cartModel.cart[i].customization.add(
              CartCustomization(
                  optionId: _customizations[outerIndex].items[innerIndex].ciId,
                  optionName:
                  _customizations[outerIndex].items[innerIndex].optionName,
                  optionPrice: _customizations[outerIndex]
                      .items[innerIndex]
                      .optionPrice));
        }

        foodListprovider.addItemToCartCustomizationArray(
            outerIndex, innerIndex);
      }
    }
  }

  removeCartCustomization(int outerIndex, int innerIndex, int itemId) {
    for (int i = 0; i < foodListprovider.cartModel.cart.length; i++) {
      if (foodListprovider.cartModel.cart[i].itemId == itemId) {
        for (int j = 0;
        j < foodListprovider.cartModel.cart[i].customization.length;
        j++) {
          if (foodListprovider.cartModel.cart[i].customization[j].optionId ==
              _customizations[outerIndex].items[innerIndex].ciId) {
            _arrCartCustomization.removeAt(j);
            foodListprovider.cartModel.cart[i].customization.removeAt(j);
            foodListprovider.removeCartCustomization(outerIndex, innerIndex);
          }
        }
      }
    }
  }

  bool isCartCustomizationExist(int outerIndex, int innerIndex) {
    for (int i = 0; i < _arrCartCustomization.length; i++) {
      if (_arrCartCustomization[i].optionId ==
          _customizations[outerIndex].items[innerIndex].ciId) {
        return true;
      }
    }
    return false;
  }

  Widget _buildShopItem(int outerIndex, int innerIndex) {
    return Container(
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      margin: EdgeInsets.only(bottom: 20.0),
      //height: 500,
      child: Row(
        children: <Widget>[
          Expanded(
              child: CachedNetworkImage(
                imageBuilder: (context, imageProvider) => Container(
                  height: MediaQuery.of(context).size.width / 2,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(5.0, 5.0),
                            blurRadius: 10.0)
                      ]),
                ),
                imageUrl:
                baseUrl + _itemHeaders[outerIndex].items[innerIndex].itemPic ??
                    "",
                placeholder: (context, url) => Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(5.0, 5.0),
                              blurRadius: 10.0)
                        ]),
                    child: Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(5.0, 5.0),
                            blurRadius: 10.0)
                      ]),
                  child: Image.asset(
                    'assets/images/dish_placeholder.png',
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _itemHeaders[outerIndex].items[innerIndex].itemName ?? "",
                    style:
                    TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text('',
                      style: TextStyle(color: Colors.grey, fontSize: 18.0)),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                      '\$${_itemHeaders[outerIndex].items[innerIndex].itemPrice ?? 0.0}',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 30.0,
                      )),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text('',
                      style: TextStyle(
                          fontSize: 18.0, color: Colors.grey, height: 1.5)),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            List<String> arrIntCustomization =
                            _itemHeaders[outerIndex]
                                .items[innerIndex]
                                .customizations
                                .toString()
                                .split(',')
                                .toList();
                            List<Customization> arrItemCustomization = [];
                            for (int i = 0; i < _customizations.length; i++) {
                              for (int j = 0;
                              j < arrIntCustomization.length;
                              j++)
                                if ("${_customizations[i].cusid}" ==
                                    arrIntCustomization[j]) {
                                  arrItemCustomization.add(_customizations[i]);
                                }
                            }
                            _settingModalBottomSheet(
                                context,
                                outerIndex,
                                innerIndex,
                                arrItemCustomization,
                                getCustomizationHeaders(
                                    arrItemCustomization,
                                    _itemHeaders[outerIndex]
                                        .items[innerIndex]
                                        .itemId));
                          },
                          child: Text(
                            (_itemHeaders[outerIndex]
                                .items[innerIndex]
                                .customizations ==
                                null ||
                                _itemHeaders[outerIndex]
                                    .items[innerIndex]
                                    .customizations ==
                                    "null" ||
                                _itemHeaders[outerIndex]
                                    .items[innerIndex]
                                    .customizations ==
                                    "")
                                ? ''
                                : 'Customizable',
                            style: TextStyle(
                              color: AppColors().kGrey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        buildIncDecrContainer(outerIndex, innerIndex)
                      ])
                ],
              ),
              margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10.0),
                      topRight: Radius.circular(10.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey,
                        offset: Offset(5.0, 5.0),
                        blurRadius: 10.0)
                  ]),
            ),
          )
        ],
      ),
    );
  }

  searchViaGroup(String value) {
    if (value == '') {
      sortViaGroup(selectedCategory);
      return;
    }
    _itemCats = Set<String>();

    for (int index = 0; index < _itemHeadersFull.length; index++) {
      for (int i = 0; i < _itemHeadersFull[index].items.length; i++) {
        if (_itemHeadersFull[index].items[i].itemCat != null) {
          if (_itemHeadersFull[index].items[i].itemName.toLowerCase().contains(value.toLowerCase()))
            _itemCats.add(_itemHeadersFull[index].items[i].itemCat);
        }
      }
    }
    _itemHeaders = [];

    for (int i = 0; i < _itemCats.length; i++) {
      List<MenuCountItem> items = [];
      for (int index = 0; index < _itemHeadersFull.length; index++) {
        for (int j = 0; j < _itemHeadersFull[index].items.length; j++) {
          if (_itemHeadersFull[index].items[j].itemCat ==
              _itemCats.toList()[i]) {
            if (_itemHeadersFull[index]
                .items[j]
                .itemName
                .toLowerCase()
                .contains(value.toLowerCase())) {
              items.add(_itemHeadersFull[index].items[j]);
            }
          }
        }
      }
      _itemHeaders.add(ItemCountHeader(
          groupid: _itemHeadersFull[i].groupid,
          name: _itemHeadersFull[i].name,
          items: items));
    }

    List<FoodGroup> arrFoodGroup = [];
    for (int i = 0; i < _itemHeaders.length; i++) {
      List<ItemQtyModel> arrItemQtyModel = [];
      List<MenuCountItem> items = [];
      for (int j = 0; j < _itemHeaders[i].items.length; j++) {
        items.add(_itemHeaders[i].items[j]);
        arrItemQtyModel
            .add(ItemQtyModel(itemId: _itemHeaders[i].items[j].itemId, qty: 0));
      }
      arrFoodGroup.add(FoodGroup(
          groupID: _itemHeaders[i].groupid, itemQtyModel: arrItemQtyModel));
    }
    _menuQtyModel.foodGroup = arrFoodGroup;
    setState(() {});
  }

  sortViaGroup(int index) {
    _itemCats = Set<String>();
    for (int i = 0; i < _itemHeadersFull[index].items.length; i++) {
      if (_itemHeadersFull[index].items[i].itemCat != null)
        _itemCats.add(_itemHeadersFull[index].items[i].itemCat);}
    _itemHeaders = [];
    for (int i = 0; i < _itemCats.length; i++) {
      List<MenuCountItem> items = [];
      for (int j = 0; j < _itemHeadersFull[index].items.length; j++) {

        if (_itemCats.toList()[i] == _itemHeadersFull[index].items[j].itemCat) {
          items.add(_itemHeadersFull[index].items[j]);
        }
      }
      _itemHeaders.add(ItemCountHeader(
          groupid: _itemHeadersFull[index].groupid,
          name: _itemHeadersFull[index].name,
          items: items));
    }
    List<FoodGroup> arrFoodGroup = [];
    for (int i = 0; i < _itemHeaders.length; i++) {
      List<ItemQtyModel> arrItemQtyModel = [];
      List<MenuCountItem> items = [];
      for (int j = 0; j < _itemHeaders[i].items.length; j++) {
        items.add(_itemHeaders[i].items[j]);
        arrItemQtyModel
            .add(ItemQtyModel(itemId: _itemHeaders[i].items[j].itemId, qty: 0));
      }
      arrFoodGroup.add(FoodGroup(
          groupID: _itemHeaders[i].groupid, itemQtyModel: arrItemQtyModel));
    }
    _menuQtyModel.foodGroup = arrFoodGroup;
    headerImageUrl = _itemHeadersFull[index].groupPic;

    setState(() {});
  }

  sortViaCategory(String cat) {
    _itemHeaders = [];
    List<FoodGroup> arrFoodGroup = [];
    for (int i = 0; i < _itemHeadersFull.length; i++) {
      List<ItemQtyModel> arrItemQtyModel = [];
      List<MenuCountItem> items = [];
      bool isThere = false;
      for (int j = 0; j < _itemHeadersFull[i].items.length; j++) {
        if (_itemHeadersFull[i].items[j].itemCat == cat) {
          isThere = true;
          items.add(_itemHeadersFull[i].items[j]);
          // _itemHeaders.add(_itemHeadersFull[i]);
          arrItemQtyModel.add(ItemQtyModel(
              itemId: _itemHeadersFull[i].items[j].itemId, qty: 0));
        }
      }
      if (isThere) {
        _itemHeaders.add(ItemCountHeader(
            name: _itemHeadersFull[i].name,
            groupid: _itemHeadersFull[i].groupid,
            items: items));
        arrFoodGroup.add(FoodGroup(
            groupID: _itemHeadersFull[i].groupid,
            itemQtyModel: arrItemQtyModel));
      }
    }
    _menuQtyModel.foodGroup = arrFoodGroup;

    if (cat == "All") {
      for (int i = 0; i < _itemHeadersFull.length; i++) {
        List<ItemQtyModel> arrItemQtyModel = [];
        List<MenuCountItem> items = [];
        for (int j = 0; j < _itemHeadersFull[i].items.length; j++) {
          items.add(_itemHeadersFull[i].items[j]);
          // _itemHeaders.add(_itemHeadersFull[i]);
          arrItemQtyModel.add(ItemQtyModel(
              itemId: _itemHeadersFull[i].items[j].itemId, qty: 0));
        }
        _itemHeaders.add(ItemCountHeader(
            name: _itemHeadersFull[i].name,
            groupid: _itemHeadersFull[i].groupid,
            items: items));
        arrFoodGroup.add(FoodGroup(
            groupID: _itemHeadersFull[i].groupid,
            itemQtyModel: arrItemQtyModel));
      }
      _menuQtyModel.foodGroup = arrFoodGroup;
    }
    setState(() {});

    //_itemHeaders = _itemHeadersFull;
  }

  searchViaText(String cat) {
    _itemHeaders = [];
    List<FoodGroup> arrFoodGroup = [];
    for (int i = 0; i < _itemHeadersFull.length; i++) {
      List<ItemQtyModel> arrItemQtyModel = [];
      List<MenuCountItem> items = [];
      bool isThere = false;
      for (int j = 0; j < _itemHeadersFull[i].items.length; j++) {
        if (_itemHeadersFull[i]
            .items[j]
            .itemName
            .toLowerCase()
            .contains(cat.toLowerCase())) {
          isThere = true;
          items.add(_itemHeadersFull[i].items[j]);
          // _itemHeaders.add(_itemHeadersFull[i]);
          arrItemQtyModel.add(ItemQtyModel(
              itemId: _itemHeadersFull[i].items[j].itemId, qty: 0));
        }
      }
      if (isThere) {
        _itemHeaders.add(ItemCountHeader(
            name: _itemHeadersFull[i].name,
            groupid: _itemHeadersFull[i].groupid,
            items: items));
        arrFoodGroup.add(FoodGroup(
            groupID: _itemHeadersFull[i].groupid,
            itemQtyModel: arrItemQtyModel));
      }
    }
    _menuQtyModel.foodGroup = arrFoodGroup;

    if (cat == "All") {
      for (int i = 0; i < _itemHeadersFull.length; i++) {
        List<ItemQtyModel> arrItemQtyModel = [];
        List<MenuCountItem> items = [];
        for (int j = 0; j < _itemHeadersFull[i].items.length; j++) {
          items.add(_itemHeadersFull[i].items[j]);
          // _itemHeaders.add(_itemHeadersFull[i]);
          arrItemQtyModel.add(ItemQtyModel(
              itemId: _itemHeadersFull[i].items[j].itemId, qty: 0));
        }
        _itemHeaders.add(ItemCountHeader(
            name: _itemHeadersFull[i].name,
            groupid: _itemHeadersFull[i].groupid,
            items: items));
        arrFoodGroup.add(FoodGroup(
            groupID: _itemHeadersFull[i].groupid,
            itemQtyModel: arrItemQtyModel));
      }
      _menuQtyModel.foodGroup = arrFoodGroup;
    }
    setState(() {});

    //_itemHeaders = _itemHeadersFull;
  }

  Future<void> toggleFavorite(MenuCountItem item) async {
    User user = await AppUtils.getUser();
    dynamic token = await AppUtils.getToken();

    if (user == null || user.id == null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginSignupScreen()));
    } else {
      ApiResponse<CommonResponseModel> response = await K3Webservice.postMethod(
          apisToUrls(Apis.favorite),
          jsonEncode({
            "user_id": "${user.id}",
            "item_id": "${item.itemId}",
            "is_fav ": !item.is_fav
          }),
          {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          });
      // ApiResponse<CommonResponseModel> apiResponse =
      // await K3Webservice.postMethod(
      //     apisToUrls(Apis.cancelOrder), jsonEncode({'order_id': orderId}), {
      //   "Authorization": "Bearer $token",
      //   "Content-Type": "application/json"
      // });
      if (response.data.status) {
        item.is_fav = !item.is_fav;
        setState(() {});
      }
    }
  }
  Future _showAlcohol(int i, int j,int outerIndex, int innerIndex,bool isStamp)async{
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.padding),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context,i,j,outerIndex,innerIndex,isStamp),
      );
    });
  }


  contentBox(context,int i, int j,int outerIndex,int innerIndex,bool isStamp){
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: Constants.padding,top: Constants.avatarRadius
              + Constants.padding, right: Constants.padding,bottom: Constants.padding
          ),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(color: Colors.black,offset: Offset(0,10),
                    blurRadius: 10
                ),
              ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Estas seguro ?",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
              SizedBox(height: 15,),
              Text("${_itemHeaders[outerIndex].items[innerIndex].itemWarn}",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
              SizedBox(height: 22,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                        color: Colors.lightBlue,
                        onPressed: (){
                          allowAlcohol(i, j, outerIndex,innerIndex,isStamp);
                        },
                        child: Text("Yes",style: TextStyle(fontSize: 18,color: Colors.white),)),
                  ),
                  SizedBox(width: 10,),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FlatButton(
                        color: Colors.red,
                        onPressed: (){
                          Navigator.of(context).pop();
                        },
                        child: Text("Cancel",style: TextStyle(fontSize: 18,color: Colors.white),)),
                  ),
                ],
              )
            ],
          ),
        ),// bottom part
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child:RotationTransition(
                  turns: new AlwaysStoppedAnimation(0),
                  child: Image.asset("assets/images/img_logo.jpeg",width: 80,fit: BoxFit.fitWidth,)
                  // child: new Icon(Icons.info_outline,size: 80, color: Colors.deepOrangeAccent,),
                )
            ),
          ),// top part
        )],
    );
  }

  allowAlcohol(int i, int j,int outerIndex,int innerIndex,bool isStamp){
    print(["outerIndex:",outerIndex,"innerIndex:",innerIndex]);
    _itemHeadersFull[i].items[j].selectedCount += _itemHeaders[outerIndex].items[innerIndex].min_qty;
    _arrCartItem.add(Cart(
        itemId: _itemHeaders[outerIndex].items[innerIndex].itemId,
        itemName: _itemHeaders[outerIndex].items[innerIndex].itemName,
        itemPrice: _itemHeaders[outerIndex].items[innerIndex].sp == null
            ? double.parse(
            _itemHeaders[outerIndex].items[innerIndex].itemPrice.toString())
            : double.parse(
            _itemHeaders[outerIndex].items[innerIndex].sp.toString()),
        sp: _itemHeaders[outerIndex].items[innerIndex].sp == null
            ? null
            : double.parse(
            _itemHeaders[outerIndex].items[innerIndex].sp.toString()),
        quantity: _itemHeaders[outerIndex].items[innerIndex].min_qty,
        taxtype: _itemHeaders[outerIndex].items[innerIndex].taxtype,
        cityTax: _itemHeaders[outerIndex].items[innerIndex].cityTax,
        stateTax: _itemHeaders[outerIndex].items[innerIndex].stateTax,
        customQunatity:
        _itemHeaders[outerIndex].items[innerIndex].customQunatity,
        taxvalue: 0.0,
        min_qty: _itemHeaders[outerIndex].items[innerIndex].min_qty,
        citytaxvalue: _itemHeaders[outerIndex].items[innerIndex].cityTax == 1
            ? double.parse(_menulResponseModel.taxes.cityTax)
            : double.parse("0.0"),
        statetaxvalue: _itemHeaders[outerIndex].items[innerIndex].stateTax == 1
            ? double.parse(_menulResponseModel.taxes.stateTax)
            : double.parse("0.0"),
        is_stamp: isStamp));
    foodListprovider.cartModel.cart = _arrCartItem;
    totalPrice = calculateTotalItemPrice();
    Navigator.of(context).pop();
    setState(() {
    });
  }
}

class ImageDialog extends StatelessWidget {
  final String imgUrl;
  final String name;
  final String description;

  const ImageDialog({Key key, this.imgUrl, this.name, this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 500,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CachedNetworkImage(
                  imageUrl: imgUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.width / 2,
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/dish_placeholder.png',
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width / 2,
                    fit: BoxFit.contain,
                  )),
              SizedBox(height: 20),
              Text(
                name ?? '',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Text(
                description ?? '',
                textAlign: TextAlign.center,
                maxLines: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}

