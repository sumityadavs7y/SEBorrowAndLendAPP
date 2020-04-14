import 'dart:math';

import 'package:borrow_and_lend_nitc/providers/transactions.dart';
import 'package:borrow_and_lend_nitc/screens/borrow_request_screen.dart';
import 'package:borrow_and_lend_nitc/screens/due_book_screen.dart';
import 'package:borrow_and_lend_nitc/screens/return_request_screen.dart';
import 'package:borrow_and_lend_nitc/screens/search_screen.dart';
import 'package:borrow_and_lend_nitc/screens/transaction_screen.dart';
import 'package:borrow_and_lend_nitc/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_book_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isInit = false;

  @override
  void didChangeDependencies() {
    if (!isInit) {
      Provider.of<Transactions>(context, listen: false)
          .isAnyDue()
          .then((isdue) {
        if (isdue) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Alert'),
              content: Text(
                  "You have not returned the book before their last availibility date. Please return your merit points will be reduced (2 points per day)."),
              actions: <Widget>[
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
        }
      });
      isInit = true;
    }
  }

  MaterialColor getRandomColor() {
    List<MaterialColor> colors = [
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.deepOrange,
      Colors.green,
      Colors.amber,
      Colors.deepPurple
    ];
    return colors[Random().nextInt(colors.length)];
  }

  Widget getGridItem(BuildContext ctx, String title, Function navigate) {
    return InkWell(
      onTap: () => navigate(),
      splashColor: Theme.of(ctx).primaryColor,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Text(
          title,
          style: Theme.of(ctx).textTheme.title,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [getRandomColor().withOpacity(0.3), getRandomColor()],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
          child: Container(
        height: MediaQuery.of(context).size.height,
        child: GridView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            getGridItem(context, 'Search Book',
                () => Navigator.of(context).pushNamed(SearchScreen.routeName)),
            getGridItem(context, 'My Book',
                () => Navigator.of(context).pushNamed(MyBookScreen.routeName)),
            getGridItem(
                context,
                'Borrow Requests',
                () => Navigator.of(context)
                    .pushNamed(BorrowRequestScreen.routeName)),
            getGridItem(
                context,
                'Return Requests',
                () => Navigator.of(context)
                    .pushNamed(ReturnRequestScreen.routeName)),
            getGridItem(context, 'Due Books',
                () => Navigator.of(context).pushNamed(DueBookScreen.routeName)),
            getGridItem(
                context,
                'Summary',
                () => Navigator.of(context)
                    .pushNamed(TransactionScreen.routeName)),
          ],
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
        ),
      )),
    );
  }
}
