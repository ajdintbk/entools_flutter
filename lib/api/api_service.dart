import 'dart:convert';
import 'package:entools/service/shared_service.dart';
import 'package:http/http.dart' as http;
import 'package:entools/model/login_model.dart';

class APIService {
  String url = "https://192.168.0.39:44333";
  String loggedUser;
  // ignore: non_constant_identifier_names
  Future<bool> Login(String requestUsername, String requestPassword) async {
    // String basicAuth =
    //     'Basic ' + base64Encode(utf8.encode('$usernameInput:$passwordInput'));

    User user = new User(username: requestUsername, password: requestPassword);
    final r = await http.post(url + "/api/Users/Login",
        headers: {
          // 'authorization': 'Basic ' + basicAuth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(user.toJson()));

    if (r.statusCode == 200) {
      SharedService.setLoginDetails(r.body);
      return true;
    }
    return false;
  }
}
