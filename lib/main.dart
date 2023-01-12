import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './widgets/new_transaction.dart';
import './widgets/transaction_list.dart';
import './widgets/chart.dart';
import './models/transaction.dart';
import './theme/theme_model.dart';

void main() {
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitUp,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeModel(),
      child: Consumer<ThemeModel>(
          builder: (context, ThemeModel themeNotifier, child) {
        return MaterialApp(
          title: 'Personal Expenses',
          theme: themeNotifier.themeDark ? ThemeData.dark() : ThemeData.light(),
          debugShowCheckedModeBanner: false,

          home: MyHomePage(),
        );
      }),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver{
  final List<Transaction> _userTransactions = [

  ];
  bool _showChart = false;
@override
  didChangeAppLifecycleState(AppLifecycleState state){
print(state);
}
@override
  void initState() {
   WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
@override
 dispose(){
  WidgetsBinding.instance.removeObserver(this);
  super.dispose();
 }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });
  }

  List<Widget> _buildLandscapeContent(
      MediaQueryData mediaQuery, AppBar appBar, Widget txListWidget) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Show Chart',
          ),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget
    ];
  }

  List<Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

Widget _buildAppBar (ThemeModel themeNotifier) {
    return Platform.isIOS
        ? CupertinoNavigationBar(
      middle: Text(
        'Personal Expenses',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTransaction(context),
          ),
        ],
      ),
    )
        : AppBar(
      title: Text(
        'Personal Expenses',
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
        Switch(
          value: themeNotifier.themeDark,
          onChanged: (value) {
            setState(() {
              themeNotifier.themeDark = value;
            });
          },
        ),
      ],
    );
}

  @override
  Widget build(BuildContext context) {
    print('build() MyHomePageState');

    return Consumer<ThemeModel>(
        builder: (context, ThemeModel themeNotifier, child) {
      final mediaQuery = MediaQuery.of(context);
      final isLandscape = mediaQuery.orientation == Orientation.landscape;
      final PreferredSizeWidget appBar = _buildAppBar(themeNotifier);
      final txListWidget = Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.7,
        child: TransactionList(_userTransactions, _deleteTransaction),
      );
      final pageBody = SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isLandscape)
                ..._buildLandscapeContent(mediaQuery, appBar, txListWidget)
             else
                ..._buildPortraitContent(mediaQuery, appBar, txListWidget),
            ],
          ),
        ),
      );
      return Platform.isIOS
          ? CupertinoPageScaffold(
              child: pageBody,
              navigationBar: appBar,
            )
          : Scaffold(
              appBar: appBar,
              body: pageBody,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Platform.isIOS
                  ? Container()
                  : FloatingActionButton(
                      child: Icon(Icons.add),
                      onPressed: () => _startAddNewTransaction(context),
                    ),
            );
    });
  }
}