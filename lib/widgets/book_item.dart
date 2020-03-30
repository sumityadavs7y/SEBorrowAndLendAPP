import 'package:borrow_and_lend_nitc/providers/books.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookItem extends StatelessWidget {
  final Book book;

  BookItem(this.book);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
        title: Text(book.title),
        subtitle: Text('Category: ' +
            '${book.category.toString().split('.').last}' +
            ', Author: ' +
            '${book.author}'),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            try {
              await Provider.of<MyBooks>(context, listen: false)
                  .deleteBook(book.id);
            } catch (error) {
              scaffold.showSnackBar(SnackBar(
                content: Text('deleting failed!', textAlign: TextAlign.center),
              ));
            }
          },
          color: Theme.of(context).errorColor,
        ));
  }
}
