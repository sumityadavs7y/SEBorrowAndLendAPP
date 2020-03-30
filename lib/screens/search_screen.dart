import 'package:borrow_and_lend_nitc/providers/auth.dart';
import 'package:borrow_and_lend_nitc/providers/books.dart';
import 'package:borrow_and_lend_nitc/widgets/search_book_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedField;
  TextEditingController searchController = TextEditingController();
  List<Book> _books;
  bool _isLoading = false;

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
        ],
      ),
    );
  }

  Future<void> _search() async {
    if (_selectedField == null) {
      _showErrorDialog('Select Search Category');
      return;
    }
    if (searchController.text == null || searchController.text.length == 0) {
      _showErrorDialog('Enter search text');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      List<Book> loadedBooks =
          await Provider.of<MyBooks>(context, listen: false)
              .searchBook(_selectedField, searchController.text);
      setState(() {
        _books = loadedBooks;
        _isLoading = false;
      });
      return;
    } catch (error) {
      _showErrorDialog(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text('Search by'),
                  underline: Container(
                    height: 1,
                    color: Colors.grey,
                  ),
                  value: _selectedField,
                  icon: Icon(Icons.arrow_drop_down),
                  elevation: 16,
                  onChanged: (String newValue) {
                    setState(() {
                      _selectedField = newValue;
                    });
                  },
                  items: ['Author', 'Title', 'Category']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                        value: value.toLowerCase(), child: Text(value));
                  }).toList(),
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Input text'),
                controller: searchController,
              ),
              RaisedButton(
                child: Text('Search'),
                onPressed: _search,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Result',
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _books == null || _books.length == 0
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text('No Search Result.'),
                          ),
                        )
                      : Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _books.length,
                              itemBuilder: (_, i) {
                                return Column(
                                  children: <Widget>[
                                    SearchBookItem(_books[i]),
                                    Divider(),
                                  ],
                                );
                              }),
                        )
            ]),
          ),
        ),
      ),
    );
  }
}
