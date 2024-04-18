
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_text_recognition/model/gemimi_response_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class TextFormatController extends GetxController{

  var apiKey = "AIzaSyDyPEPp5H3KoRaZuK2Nu5CCjiuDL5zcJNs";
  GemimiResponseModel? gemimiResponseModel;
  List responseList = [];

  Future<String> textFormatRepo({required String extractedText}) async {
    if (kDebugMode) {
      print("==========>>$extractedText");
    }
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$apiKey");
    final headers = {'Content-Type': 'application/json'};
    var bodyData = {
      "contents": [
        {
          "parts": [
            {"text": "$extractedText, the texts make format like this(name, designation, company name, email, phone number, address) with a list"}
          ]
        }
      ]
    };
    try {
      var response =
      await http.post(url, body: jsonEncode(bodyData), headers: headers);
      if (kDebugMode) {
        print(response.body);
      }
      if (kDebugMode) {
        print(response.statusCode);
      }
      if (response.statusCode == 200) {
        gemimiResponseModel = GemimiResponseModel.fromJson(jsonDecode(response.body));
        final text = gemimiResponseModel?.candidates?[0].content?.parts?[0].text;
        if(text != null ){
          var responseText = text.replaceAll(RegExp(r'(\*|-|,|\n)'), '');
          if (kDebugMode) {
            print("responseText:::: ${responseText}");
          }
          List<String> parts = responseText.split(':').map((e) => e.trim()).toList();
          // Extract values and assign them to variables
          String name = parts[0];
          String designation = parts[1];
          String companyName = parts[2];
          String email = parts[3];
          String phoneNumber = parts[4];
          String address = parts.sublist(5).join(', '); // Join remaining parts for address

          // Print the extracted values
          print('Name: $name');
          print('Designation: $designation');
          print('Company Name: $companyName');
          print('Email: $email');
          print('Phone Number: $phoneNumber');
          print('Address: $address');
        }

        return response.body.toString();
      } else {
        return "Something went wrong";
      }
    } catch (error) {
      print("Error: $error");
      return "Something went wrong";
    }
  }

}
