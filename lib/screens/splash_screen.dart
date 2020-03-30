import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 150,
            child: Image(
              fit: BoxFit.fitWidth,
              image: AssetImage('icon/icon.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Borrow and Lend NITC',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
          )
        ],
      )),
    );
  }
}
