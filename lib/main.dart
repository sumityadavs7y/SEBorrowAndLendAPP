import 'package:borrow_and_lend_nitc/providers/return_request.dart';
import 'package:borrow_and_lend_nitc/providers/transactions.dart';
import 'package:borrow_and_lend_nitc/screens/about_screen.dart';
import 'package:borrow_and_lend_nitc/screens/return_request_screen.dart';
import 'package:borrow_and_lend_nitc/screens/transaction_screen.dart';
import 'package:borrow_and_lend_nitc/screens/update_info_screen.dart';

import './providers/books.dart';
import './providers/borrow_request.dart';
import './screens/auth_screen.dart';
import './screens/borrow_request_screen.dart';
import './screens/dashboard_screen.dart';
import './screens/due_book_screen.dart';
import './screens/my_book_screen.dart';
import './screens/search_screen.dart';
import './screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, MyBooks>(
          create: (ctx) => MyBooks(null, []),
          update: (ctx, auth, previousBooks) => MyBooks(
              auth.userId, previousBooks == null ? [] : previousBooks.books),
        ),
        ChangeNotifierProxyProvider<Auth, BorrowRequests>(
          create: (ctx) => BorrowRequests(null, []),
          update: (ctx, auth, previousRequests) => BorrowRequests(auth.userId,
              previousRequests == null ? [] : previousRequests.requests),
        ),
        ChangeNotifierProxyProvider<Auth, ReturnRequests>(
          create: (ctx) => ReturnRequests(null, []),
          update: (ctx, auth, previousRequests) => ReturnRequests(auth.userId,
              previousRequests == null ? [] : previousRequests.requests),
        ),
        ChangeNotifierProxyProvider<Auth, Transactions>(
          create: (ctx) => Transactions(null, []),
          update: (ctx, auth, previousTransactions) => Transactions(
              auth.userId,
              previousTransactions == null
                  ? []
                  : previousTransactions.transactions),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: 'Borrow and Lend NITC',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              accentColor: Colors.deepOrange,
            ),
            home: auth.isAuth
                ? DashboardScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              DashboardScreen.routeName: (ctx) => DashboardScreen(),
              SearchScreen.routeName: (ctx) => SearchScreen(),
              MyBookScreen.routeName: (ctx) => MyBookScreen(),
              BorrowRequestScreen.routeName: (ctx) => BorrowRequestScreen(),
              DueBookScreen.routeName: (ctx) => DueBookScreen(),
              ReturnRequestScreen.routeName: (ctx) => ReturnRequestScreen(),
              TransactionScreen.routeName: (ctx) => TransactionScreen(),
              UpdateInfoScreen.routeName: (ctx) => UpdateInfoScreen(),
              AboutScreen.routeName: (ctx) => AboutScreen(),
            },
          );
        },
      ),
    );
  }
}
