import 'dart:convert';

import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Transaction {
  final int id;
  final String bookName;
  final String bookAuthor;
  final String lenderName;
  final String lenderContact;
  final String borrowerName;
  final String borrowerContact;
  final DateTime borrowedDate;
  final DateTime returnedDate;
  final bool isBookOwner;

  Transaction(
      {this.id,
      this.bookName,
      this.bookAuthor,
      this.lenderName,
      this.lenderContact,
      this.borrowerName,
      this.borrowerContact,
      this.borrowedDate,
      this.returnedDate,
      this.isBookOwner});

  Map<String, String> toJson() {
    DateFormat format = new DateFormat("dd-MM-yyyy");
    String returnDate = this.returnedDate==null?'not returned' : format.format(this.returnedDate);
    return {
      "Book name": bookName,
      "Book author": bookAuthor,
      "Lender name": lenderName,
      "Lender contact": lenderContact,
      "Borrower name": borrowerName,
      "Borrower contact": borrowerContact,
      "Borrower date": format.format(borrowedDate),
      "Return date": returnDate
    };
  }
}

class Transactions with ChangeNotifier {
  List<Transaction> _transactions = [];
  static DateFormat format = new DateFormat("dd-MM-yyyy");

  final int userId;

  Transactions(this.userId, this._transactions);

  List<Transaction> get transactions {
    return _transactions;
  }

  Map<String, String> get _header {
    return {"Content-Type": "application/json"};
  }

  Future<bool> isAnyDue() async {
    final String url = Auth.domain + '/user/$userId/isdue';
    final response = await http.get(url, headers: _header);
    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      return responseData['due'];
    }
    return false;
  }

  Future<void> fetchAndSetTransactions() async {
    List<Transaction> _loadedTransaction = [];
    final String url = Auth.domain + '/user/$userId/summary';
    final response = await http.get(url, headers: _header);
    final rawTransactions = json.decode(response.body)['transactions'];
    // print(response.body);
    rawTransactions.forEach((transactionData) {
      print(transactionData['borrow_date']);
      print(transactionData['return_date']);
      _loadedTransaction.add(Transaction(
        id: transactionData['id'],
        bookName: transactionData['book']['title'],
        bookAuthor: transactionData['book']['author'],
        lenderName: transactionData['lender']['name'],
        lenderContact: transactionData['lender']['contact'],
        borrowerName: transactionData['borrower']['name'],
        borrowerContact: transactionData['borrower']['contact'],
        borrowedDate: transactionData['borrow_date'] == null
            ? null
            : format.parse(transactionData['borrow_date']),
        returnedDate: transactionData['return_date'] == null
            ? null
            : format.parse(transactionData['return_date']),
        isBookOwner:
            transactionData['book']['user_id'] == userId ? true : false,
      ));
    });
    _transactions = _loadedTransaction;
    print(_transactions.length);
    notifyListeners();
  }
}
