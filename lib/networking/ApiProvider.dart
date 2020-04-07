import 'package:cyberdindaroloapp/networking/CustomException.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

class CyberDindaroloAPIv1Provider {
  static const String _baseUrl = "http://10.0.2.2:8000/api/v1/";

  Future<dynamic> get(String url, {Map headers}) async {
    var responseJson;
    try {
      final response = await http.get(_baseUrl + url, headers: headers);
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, {Map headers, Map body, encoding}) async {
    var responseJson;
    try {
      final response = await http
          .post(_baseUrl + url, body: body, headers: headers, encoding: encoding)
          .timeout(const Duration(seconds: 5));
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> patch(String url, {Map headers, Map body, encoding}) async {
    var responseJson;
    try {
      final response = await http
          .patch(_baseUrl + url, body: body, headers: headers, encoding: encoding)
          .timeout(const Duration(seconds: 5));
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> delete(String url, {Map headers}) async {
    var responseJson;
    try {
      final response = await http
          .delete(_baseUrl + url, headers: headers)
          .timeout(const Duration(seconds: 5));
      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        var responseJson = json.decode(response.body.toString());
        print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 404:
        throw NotFoundException(response.body.toString());
      case 409:
        throw ConflictException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
