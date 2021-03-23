import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:zabor/app_localizations/app_localizations.dart';
import 'package:zabor/constants/apis.dart';
import 'package:zabor/constants/constants.dart';
import 'package:zabor/screens/forgot_password/forgot_password_screen.dart';
import 'package:zabor/screens/login_signup/model/model.dart';
import 'package:zabor/screens/login_signup/providers/login_sigup_provider.dart';
import 'package:zabor/screens/login_signup/widgets/social_button.dart';
import 'package:zabor/state_manager_widgets/tab_bar_manager.dart';
import 'package:zabor/webservices/webservices.dart';
import 'package:zabor/constants/app_utils.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({
    Key key,
  }) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _password;
  String _email;
  TextEditingController emailController =
      TextEditingController(text: "");
  TextEditingController pwdController =
      TextEditingController(text: "joshua3758");

  @override
  Widget build(BuildContext context) {
    final loginSignupTabBar = Provider.of<LoginSignupTabBar>(context);
    final webservices = Provider.of<Webservices>(context, listen: false);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: ScreenUtil.instance.setHeight(420),
            ),
            Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: AppColors().kWhiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors().kBlackColor54,
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'LOGIN',
                                    style: AppFontStyle().kHeading16TextStyle,
                                  ),
                                  onPressed: () {},
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 15,
                                  right: 15,
                                  child: Container(
                                    height: 2,
                                    width: 50,
                                    color: AppColors().kPrimaryColor,
                                  ),
                                )
                              ],
                            ),
                            FlatButton(
                              child: Text('SIGN UP',
                                  style: AppFontStyle().kHeading16GreyStyle),
                              onPressed: () {
                                loginSignupTabBar
                                    .changeTab(LoginSignupTab.Signup);
                              },
                            ),
                          ],
                        ),
                        emailTextField(),
                        passwordTextField(),
                        //new PasswordTextFieldWidget(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ForgotPassswordScreen()));
                              },
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('Forgot Password?'),
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontSize: 11,
                                    color: AppColors().kPrimaryColor),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: ScreenUtil.instance.setHeight(90),
                    width: double.infinity,
                    child: Consumer<Webservices>(
                      builder: (context, webservice, child) => FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0)),
                        onPressed: webservice.isFetching
                            ? null
                            : () {
                                _validateInputs(context, webservices);
                              },
                        color: AppColors().kPrimaryColor,
                        child: webservice.isFetching
                            ? CircularProgressIndicator()
                            : Text(
                                'SIGN IN',
                                style: AppFontStyle().kHeading16TextStyle,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(90),
                ),
                Platform.isAndroid ? buildSocialLoginColumn() : Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Don't have an account?",
                        style: AppFontStyle().kTextGrey12Style),
                    Text(' '),
                    GestureDetector(
                      onTap: () {
                        loginSignupTabBar.changeTab(LoginSignupTab.Signup);
                      },
                      child: Text('SIGN UP',
                          style: AppFontStyle().kTextYellowBold12Style),
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setHeight(20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Column buildSocialLoginColumn() {
    return Column(children: [
      Text(
        ('------- SOCIAL LOGIN WITH -------'),
        style: AppFontStyle().kTextBlack10Style,
      ),
      SizedBox(
        height: ScreenUtil.instance.setHeight(40),
      ),
      new SocialButtonWidget(),
      SizedBox(
        height: ScreenUtil.instance.setHeight(40),
      ),
    ]);
  }

  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors().kGreyColor100),
          borderRadius: BorderRadius.all(
              new Radius.circular(ScreenUtil.instance.setHeight(90))),
        ),
        child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
                hintText: 'Email',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FaIcon(
                    FontAwesomeIcons.envelope,
                    color: AppColors().kPrimaryColor,
                  ),
                ),
                enabledBorder: InputBorder.none,
                border: InputBorder.none),
            validator: AppHelpers().validateEmail,
            onSaved: (String val) {
              _email = val;
            }),
      ),
    );
  }

  Widget passwordTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors().kGreyColor100),
          borderRadius: BorderRadius.all(
              new Radius.circular(ScreenUtil.instance.setHeight(90))),
        ),
        child: TextFormField(
            obscureText: true,
            controller: pwdController,
            decoration: InputDecoration(
                hintText: 'Password',
                icon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FaIcon(
                    FontAwesomeIcons.unlock,
                    color: AppColors().kPrimaryColor,
                  ),
                ),
                enabledBorder: InputBorder.none,
                border: InputBorder.none),
            validator: AppHelpers().validatePassword,
            onSaved: (String val) {
              _password = val;
            }),
      ),
    );
  }

  void _validateInputs(context, webservices) async {
    final tabBarManager = Provider.of<TabBarManager>(context);
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String token = await AppUtils.getDeviceToken();
      final LoginResponseModel model = await webservices
          .callPOSTWebserivce<LoginResponseModel>(apisToUrls(Apis.login),
              {'email': _email, 'password': _password, 'device_token': token});

      //await showAlert(context, model.msg);
      showInSnackBar(model.msg);
      if (model.status == true) {
        print(model.data.token);
        AppUtils.saveUser(model.data.user);
        AppUtils.saveToken(model.data.token);
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => HomeScreen()
        // ));
        tabBarManager.activeTab = 0;
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text(value),
    ));
  }
}
