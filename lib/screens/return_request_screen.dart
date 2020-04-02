import 'package:borrow_and_lend_nitc/providers/return_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

class ReturnRequestScreen extends StatelessWidget {
  static const routeName = '/returnRequests';

  Future<void> _refreshRequests(BuildContext context) async {
    await Provider.of<ReturnRequests>(context, listen: false)
        .fetchAndSetRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Return Requests')),
      body: FutureBuilder(
        future: _refreshRequests(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    child: Consumer<ReturnRequests>(
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
  final ReturnRequest request;
  var rating = 0.0;

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

  void _showRatingDialog(BuildContext context) {
    final scaffold = Scaffold.of(context);
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Rating'),
            content: RatingBar(
                initialRating: 3,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.red,
                      );
                    case 1:
                      return Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.redAccent,
                      );
                    case 2:
                      return Icon(
                        Icons.sentiment_neutral,
                        color: Colors.amber,
                      );
                    case 3:
                      return Icon(
                        Icons.sentiment_satisfied,
                        color: Colors.lightGreen,
                      );
                    case 4:
                      return Icon(
                        Icons.sentiment_very_satisfied,
                        color: Colors.green,
                      );
                  }
                  return Container(
                    child: null,
                  );
                },
                onRatingUpdate: (rate) {
                  rating = rate;
                }),
            actions: <Widget>[
              FlatButton(
                child: Text('Return'),
                onPressed: () {
                  Provider.of<ReturnRequests>(context, listen: false)
                      .respondToRequest(request.id, true, rating: rating);
                  scaffold.showSnackBar(SnackBar(content: Text('accepted')));
                },
              )
            ],
          );
        });
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
                _showRatingDialog(context);
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
                Provider.of<ReturnRequests>(context, listen: false)
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
