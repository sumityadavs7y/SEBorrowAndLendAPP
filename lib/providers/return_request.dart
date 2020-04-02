import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'auth.dart';

class ReturnRequest {
  final int id;
  final String bookTitle;
  final DateTime date;
  final String senderName;
  final int senderMeritPoint;
  final String senderContact;

  ReturnRequest(
      {this.id,
      this.bookTitle,
      this.date,
      this.senderName,
      this.senderMeritPoint,
      this.senderContact});
}

class ReturnRequests with ChangeNotifier {
  final int userId;
  List<ReturnRequest> _requests = [];
  static DateFormat format = new DateFormat("dd-MM-yyyy");

  ReturnRequests(this.userId, this._requests);

  List<ReturnRequest> get requests {
    return _requests;
  }

  Map<String, String> get _header {
    return {"Content-Type": "application/json"};
  }

  Future<void> fetchAndSetRequests() async {
    List<ReturnRequest> _loadedRequest = [];
    final String url = Auth.domain + "/user/$userId/returnrequests";
    final response = await http.get(url);
    print(response.body);
    final rawRequests = json.decode(response.body)['requests'];
    rawRequests.forEach((requestData) {
      print('found 1');
      _loadedRequest.add(ReturnRequest(
          id: requestData['id'],
          bookTitle: requestData['book']['title'],
          date: format.parse(requestData['date']),
          senderName: requestData['sender']['name'],
          senderMeritPoint: requestData['sender']['merit_point'],
          senderContact: requestData['sender']['contact']));
    });
    _requests = _loadedRequest;
    notifyListeners();
  }

  Future<void> sendReturnRequest(int bookId) async {
    final String url = Auth.domain + '/book/$bookId/returnrequest';
    final response = await http.post(url, headers: _header);
    if (response.statusCode < 500 && response.statusCode >= 300) {
      throw HttpException(json.decode(response.body)['message']);
    } else if (response.statusCode >= 500) {
      throw HttpException('got internal error');
    }
  }

  Future<void> respondToRequest(int requestId, bool status,
      {double rating = 1}) async {
    final String url = Auth.domain + '/returnrequest/$requestId/response';
    final response = await http.post(url,
        headers: _header,
        body: json.encode({'response': status, 'rating': rating.toInt()}));
    print(response.body);
    if (response.statusCode < 500 && response.statusCode >= 300) {
      throw HttpException(json.decode(response.body)['message']);
    } else if (response.statusCode >= 500) {
      throw HttpException('got internal error');
    }
    fetchAndSetRequests();
  }
}
