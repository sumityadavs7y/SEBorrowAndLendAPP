import 'package:borrow_and_lend_nitc/providers/books.dart';
import 'package:borrow_and_lend_nitc/providers/return_request.dart';
import 'package:borrow_and_lend_nitc/widgets/search_book_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DueBookScreen extends StatelessWidget {
  static const String routeName = '/duebooks';

  Future<void> _refreshBooks(BuildContext context) async {
    await Provider.of<MyBooks>(context, listen: false).fetchAndSetDueBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Due Books')),
      body: FutureBuilder(
        future: _refreshBooks(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<MyBooks>(
                      builder: (ctx, dueBookData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: dueBookData.dueBooks.length == 0
                            ? Center(child: Text('No Book Added'))
                            : ListView.builder(
                                itemCount: dueBookData.dueBooks.length,
                                itemBuilder: (_, i) {
                                  return Column(
                                    children: <Widget>[
                                      DueBookItem(dueBookData.dueBooks[i]),
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

class DueBookItem extends StatelessWidget {
  final Book book;

  DueBookItem(this.book);

  void _showBookDetail(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return BookDetailSheet(bookId: book.id);
        });
  }

  void _showErrorDialog(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
        title: Text(book.title),
        subtitle: Text('Category: ' +
            '${book.category.toString().split('.').last}' +
            ', Author: ' +
            '${book.author}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _showBookDetail(context),
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.assignment_return),
              onPressed: () async {
                try {
                  await Provider.of<ReturnRequests>(context, listen: false)
                      .sendReturnRequest(book.id);
                  scaffold
                      .showSnackBar(SnackBar(content: Text('request sent')));
                } catch (error) {
                  _showErrorDialog(context, error.toString());
                }
              },
              color: Theme.of(context).primaryColor,
            ),
          ],
        ));
  }
}
