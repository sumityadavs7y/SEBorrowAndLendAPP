import 'package:borrow_and_lend_nitc/providers/transactions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionScreen extends StatelessWidget {
  static const routeName = '/transactions';

  Future<void> _refreshTransactions(BuildContext context) async {
    await Provider.of<Transactions>(context, listen: false)
        .fetchAndSetTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Summary')),
      body: FutureBuilder(
        future: _refreshTransactions(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<Transactions>(
                      builder: (ctx, transactionData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: transactionData.transactions.length == 0
                            ? Center(child: Text('No Book Added'))
                            : ListView.builder(
                                itemCount: transactionData.transactions.length,
                                itemBuilder: (_, i) {
                                  return Column(
                                    children: <Widget>[
                                      TransactionItem(
                                          transactionData.transactions[i]),
                                      Divider(),
                                    ],
                                  );
                                }),
                      ),
                    ),
                    onRefresh: () => _refreshTransactions(context),
                  ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  TransactionItem(this.transaction);

  void _showTransactionDetail(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          return TransactionDetailSheet(transaction: transaction);
        });
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    DateFormat format = new DateFormat("dd-MM-yyyy");
    String status = transaction.isBookOwner ? 'Lent' : 'Borrowed';
    String returnedDate = transaction.returnedDate==null?'not returned' : format.format(transaction.returnedDate);
    return ListTile(
        title: Text(status + ' : ' + transaction.bookName),
        subtitle: Text(
            "Borrowed: ${format.format(transaction.borrowedDate)}, Returned: $returnedDate"),
        trailing: IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => _showTransactionDetail(context),
          color: Theme.of(context).primaryColor,
        ));
  }
}

class TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailSheet({this.transaction});

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    transaction.toJson().forEach((k, v) => list.add(Text(
          '$k: $v',
          style: Theme.of(context).textTheme.title,
        )));
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }
}
