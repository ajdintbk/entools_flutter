import 'dart:convert';
import 'package:entools/model/machine_model.dart';
import 'package:entools/model/newrequest_model.dart';
import 'package:entools/model/part_model.dart';
import 'package:entools/model/part_operations_model.dart';
import 'package:entools/model/tool_model.dart';
import 'package:entools/model/version_request_model.dart';
import 'package:entools/model/versions_model.dart';
import 'package:entools/service/shared_service.dart';
import 'package:entools/utils/form_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String loggedUser;
  List<Part> _parts = [];
  List<Version> _versions = [];
  int partSelected;
  setLoggedUser() async {
    var result = await get("https://192.168.0.39:44333/api/parts");
    var l = json.decode(result.body);
    _parts = List<Part>.from(l.map((model) => Part.fromJson(model)));

    var versionsResult =
        await get("https://192.168.0.39:44333/api/Parts/preview/1");
    var vl = json.decode(versionsResult.body);
    _versions = List<Version>.from(vl.map((model) => Version.fromJson(model)));
    SharedService.loginDetails().then((String result) {
      setState(() {
        loggedUser = result;
      });
    });
  }

  @override
  // ignore: must_call_super
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
                  Navigator.pop(context);
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
      body: SingleChildScrollView(
          child: Column(
        children: [
          Column(children: [
            Image.asset("./Images/homescreenbanner.png",
                width: double.infinity, fit: BoxFit.cover)
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0)),
              Text("Komad",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          DropdownButton(
            hint: Text("Izaberi komad"),
            value: partSelected != null ? partSelected : 1,
            onChanged: (value) async {
              setState(() {
                partSelected = value;
              });
              await get("https://192.168.0.39:44333/api/Parts/preview/" +
                      value.toString())
                  .then((value) {
                var l = json.decode(value.body);
                _versions = List<Version>.from(
                    l.map((model) => Version.fromJson(model)));
              });
            },
            items: _parts.map((e) {
              return DropdownMenuItem(value: e.id, child: Text(e.name));
            }).toList(),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              _versions.length > 0
                  ? Text("Verzije",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                  : Text("")
            ]),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: _versions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 10.0),
                  child: Card(
                    elevation: 2.2,
                    child: ListTile(
                        onTap: () async {
                          var url = _versions[index].gcodeUrl;
                          if (url.isEmpty)
                            FormHelper.showMessage(context, "GCode",
                                "Ova verzija nema GCode file.", "OK", () {
                              Navigator.of(context).pop();
                            });
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw "Greska";
                          }
                        },
                        title: Text(_versions[index].versionName),
                        subtitle: Text(_versions[index].createdBy +
                            " | " +
                            _versions[index].dateCreated),
                        leading: Icon(Icons.assignment),
                        trailing: _versions[index].gcodeUrl.length > 0
                            ? Icon(Icons.download, color: Colors.grey[500])
                            : Icon(Icons.download, color: Colors.grey[350])),
                  ),
                );
              }),
          Container(
            margin: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  style: TextButton.styleFrom(
                      shape: CircleBorder(),
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      backgroundColor: Colors.purple.shade400),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new _NewRequestPage(
                                partFromHomeId:
                                    partSelected == null ? 1 : partSelected,
                                userLogged: loggedUser)));
                    // Navigator.of(context).push(route)
                  },
                ),
              ],
            ),
          )
        ],
      )),
      backgroundColor: Colors.white,
    );
  }
}

// ignore: must_be_immutable
class _NewRequestPage extends StatefulWidget {
  int partFromHomeId;
  String userLogged;
  // ignore: unused_element
  _NewRequestPage({Key key, this.partFromHomeId, Key key2, this.userLogged})
      : super(key: key);

  @override
  __NewRequestPageState createState() => __NewRequestPageState();
}

class __NewRequestPageState extends State<_NewRequestPage> {
  List<PartOperations> _partOperations = [];
  List<Machine> _machines = [];
  int machineSelected;
  List<Tool> _tools = [];
  int requestId;
  List<int> selectedTools = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  DateTime dateToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  getOperations() async {
    var operationsResult = await get(
        "https://192.168.0.39:44333/api/PartOperations?id=" +
            widget.partFromHomeId.toString());
    var l = json.decode(operationsResult.body);
    var operations = List<PartOperations>.from(
        l.map((model) => PartOperations.fromJson(model)));

    var toolsResult = await get("https://192.168.0.39:44333/api/Tools");
    var toolsl = json.decode(toolsResult.body);
    _tools = List<Tool>.from(toolsl.map((model) => Tool.fromJson(model)));
    return operations;
  }

  getMachines() async {
    var machinesResult = await get("https://192.168.0.39:44333/api/Machine");
    var l = json.decode(machinesResult.body);
    var machines =
        List<Machine>.from(l.map((model) => Machine.fromJson(model)));

    return machines;
  }

