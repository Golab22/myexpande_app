import 'package:flutter/material.dart';
import 'dart:math';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class TrasactionItem extends StatefulWidget {
  const TrasactionItem({
    Key key,
    @required this.transaction,
    @required this.deleteTx,
  }) : super(key: key);

  final Transaction transaction;
  final Function deleteTx;

  @override
  State<TrasactionItem> createState() => _TrasactionItemState();
}

class _TrasactionItemState extends State<TrasactionItem> {

  Color _bgColor;
  @override
  void initState() {
    const availableColors = [Colors.red, Colors.black, Colors.blue, Colors.amber];
    _bgColor = availableColors[Random().nextInt(4)];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _bgColor,
          radius: 30,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: FittedBox(
              child: Text('\$${widget.transaction.amount}'),
            ),
          ),
        ),
        title: Text(
          widget.transaction.title,
          // style: Theme.of(context).textTheme.title,
        ),
        subtitle: Text(
          DateFormat.yMMMd().format(widget.transaction.date),
        ),
        trailing: MediaQuery.of(context).size.width > 460
            ? TextButton.icon(
                icon: Icon(Icons.delete),
                label: Text('Delete'),
                // textColor: Theme.of(context).errorColor,
                onPressed: () => widget.deleteTx(widget.transaction.id),
              )
            : IconButton(
                icon: Icon(Icons.delete),
                color: Theme.of(context).errorColor,
                onPressed: () => widget.deleteTx(widget.transaction.id),
              ),
      ),
    );
  }
}
