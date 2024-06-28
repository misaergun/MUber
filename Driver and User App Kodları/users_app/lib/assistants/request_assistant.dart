import 'dart:convert';

import 'package:http/http.dart' as http;

class RequestAssistant
{
  static Future<dynamic> receiveRequest(String url) async
  {
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode == 200) //successful response
        {
          String responseData = httpResponse.body;
          var decodeResponseData = jsonDecode(responseData); //json
          return decodeResponseData;
        }
      else
        {
          return "Error occured. Failed. No response.";
        }
      }
      catch(exp)
      {
        return "Error occured. Failed. No response.";
      }

  }
}