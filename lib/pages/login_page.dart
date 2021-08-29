import 'dart:convert';

import 'package:entools/api/api_service.dart';
import 'package:entools/model/login_model.dart';
import 'package:entools/utils/form_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final APIService _apiService = new APIService();
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> Login() async {
    final url = "https://192.168.0.39:44333/api/Users/Login";
    // String basicAuth =
    //     'Basic ' + base64Encode(utf8.encode('$usernameInput:$passwordInput'));

    User user = new User(
        username: usernameController.text, password: passwordController.text);
    await http.post(url,
        headers: {
          // 'authorization': 'Basic ' + basicAuth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(user.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                  margin: EdgeInsets.symmetric(vertical: 85, horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).hintColor.withOpacity(0.2),
                            offset: Offset(0, 10),
                            blurRadius: 20)
                      ]),
                  child: Form(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Image.network("https://i.imgur.com/6Dbhpl4.png",
                            fit: BoxFit.contain, width: 140),
                        SizedBox(
                          height: 50,
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: usernameController,
                          decoration: new InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: "Korisničko ime",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.purple.shade400,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).accentColor),
                            ),
                            prefixIcon: Icon(Icons.account_box,
                                color: Colors.purple.shade500),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        new TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: passwordController,
                          obscureText: true,
                          decoration: new InputDecoration(
                            fillColor: Colors.grey.shade100,
                            filled: true,
                            hintText: "Lozinka",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.purple.shade400,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).accentColor),
                            ),
                            prefixIcon: Icon(Icons.password,
                                color: Colors.purple.shade500),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        new TextButton(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 20.0, color: Colors.white),
                            ),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                backgroundColor: Colors.purple.shade400),
                            onPressed: () async => {
                                  await _apiService.Login(
                                          usernameController.text,
                                          passwordController.text)
                                      .then((value) => value
                                          ? Navigator.of(context)
                                              .pushReplacementNamed("/home")
                                          : FormHelper.showMessage(
                                              context,
                                              "Greška",
                                              "Neuspještan login.",
                                              "OK", () {
                                              Navigator.of(context).pop();
                                            }))
                                }),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        )));
  }
}