  createRequest() async {
    CircularProgressIndicator();
    var createdBy = widget.userLogged;

    var partId = widget.partFromHomeId;
    NewRequestModel dataToSend = new NewRequestModel(
        createdBy: createdBy,
        isApproved: false,
        isOpened: false,
        partId: partId,
        versionId: 1);

    await (post("https://192.168.0.39:44333/api/Request",
            headers: {
              // 'authorization': 'Basic ' + basicAuth,
              "Content-Type": "application/json"
            },
            body: jsonEncode(dataToSend.toJson())))
        .then((value) {
      var l = json.decode(value.body);
      NewRequestModel newRequest = NewRequestModel.fromJson(l);
      requestId = newRequest.id;
      var i = 0;
      List<VersionRequest> _listVersionRequests = [];
      _partOperations.forEach((e) {
        VersionRequest vr = new VersionRequest(
            machineId: machineSelected,
            requestId: requestId,
            operationId: e.operationId,
            partId: widget.partFromHomeId,
            toolId: _tools[selectedTools[i] - 1].id);
        _listVersionRequests.add(vr);
        i++;
      });

      _listVersionRequests.forEach((element) {
        post("https://192.168.0.39:44333/api/VersionRequest",
                headers: {
                  // 'authorization': 'Basic ' + basicAuth,
                  "Content-Type": "application/json"
                },
                body: jsonEncode(element.toJson()))
            .then((value) {
          if (value.statusCode != 200) {
            FormHelper.showMessage(
                context, "Greška", "Kreiranje zahtjeva nije uspjelo.", "OK",
                () {
              Navigator.of(context).pop();
            });
          }
        });
      });
      FormHelper.showMessage(context, "Zahtjev kreiran",
          "Zahtjev je uspješno prosljeđen na pregled.", "OK", () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        // Navigator.of(context).pushReplacementNamed("/home");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getOperations();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nazad",
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          FutureBuilder(
              //masine
              future:
                  getMachines(), //async function that returns a Future<Map<String, dynamic>>
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _machines = [];
                  }
                  return CircularProgressIndicator();
                }
                _machines = snapshot.data;
                return Container(
                    // width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).hintColor.withOpacity(0.2),
                              offset: Offset(0, 10),
                              blurRadius: 20)
                        ]),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 1.0),
                          child: Text(
                            "Novi zahtjev",
                            style: TextStyle(
                                fontSize: 22.0,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Roboto"),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton(
                              hint: Text("Izaberi mašinu"),
                              value: machineSelected,
                              onChanged: (value) async {
                                setState(() {
                                  machineSelected = value;
                                });
                                print(machineSelected);
                                print(_machines[machineSelected].imagePath +
                                    " id: " +
                                    _machines[machineSelected].id.toString() +
                                    _machines[machineSelected].name);
                              },
                              items: _machines.map((e) {
                                return DropdownMenuItem(
                                    value: e.id, child: Text(e.name));
                              }).toList(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                    machineSelected != null
                                        ? _machines[machineSelected - 1]
                                            .imagePath
                                        : "/Images/noimage.jpg",
                                    width: 100),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(machineSelected != null
                                          ? "Snaga: " +
                                              _machines[machineSelected - 1]
                                                  .power
                                                  .toString() +
                                              "W"
                                          : ""),
                                      Text(machineSelected != null
                                          ? "Brzina: " +
                                              _machines[machineSelected - 1]
                                                  .speed
                                                  .toString()
                                          : ""),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ));
              }),
          FutureBuilder(
              future:
                  getOperations(), //async function that returns a Future<Map<String, dynamic>>
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _partOperations = [];
                  }
                  return CircularProgressIndicator();
                }
                _partOperations = snapshot.data;
                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _partOperations.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10.0),
                          child: Card(
                            child: ListTile(
                              onTap: () {},
                              title: Text(_partOperations[index].operationName),
                              subtitle:
                                  Text(_partOperations[index].machineName),
                              leading: CircleAvatar(
                                backgroundImage: AssetImage(
                                    _tools[selectedTools[index] - 1]
                                        .imagePath
                                        .substring(
                                            1,
                                            _tools[selectedTools[index] - 1]
                                                .imagePath
                                                .length)),
                              ),
                              trailing: DropdownButton(
                                hint: Text("Izaberi alat"),
                                value: selectedTools[index],
                                onChanged: (value) async {
                                  setState(() {
                                    selectedTools[index] = value;
                                  });
                                },
                                items: _tools.map((e) {
                                  return DropdownMenuItem(
                                      value: e.id, child: Text(e.name));
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }),
                );
              }),
          Container(
            margin: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    child: Text("KREIRAJ ZAHTJEV",
                        style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                        elevation: 3.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                        backgroundColor: Colors.purple.shade400),
                    onPressed: () {
                      if (machineSelected == null) {
                        FormHelper.showMessage(
                            context,
                            "Greška",
                            "Prvo izaberite mašinu kako bi se kreirao zahtjev.",
                            "OK", () {
                          Navigator.of(context).pop();
                        });
                        return;
                      } else {
                        createRequest();
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
