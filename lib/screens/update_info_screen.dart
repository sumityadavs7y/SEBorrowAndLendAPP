import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class UpdateInfoScreen extends StatefulWidget {
  static const String routeName = '/updateinfo';

  @override
  _UpdateInfoScreenState createState() => _UpdateInfoScreenState();
}

class _UpdateInfoScreenState extends State<UpdateInfoScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    Provider.of<Auth>(context, listen: false).fetchAndSetUserInfo();
    super.initState();
  }

  void showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('An Error Occured'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ]));
  }

  void _updateUserInfo(BuildContext ctx) async {
    _formKey.currentState.validate();
    _formKey.currentState.save();
    try {
      await Provider.of<Auth>(ctx, listen: false).updateUserInfo(
          nameController.text, contactController.text, addressController.text);
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                  title: Text('Message'),
                  content: Text('info updated'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ]));
    } catch (error) {
      showErrorDialog(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Info')),
      body: FutureBuilder(
        future: Provider.of<Auth>(context, listen: false).fetchAndSetUserInfo(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (dataSnapshot.error != null) {
            return Center(
              child: Text('error occured'),
            );
          } else {
            nameController.text =
                Provider.of<Auth>(context, listen: false).name;
            addressController.text =
                Provider.of<Auth>(context, listen: false).address;
            contactController.text =
                Provider.of<Auth>(context, listen: false).contact;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Name'),
                    controller: nameController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 3) {
                        return 'Length not enough';
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Contact'),
                    controller: contactController,
                    validator: (value) {
                      if (value.isEmpty || value.length != 10) {
                        return 'Contact not current';
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Address'),
                    controller: addressController,
                    validator: (value) {
                      if (value.isEmpty || value.length <= 5) {
                        return 'Address is not valid';
                      }
                    },
                  ),
                  RaisedButton(
                      child: Text('Update'),
                      onPressed: () => _updateUserInfo(context))
                ]),
              ),
            );
          }
        },
      ),
    );
  }
}
