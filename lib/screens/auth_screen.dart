import 'dart:io';
import 'dart:math';

import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

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

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              getRandomColor().withOpacity(0.5),
              getRandomColor().withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, 1],
          )),
        ),
        SingleChildScrollView(
            child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 24.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Theme.of(context).primaryColor,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 8,
                                  color: Colors.black26,
                                  offset: Offset(0, 2))
                            ]),
                        child: Text(
                          'Borrow and Lend NITC',
                          style: TextStyle(
                            color:
                                Theme.of(context).accentTextTheme.title.color,
                            fontSize: 30,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: deviceSize.width > 600 ? 2 : 1,
                      child: AuthCard(),
                    )
                  ],
                )))
      ]),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _loginKey = GlobalKey(), _signupKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': ''};
  Map<String, String> _signupData = {
    'email': '',
    'password': '',
    'name': '',
    'contact': '',
    'address': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('An Error Occured'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ]));
  }

  void _showMessageDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text('Message'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okay'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ]));
  }

  Future<void> _submit() async {
    if (_authMode == AuthMode.Login) {
      if (!_loginKey.currentState.validate()) {
        return;
      }
    }
    if (_authMode == AuthMode.Signup) {
      if (!_signupKey.currentState.validate()) {
        return;
      }
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        _loginKey.currentState.save();
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email'], _authData['password']);
      }
      if (_authMode == AuthMode.Signup) {
        _signupKey.currentState.save();
        await Provider.of<Auth>(context, listen: false).signUp(_signupData);
        _switchAuthMode();
        _showMessageDialog('Signup Successfull');
      }
    } on HttpException catch (error) {
      _showErrorDialog('http: ' + error.message);
    } catch (error) {
      print(error.toString());
      _showErrorDialog('something gone wrong:screen');
    }
    // will login or signup here
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
    _passwordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 620 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: _authMode == AuthMode.Login
            ? Form(
                key: _loginKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@nitc.ac.in')) {
                            return 'Invalid email';
                          }
                        },
                        onSaved: (value) {
                          _authData['email'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty || value.length < 5) {
                            return 'Password is too short';
                          }
                        },
                        onSaved: (value) {
                          _authData['password'] = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        RaisedButton(
                          child: Text('Login'),
                          onPressed: _submit,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                          color: Theme.of(context).primaryColor,
                          textColor:
                              Theme.of(context).primaryTextTheme.button.color,
                        ),
                      FlatButton(
                        child: Text('SIGNUP INSTEAD'),
                        onPressed: _switchAuthMode,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textColor: Theme.of(context).primaryColor,
                      )
                    ],
                  ),
                ),
              )
            : Form(
                key: _signupKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'E-mail'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@nitc.ac.in')) {
                            return 'Invalid email';
                          }
                        },
                        onSaved: (value) {
                          _signupData['email'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value.isEmpty || value.length < 5) {
                            return 'Password is too short';
                          }
                        },
                        onSaved: (value) {
                          _signupData['password'] = value;
                        },
                      ),
                      TextFormField(
                        decoration:
                            InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (value) {
                          if (_passwordController.text != value) {
                            return 'Password do not match';
                          }
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 3) {
                            return 'Name length not correct';
                          }
                        },
                        onSaved: (value) {
                          _signupData['name'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Contact'),
                        validator: (value) {
                          if (value.isEmpty || value.length != 10) {
                            return 'Enter correct mobile no.';
                          }
                        },
                        onSaved: (value) {
                          _signupData['contact'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value.isEmpty || value.length < 3) {
                            return 'Address to short';
                          }
                        },
                        onSaved: (value) {
                          _signupData['address'] = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        RaisedButton(
                          child: Text('Sign Up'),
                          onPressed: _submit,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 8.0),
                          color: Theme.of(context).primaryColor,
                          textColor:
                              Theme.of(context).primaryTextTheme.button.color,
                        ),
                      FlatButton(
                        child: Text('LOGIN INSTEAD'),
                        onPressed: _switchAuthMode,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textColor: Theme.of(context).primaryColor,
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
