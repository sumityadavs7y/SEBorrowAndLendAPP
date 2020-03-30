import 'dart:io';

import 'package:borrow_and_lend_nitc/providers/books.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookFormSheet extends StatefulWidget {
  @override
  _BookFormSheetState createState() => _BookFormSheetState();
}

class _BookFormSheetState extends State<BookFormSheet> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate;
  Category _selectedCategory;
  var _editedBook = Book(
      id: null,
      title: '',
      author: '',
      category: null,
      publication: '',
      edition: '',
      tillDate: null);

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now().add(Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 1))
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      } else {
        setState(() {
          _selectedDate = pickedDate;
        });
      }
    });
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

  Future<void> _saveForm() async {
    _formKey.currentState.validate();
    if (_selectedDate == null) {
      showErrorDialog('Can\'t leave date field Empty');
      return;
    }
    if (_selectedCategory == null) {
      showErrorDialog('Can\'t leave category field Empty');
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    _editedBook = Book(
        id: _editedBook.id,
        title: _editedBook.title.toLowerCase(),
        author: _editedBook.author.toLowerCase(),
        category: _selectedCategory,
        publication: _editedBook.publication,
        edition: _editedBook.edition,
        tillDate: _selectedDate);
    try {
      await Provider.of<MyBooks>(context, listen: false).saveBook(_editedBook);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(error.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Add Book',
                            style: Theme.of(context).textTheme.title,
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Title'),
                            onSaved: (value) {
                              _editedBook = Book(
                                  id: _editedBook.id,
                                  title: value,
                                  author: _editedBook.author,
                                  category: _editedBook.category,
                                  publication: _editedBook.publication,
                                  edition: _editedBook.edition,
                                  tillDate: _editedBook.tillDate);
                            },
                            validator: (value) {
                              if (value.isEmpty || value.length < 3) {
                                return 'length not enough';
                              }
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(labelText: 'Author'),
                            onSaved: (value) {
                              _editedBook = Book(
                                  id: _editedBook.id,
                                  title: _editedBook.title,
                                  author: value,
                                  category: _editedBook.category,
                                  publication: _editedBook.publication,
                                  edition: _editedBook.edition,
                                  tillDate: _editedBook.tillDate);
                            },
                            validator: (value) {
                              if (value.isEmpty || value.length < 3) {
                                return 'length not enough';
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: DropdownButton<Category>(
                              isExpanded: true,
                              hint: Text('Category'),
                              underline: Container(
                                height: 1,
                                color: Colors.grey,
                              ),
                              value: _selectedCategory,
                              icon: Icon(Icons.arrow_drop_down),
                              elevation: 16,
                              onChanged: (Category newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                              items: Category.values
                                  .map<DropdownMenuItem<Category>>(
                                      (Category value) {
                                return DropdownMenuItem<Category>(
                                    value: value,
                                    child: Text(value.toString()));
                              }).toList(),
                            ),
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Publication'),
                            onSaved: (value) {
                              _editedBook = Book(
                                  id: _editedBook.id,
                                  title: _editedBook.title,
                                  author: _editedBook.author,
                                  category: _editedBook.category,
                                  publication: value,
                                  edition: _editedBook.edition,
                                  tillDate: _editedBook.tillDate);
                            },
                            validator: (value) {
                              if (value.isEmpty || value.length < 3) {
                                return 'length not enough';
                              }
                            },
                          ),
                          TextFormField(
                              decoration: InputDecoration(labelText: 'Edition'),
                              onSaved: (value) {
                                _editedBook = Book(
                                    id: _editedBook.id,
                                    title: _editedBook.title,
                                    author: _editedBook.author,
                                    category: _editedBook.category,
                                    publication: _editedBook.publication,
                                    edition: value,
                                    tillDate: _editedBook.tillDate);
                              },
                              validator: (value) {
                                if (value.isEmpty || value.length < 3) {
                                  return 'length not enough';
                                }
                              }),
                          Container(
                            height: 70,
                            child: Row(
                              children: <Widget>[
                                Text(_selectedDate == null
                                    ? 'No Date Chosen'
                                    : 'Picked Date: ${DateFormat.yMd().format(_selectedDate)}'),
                                FlatButton(
                                  child: Text(
                                    'Choose Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _presentDatePicker,
                                )
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              RaisedButton(
                                child: Text('submit'),
                                onPressed: _saveForm,
                              )
                            ],
                          )
                        ],
                      )),
                )),
          );
  }
}
