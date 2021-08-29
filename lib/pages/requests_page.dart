import 'dart:convert';

import 'package:entools/model/user_requests_model.dart';
import 'package:entools/service/shared_service.dart';
import 'package:entools/utils/form_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestsPage extends StatefulWidget {
  @override
  _RequestsPageState createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  List<UserRequestModel> _requests = [];
  String loggedUser;
  getRequests() async {
    var result = await get("https://192.168.0.39:44333/api/Request?username=");
    var l = json.decode(result.body);
    var requests = List<UserRequestModel>.from(
        l.map((model) => UserRequestModel.fromJson(model)));
    return requests;
  }

  setLoggedUser() async {
    SharedService.loginDetails().then((String result) {
      setState(() {
        loggedUser = result;
      });
    });
  }

  @override
  initState() {
    setLoggedUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "ENTOOLS",
        )),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text("Dobrodošao, Admin"),
              accountEmail: new Text("admin@gmail.com"),
              currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.yellow,
                  child: Text('A', style: TextStyle(color: Colors.black87))),
              decoration: new BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.purple, Colors.blue]),
              ),
            ),
            new ListTile(
                leading: Icon(Icons.home),
                title: new Text("Početna"),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed("/home");
                }),
            new ListTile(
                leading: Icon(Icons.archive),
                title: new Text("Zahtjevi"),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed("/requests");
                }),
            new Divider(),
            new ListTile(
                leading: Icon(Icons.power_settings_new),
                title: new Text("Logout"),
                onTap: () {
                  SharedService.logout(context);
                }),
          ],
        ),
      ),
      body: FutureBuilder(
          future:
              getRequests(), //async function that returns a Future<Map<String, dynamic>>
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.done) {
                _requests = [];
              }
              return CircularProgressIndicator();
            }
            _requests = snapshot.data;
            return GridView.builder(
              itemCount: _requests.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 8.0 / 6.0,
                crossAxisCount: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: EdgeInsets.all(5),
                    child: GestureDetector(
                      onTap: () async {
                        var url = _requests[index].gcodeUrl;
                        if (url.isEmpty)
                          FormHelper.showMessage(context, "GCode",
                              "Zahtjev još nije odobren.", "OK", () {
                            Navigator.of(context).pop();
                          });
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw "Greska";
                        }
                      },
                      child: Card(
                          color: _requests[index].isOpened == true &&
                                  _requests[index].isApproved == false
                              ? Colors.red
                              : _requests[index].gcodeUrl != null
                                  ? Colors.tealAccent.shade400
                                  : Colors.grey.shade200,
                          elevation: 5.0,
                          semanticContainer: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _requests[index].isOpened == true &&
                                            _requests[index].isApproved == false
                                        ? Icon(Icons.alarm_off)
                                        : _requests[index].gcodeUrl != null
                                            ? Icon(Icons.download)
                                            : Icon(Icons.access_alarm)
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _requests[index].isOpened == true &&
                                              _requests[index].isApproved ==
                                                  false
                                          ? Text("Odbijeno",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Colors.white))
                                          : _requests[index].gcodeUrl != null
                                              ? Text("Prihvaćeno",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.teal))
                                              : Text("Na čekanju",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors
                                                          .grey.shade600)),
                                      Text("Kreirano: " +
                                          _requests[index]
                                              .dateCreated
                                              .substring(
                                                  0,
                                                  _requests[index]
                                                      .dateCreated
                                                      .indexOf("T"))),
                                      Text("Zahtjev #" +
                                          _requests[index].id.toString())
                                    ],
                                  )),
                            ],
                          )),
                    ));
              },
            );
          }),
    );
  }
}
