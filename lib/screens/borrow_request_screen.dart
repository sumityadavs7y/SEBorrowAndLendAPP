import 'package:borrow_and_lend_nitc/providers/borrow_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BorrowRequestScreen extends StatelessWidget {
  static const routeName = '/borrowRequests';

  Future<void> _refreshRequests(BuildContext context) async {
    await Provider.of<BorrowRequests>(context, listen: false)
        .fetchAndSetRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Borrow Requests')),
      body: FutureBuilder(
        future: _refreshRequests(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<BorrowRequests>(
                      builder: (ctx, requestData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: requestData.requests.length == 0
                            ? Center(child: Text('No requests'))
                            : ListView.builder(
                                itemCount: requestData.requests.length,
                                itemBuilder: (_, i) {
                                  return Column(children: <Widget>[
                                    RequestItem(requestData.requests[i]),
                                    Divider()
                                  ]);
                                }),
                      ),
                    ),
                    onRefresh: () => _refreshRequests(context),
                  ),
      ),
    );
  }
}

class RequestItem extends StatelessWidget {
  final BorrowRequest request;

  RequestItem(this.request);

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
      title: Text('Sent by: ${request.senderName} for ${request.bookTitle}'),
      subtitle: Text('sender\'s merit point: ${request.senderMeritPoint}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              try {
                Provider.of<BorrowRequests>(context, listen: false)
                    .respondToRequest(request.id, true);
                scaffold.showSnackBar(SnackBar(content: Text('accepted')));
              } catch (error) {
                _showErrorDialog(context, error.toString());
              }
            },
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              try {
                Provider.of<BorrowRequests>(context, listen: false)
                    .respondToRequest(request.id, false);
                scaffold.showSnackBar(SnackBar(content: Text('rejected')));
              } catch (error) {
                _showErrorDialog(context, error.toString());
              }
            },
            color: Theme.of(context).errorColor,
          ),
        ],
      ),
    );
  }
}
