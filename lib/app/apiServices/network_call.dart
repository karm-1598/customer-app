import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:shopperz/app/apiServices/common_widget.dart';
import 'package:shopperz/model/responseapi.dart';
import 'package:shopperz/utils/api_list.dart';

final Logger _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

Map<String, String> getHeaders({bool isJson = true}) {
  return isJson
      ? {
          "Content-Type": "application/json",
        }
      : {};
}

/// =======================
/// POST API (JSON)
/// =======================
Future<void> postAPI({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  final String url = ApiList.baseUrl + methodName;
  final Uri uri = Uri.parse(url);

  log("==REQUEST== $uri");
  log("==PARAMS== $param");

  try {
    final response = await http
        .post(
          uri,
          headers: getHeaders(isJson: true),
          body: jsonEncode(param),
        )
        .timeout(const Duration(seconds: 20));

    _handleResponse(response, callback);
  } on TimeoutException {
    _handleNetworkError("Request Timeout", callback);
  } catch (e) {
    _handleNetworkError(e.toString(), callback);
  }
}

/// =======================
/// POST API (Form Data)
/// =======================
Future<void> postAPIWithoutToken({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  final String url = ApiList.baseUrl + methodName;
  final Uri uri = Uri.parse(url);

  log("==REQUEST== $uri");
  log("==PARAMS== $param");

  try {
    final response = await http
        .post(
          uri,
          body: param,
        )
        .timeout(const Duration(seconds: 20));

    _handleResponse(response, callback);
  } on TimeoutException {
    _handleNetworkError("Request Timeout", callback);
  } catch (e) {
    _handleNetworkError(e.toString(), callback);
  }
}

/// =======================
/// GET API
/// =======================
Future<void> getAPI({
  required String methodName,
  required Map<String, dynamic> param,
  required Function(ResponseAPI) callback,
}) async {
  final String url = ApiList.baseUrl + methodName;
  Uri uri = Uri.parse(url).replace(queryParameters: param);

  log("==REQUEST== $uri");

  try {
    final response = await http
        .get(
          uri,
          headers: getHeaders(isJson: false),
        )
        .timeout(const Duration(seconds: 20));

    _handleResponse(response, callback);
  } on TimeoutException {
    _handleNetworkError("Request Timeout", callback);
  } catch (e) {
    _handleNetworkError(e.toString(), callback);
  }
}

/// =======================
/// GET MAP API
/// =======================
Future<void> getMapAPI({
  required String methodName,
  required Function(ResponseAPI) callback,
}) async {
  final Uri uri = Uri.parse(methodName);

  log("==REQUEST== $uri");

  try {
    final response =
        await http.get(uri).timeout(const Duration(seconds: 20));

    _handleResponse(response, callback);
  } on TimeoutException {
    _handleNetworkError("Request Timeout", callback);
  } catch (e) {
    _handleNetworkError(e.toString(), callback);
  }
}

/// =======================
/// MULTIPART POST API
/// =======================
Future<void> multipartPostAPI({
  required String methodName,
  required Map<String, String> param,
  required Function(ResponseAPI) callback,
  required List<XFile> photo,
  required String photoName,
}) async {
  final String url = ApiList.baseUrl + methodName;
  final Uri uri = Uri.parse(url);

  log("==REQUEST== $uri");
  log("==PARAMS== $param");

  try {
    final request = http.MultipartRequest('POST', uri);

    for (int i = 0; i < photo.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath(
          photoName,
          photo[i].path,
        ),
      );
    }

    request.fields.addAll(param);

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 30));

    final response =
        await http.Response.fromStream(streamedResponse);

    _handleResponse(response, callback);
  } on TimeoutException {
    _handleNetworkError("Upload Timeout", callback);
  } catch (e) {
    _handleNetworkError(e.toString(), callback);
  }
}

/// =======================
/// HANDLE RESPONSE
/// =======================
void _handleResponse(
    http.Response response, Function(ResponseAPI) callback) {
  _logger.i("==STATUS== ${response.statusCode}");
  _logger.i("==BODY== ${response.body}");

  if (response.statusCode >= 200 &&
      response.statusCode < 300) {
    callback(ResponseAPI(response.statusCode, response.body));
  } else {
    callback(ResponseAPI(
      response.statusCode,
      "Server Error",
      isError: true,
      error: null,
    ));
  }
}

/// =======================
/// HANDLE NETWORK ERROR
/// =======================
void _handleNetworkError(
    String message, Function(ResponseAPI) callback) {
  _logger.e("NETWORK ERROR: $message");

  toast("Network Error");

  callback(ResponseAPI(
    0,
    message,
    isError: true,
    error: null,
  ));
}
