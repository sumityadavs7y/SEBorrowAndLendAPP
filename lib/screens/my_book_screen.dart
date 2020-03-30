import 'package:borrow_and_lend_nitc/providers/books.dart';
import 'package:borrow_and_lend_nitc/widgets/book_form_sheet.dart';
import 'package:borrow_and_lend_nitc/widgets/book_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyBookScreen extends StatelessWidget {
  static const routeName = '/myBook';

  void _startAddBook(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return BookFormSheet();
        });
  }

  Future<void> _refreshBooks(BuildContext context) async {
    await Provider.of<MyBooks>(context, listen: false).fetchAndSetMyBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Books'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddBook(context),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshBooks(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<MyBooks>(
                      builder: (ctx, bookData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: bookData.books.length == 0
                            ? Center(child: Text('No Book Added'))
                            : ListView.builder(
                                itemCount: bookData.books.length,
                                itemBuilder: (_, i) {
                                  return Column(
                                    children: <Widget>[
                                      BookItem(bookData.books[i]),
                                      Divider(),
                                    ],
                                  );
                                }),
                      ),
                    ),
                    onRefresh: () => _refreshBooks(context),
                  ),
      ),
    );
  }
}
