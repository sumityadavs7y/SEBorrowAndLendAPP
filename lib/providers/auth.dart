import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _accessToken;
  String _refreshToken;
  int _userId;
  DateTime _expiryDate;
  Timer _authTimer;

  String name;
  String contact;
  String address;

  static String domain = "https://serestapi.herokuapp.com";

  String get accessToken {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _accessToken != null) {
      return _accessToken;
    }
    return null;
  }

  bool get isAuth {
    return accessToken != null;
  }

  int get userId {
    return _userId;
  }

  Map<String, String> get _header {
    return {'Content-Type': 'application/json'};
  }

  Future<void> fetchAndSetUserInfo() async {
    final url = domain + '/user/$userId';
    try {
      final response = await http.get(url, headers: _header);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        name = responseData['name'];
        contact = responseData['contact'];
        address = responseData['address'];
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateUserInfo(
      String name, String contact, String address) async {
    final url = domain + '/user/$userId';
    final response = await http.put(url,
        headers: _header,
        body: json
            .encode({"name": name, "contact": contact, "address": address}));
    if (response.statusCode != 200) {
      throw HttpException('Can\'t update');
    }
  }

  Future<void> signUp(Map<String, String> signupData) async {
    final url = domain + '/register';
    try {
      final response = await http.post(url,
          headers: _header,
          body: json.encode({
            'email': signupData['email'],
            'password': signupData['password'],
            'name': signupData['name'],
            'contact': signupData['contact'],
            'address': signupData['address']
          }));
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(responseData.containsKey('message')
            ? responseData['message']
            : 'dont know');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    final url = domain + "/login";
    try {
      final response = await http.post(url,
          headers: _header,
          body: json.encode({'email': email, 'password': password}));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(response.body);
      }
      final responseData = json.decode(response.body);
      _accessToken = responseData['access_token'];
      _refreshToken = responseData['refresh_token'];
      _userId = responseData['user_id'];
      _expiryDate =
          DateTime.now().add(Duration(minutes: responseData['expires_in']));
      _autoGetAccessToken();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData'));
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    _accessToken = extractedUserData['accessToken'];
    _refreshToken = extractedUserData['refreshToken'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    if (expiryDate.isBefore(DateTime.now())) {
      try {
        await _getAccessToken();
      } catch (error) {
        await logout();
        return false;
      }
    }
    notifyListeners();
    _autoGetAccessToken();
    return true;
  }

  void _autoGetAccessToken() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(minutes: timeToExpiry), _getAccessToken);
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  Future<void> _getAccessToken() async {
    final url = domain + '/refresh';
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refresh_token': _refreshToken}));
      if (response.statusCode != 200) {
        logout();
        throw HttpException('error in getting access token through refresh');
      }
      final responseData = json.decode(response.body);
      _accessToken = responseData['access_token'];
      _expiryDate =
          DateTime.now().add(Duration(minutes: responseData['expires_in']));
      notifyListeners();
      _autoGetAccessToken();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (error) {
      logout();
      throw error;
    }
  }
}
