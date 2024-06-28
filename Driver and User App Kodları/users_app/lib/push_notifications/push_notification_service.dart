import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as devtools show log;

import '../infoHandler/app_info.dart';


class PushNotificationService {

  static Future<String> getAccessToken() async
  {
    final serviceAccountJson =
    {

      "type": "service_account",
      "project_id": "muber-9641d",
      "private_key_id": "db21a411157e5ec0a2b2f5ea0df936903e05b342",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+ohAsbethTAmj\nf6O94/q6FU5Qr0eNGyXfR8Y1QH6R/VMX3/ULNhsea4v1seckdNmVZcZVSqamIML6\nB+ySmeYucA8LjPcjh1u7f+eyJ8+RNscKZUex+fgYYwlvuszqLcZjL+RC42lwoORy\nvhcPvfrAMWhiesz6swy1wuo5ySMKWtYgTBq0ED0ntPNV3Eoi0R88d5kwsvmYttGO\nrpWbMRDPfSICDdCgHctSpUWf6bnB5PYejF3deXOBJzt0IjwrK8FEFLlhP+ET7JF8\nYh0jTMHTqRT2NmMjGnLU8Reys9SeUutd1DMzGN4CXYTJEipoP79jSGyytf7lRw3s\nq39eze57AgMBAAECggEAFJz0j8FQ/uPYdPfzzjAtJ9ru7XWOkJj7ZuHdclundATG\n6+F5Hz25//eUGjyi6EPEVU28fPOGApevTZb2w0Fl7OaMEe0ruglEZ4lkldSNMsAQ\nFLUv4/RKGeT3m7/AsZ/CgG4oyfzKJXYYTbn1R2v9BbQx+9gYexFKUgsiBZ6UreVF\nycinfYXKilI0z+lxQ5So63PecsAG16v0KqIJK3+i5xA5Ia7LDYoXWALvWuuuVa1U\n/2kw1RdcJjB6WITwlf4Jz7NqG7khTSN95EcruIetAKHXW2TfeG68ccduaypT+Yyv\nFQCXUM8gBeHeC7+7euU+0XPGPG+9b/IxMNqlhkyD8QKBgQDmb/9/kOLII0RVG1IY\nICs7TBPcFWkRjV1mCmhau/e76DdI7IUhvxbwUtz4Nk1kedTO90nzpi0dRfyZdXBF\nhfZqv7uQfresEMhGHKjMG1TdB21SJTWcS0OyCJp28g6gMPlk9ud8lzTWx1zvwwun\nHo+HOPfesBETPOoR4D3ieOBfKwKBgQDTx7E47NXaBNQQwkCaMa9/555taRW4cUPu\nct9xfeRegWVOS4/F7s2jPIjfJWfDEhF3FtoTuPZHQWlc1Wl5i/0Uj+Zu+wQmsnIp\nK/2XxlU4uSECxGxYCWB79h8YvQF/ydL0XCKVEgourcHjxZq+XZ8IwxokxUAngpb/\nFNVHLOmF8QKBgQDg/pe0AU48ZZrRkjRs0/QCGL0HVWxaM/HusNjFRuSS9yALtswi\ncAbArdeNDtAv+3iaf/8Xw7gm7e++ElmFuFAqWHyVj/RcL6KsOk1hxInuqdLGswgO\nS7qUOSxAWQWIyWioeR76mlSAJPYMMB/Pk9pGCIyURMrXQtG0lIM3/hftMwKBgQC0\nQqongPd5zlhPN3jThm0SWqzwBd02FDq1MNPd/0Et68e1//0NhflE81axUV5jnPJ+\nwlW3Kd1+wz+ShBh2G+C76sxCNKjQ41zmjIoa8PdDA9kESPrLaJfWi6TmYqJvCfPk\niLPq3OML3lxFqsHPPVMLmz2ahMbZmn85+ZqcLa9LkQKBgAna0ZWnjbdt1xpNMSS0\nqSgchK2fAD2L2fN+nY0cWRlbLkit7qGw2j3mv7Yn7LuboHwkY5ZDOq1c/MK+G06v\nNnK3P/qjO0X0lU0WG6EkwJZ85be4NwAwExfow2wnqXYSCz0MNZ2KxPd659UoSLss\nlSrUQ2c/G++qgep52QK+X78Z\n-----END PRIVATE KEY-----\n",
      "client_email": "muber-flutter-uber-clone@muber-9641d.iam.gserviceaccount.com",
      "client_id": "103197967343554383824",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/muber-flutter-uber-clone%40muber-9641d.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };



    List<String> scopes =
    [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();

    return credentials.accessToken.data;
  }

   static sendNotificationToSelectedDriver(String deviceToken, BuildContext context, String tripID) async
  {
    String dropOffAddress = Provider.of<AppInfo>(context, listen: false).userDropOffLocation!.locationName.toString();
    String pickUpAddress = Provider.of<AppInfo>(context, listen: false).userPickUpLocation!.locationName.toString();

    final String serverAccessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/muber-9641d/messages:send';

    final Map<String, dynamic> message =
    {
      'message':
      {
        'token': deviceToken,
        'notification' :
        {
          "title": "MUber",
          "body": "Hello! You have a new Ride Request! Please check."
        },
        'data': //aynısını kullanmaya dikkat!!!!
        {
          "tripID":tripID,
        },
      }
    };
    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers:<String, String>
      {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: jsonEncode(message),
    );

    if(response.statusCode == 200)
    {
      print('Notification sent successfully.');
    }
    else
    {
      print('Failed to send FCM message: ${response.statusCode}');
    }
  }
}