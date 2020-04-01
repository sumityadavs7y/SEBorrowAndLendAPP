import 'package:borrow_and_lend_nitc/providers/books.dart';
import 'package:borrow_and_lend_nitc/providers/borrow_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBookItem extends StatelessWidget {
  final Book book;
  SearchBookItem(this.book);

  void _showBookDetail(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return BookDetailSheet(bookId: book.id);
        });
  }

  void _showDialog(BuildContext context,String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
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
              icon: Icon(Icons.send),
              onPressed: () async {
                try {
                  await Provider.of<BorrowRequests>(context, listen: false)
                      .sendBorrowRequest(book.id);
                  scaffold
                      .showSnackBar(SnackBar(content: Text('request sent')));
                } catch (error) {
                  _showDialog(context, "An Error Occured",error.toString());
                }
              },
              color: Theme.of(context).primaryColor,
            )
          ],
        ));
  }
}

class BookDetailSheet extends StatelessWidget {
  final int bookId;
  final BuildContext ctx;
  const BookDetailSheet({this.ctx,this.bookId});

  void _showDialog(BuildContext context,String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
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
    return FutureBuilder(
      future: Provider.of<MyBooks>(context).getBookDetail(bookId),
      builder: (_, bookSnapShot) {
        if (bookSnapShot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        else {
          if (bookSnapShot.error != null) {
            return Center(child: Text('An error occured'));
          } else {
            Book book = bookSnapShot.data;
            List<Widget> list = [];
            book.toJsonDisplay().forEach((k, v) => list.add(Text(
                  '$k: $v',
                  style: Theme.of(context).textTheme.title,
                )));
            list.add(RaisedButton(
              child: Text('Report'),
              onPressed: () async {
                try{
                  await Provider.of<MyBooks>(context, listen: false).sendBlockRequest(bookId);
                  _showDialog(context,'Message','report sent');
                }catch(error){
                  _showDialog(context,'An Error Occured','report sent failed');
                }
              },
            ));
            return Container(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list,
              ),
            );
          }
        }
      },
    );
  }
}
