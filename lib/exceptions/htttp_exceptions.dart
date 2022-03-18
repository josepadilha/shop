import 'dart:io';

class HttpException implements Exception {
  String msg;
  int statusCode;

  HttpException({
    required this.msg,
    required this.statusCode,
  });

  @override
  String toString() {
    return msg;
  }
}
