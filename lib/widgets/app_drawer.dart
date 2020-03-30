import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:borrow_and_lend_nitc/screens/about_screen.dart';
import 'package:borrow_and_lend_nitc/screens/update_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(title: Text('NITC'), automaticallyImplyLeading: false),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Update info'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(UpdateInfoScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About Project'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AboutScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
