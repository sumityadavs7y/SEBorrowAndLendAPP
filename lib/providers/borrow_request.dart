import 'dart:convert';
import 'dart:io';

import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BorrowRequest {
  final int id;
  final String bookTitle;
  final DateTime date;
  final String senderName;
  final int senderMeritPoint;
  final String senderContact;

  BorrowRequest(
      {this.id,
      this.bookTitle,
      this.date,
      this.senderName,
      this.senderMeritPoint,
      this.senderContact});
}

class BorrowRequests with ChangeNotifier {
  final int userId;
  List<BorrowRequest> _requests = [];
  static DateFormat format = new DateFormat("dd-MM-yyyy");

  List<BorrowRequest> get requests {
    return _requests;
  }

  BorrowRequests(this.userId, this._requests);

  Map<String, String> get _header {
    return {"Content-Type": "application/json"};
  }

  Future<void> fetchAndSetRequests() async {
    List<BorrowRequest> _loadedRequest = [];
    final String url = Auth.domain + "/user/$userId/borrowrequests";
    final response = await http.get(url);
    print(response.body);
    final rawRequests = json.decode(response.body)['requests'];
    rawRequests.forEach((requestData) {
      print('found 1');
      _loadedRequest.add(BorrowRequest(
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

  Future<void> sendBorrowRequest(int bookId) async {
    final String url = Auth.domain + '/borrowrequest';
    final response = await http.post(url,
        headers: _header,
        body: json.encode({"sent_by": userId, "book_id": bookId}));
    print(bookId);
    print(userId);
    print(response.body);
    if (response.statusCode < 500 && response.statusCode >= 300) {
      throw HttpException(json.decode(response.body)['message']);
    } else if (response.statusCode >= 500) {
      throw HttpException('got internal error');
    }
  }

  Future<void> respondToRequest(int requestId, bool status) async {
    final String url = Auth.domain + '/borrowrequest/$requestId/response';
    final response = await http.post(url,
        headers: _header, body: json.encode({'response': status}));
    if (response.statusCode < 500 && response.statusCode >= 300) {
      throw HttpException(json.decode(response.body)['message']);
    } else if (response.statusCode >= 500) {
      throw HttpException('got internal error');
    }
    fetchAndSetRequests();
  }
}
