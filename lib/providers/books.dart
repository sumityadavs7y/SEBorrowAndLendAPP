import 'dart:convert';
import 'dart:io';

import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum Category { NOVEL, FICTION, SCIFI, COMPUTERSCIENCE }

class Book {
  final int id;
  final String title;
  final String author;
  final Category category;
  final String publication;
  final String edition;
  final DateTime tillDate;
  int ownerId;
  String ownerName;
  String ownerContact;

  Book(
      {this.id,
      this.title,
      this.author,
      this.category,
      this.publication,
      this.edition,
      this.tillDate});

  Book.withOwnerDetail(
      {this.id,
      this.title,
      this.author,
      this.category,
      this.publication,
      this.edition,
      this.tillDate,
      this.ownerId,
      this.ownerName,
      this.ownerContact});

  Map<String, dynamic> toJsonDisplay() {
    DateFormat format = new DateFormat("dd-MM-yyyy");
    return {
      'Title': title,
      'Author': author,
      'Category': category,
      'Publication': publication,
      'Edition': edition,
      'Available till': format.format(tillDate),
      'Owner name': ownerName,
      'Owner contact': ownerContact
    };
  }
}

class MyBooks with ChangeNotifier {
  List<Book> _books = [];
  List<Book> _dueBooks = [];
  static DateFormat format = new DateFormat("dd-MM-yyyy");

  List<Book> get books {
    return _books;
  }

  List<Book> get dueBooks {
    return _dueBooks;
  }

  final int userId;

  MyBooks(this.userId, this._books);

  Map<String, String> get _header {
    return {'Content-Type': 'application/json'};
  }

  Future<void> saveBook(Book newBook) async {
    final String url = Auth.domain + '/book';
    final response = await http.post(url,
        headers: _header,
        body: json.encode({
          'title': newBook.title,
          'author': newBook.author,
          'category': newBook.category.toString().split('.').last,
          'publication': newBook.publication,
          'edition': newBook.edition,
          'till_date': format.format(newBook.tillDate),
          'user_id': userId
        }));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final responseData = json.decode(response.body);
      newBook = Book(
          id: responseData['book_id'],
          title: newBook.title,
          author: newBook.author,
          category: newBook.category,
          publication: newBook.publication,
          edition: newBook.edition,
          tillDate: newBook.tillDate);
      _books.add(newBook);
      notifyListeners();
    } else {
      throw HttpException(json.decode(response.body)['message']);
    }
  }

  Future<void> fetchAndSetMyBooks() async {
    List<Book> _loadedBooks = [];
    final String url = Auth.domain + '/user/' + userId.toString() + '/books';
    final response = await http.get(
      url,
      headers: _header,
    );
    final rawBooks = json.decode(response.body)['books'];
    rawBooks.forEach((bookData) {
      _loadedBooks.add(Book(
          id: bookData['id'],
          title: bookData['title'],
          author: bookData['author'],
          edition: bookData['edition'],
          category: Category.values.firstWhere(
              (e) => e.toString() == 'Category.' + bookData['category']),
          publication: bookData['publication'],
          tillDate: format.parse(bookData['till_date'])));
    });
    _books = _loadedBooks;
    notifyListeners();
  }

  Future<void> fetchAndSetDueBooks() async {
    List<Book> _loadedBooks = [];
    final String url = Auth.domain + '/user/$userId/duebooks';
    final response = await http.get(
      url,
      headers: _header,
    );
    final rawBooks = json.decode(response.body)['books'];
    rawBooks.forEach((bookData) {
      _loadedBooks.add(Book.withOwnerDetail(
          id: bookData['id'],
          title: bookData['title'],
          edition: bookData['edition'],
          author: bookData['author'],
          category: Category.values.firstWhere(
              (e) => e.toString() == 'Category.' + bookData['category']),
          publication: bookData['publication'],
          tillDate: format.parse(bookData['till_date']),
          ownerId: bookData['owner']['id'],
          ownerName: bookData['owner']['name'],
          ownerContact: bookData['owner']['contact']));
    });
    _dueBooks = _loadedBooks;
    notifyListeners();
  }

  Future<void> deleteBook(int bookId) async {
    final String url = Auth.domain + '/book/$bookId';
    final response = await http.delete(url);
    print(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      fetchAndSetMyBooks();
    } else {
      throw HttpException('Got Some error');
    }
  }

  Future<List<Book>> searchBook(String category, String text) async {
    final String url =
        Auth.domain + '/user/$userId/search/$category/${text.toLowerCase()}';
    final response = await http.get(url, headers: _header);
    List<Book> _loadedBooks = [];
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final rawBooks = json.decode(response.body)['books'];
      rawBooks.forEach((bookData) {
        _loadedBooks.add(Book.withOwnerDetail(
            id: bookData['id'],
            title: bookData['title'],
            edition: bookData['edition'],
            author: bookData['author'],
            category: Category.values.firstWhere(
                (e) => e.toString() == 'Category.' + bookData['category']),
            publication: bookData['publication'],
            tillDate: format.parse(bookData['till_date']),
            ownerId: bookData['owner']['id'],
            ownerName: bookData['owner']['name'],
            ownerContact: bookData['owner']['contact']));
      });
    } else {
      throw HttpException('Got Some error');
    }
    return _loadedBooks;
  }

  Future<Book> getBookDetail(int bookId) async {
    final String url = Auth.domain + '/book/$bookId';
    final response = await http.get(url, headers: _header);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final bookData = json.decode(response.body);
      return Book.withOwnerDetail(
          id: bookData['id'],
          title: bookData['title'],
          edition: bookData['edition'],
          author: bookData['author'],
          category: Category.values.firstWhere(
              (e) => e.toString() == 'Category.' + bookData['category']),
          publication: bookData['publication'],
          tillDate: format.parse(bookData['till_date']),
          ownerId: bookData['owner']['id'],
          ownerName: bookData['owner']['name'],
          ownerContact: bookData['owner']['contact']);
    } else {
      throw HttpException('Got Some error');
    }
  }

  Future<void> sendBlockRequest(int bookId) async {
    final String url = Auth.domain + '/block/book/$bookId';
    final response = await http.get(url, headers: _header);
    if (response.statusCode >= 300) {
      final responseData = json.decode(response.body);
      throw HttpException(responseData['messsage']);
    }
  }
}
