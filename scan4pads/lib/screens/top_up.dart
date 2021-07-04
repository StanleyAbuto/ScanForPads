import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pad_app/models/bals.dart';
import 'package:pad_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:pad_app/services/database_service.dart';
import 'package:pad_app/models/balanceLists.dart';

import '../constants.dart';

class TopUp extends StatefulWidget {
  final String namae, mimoto;

  TopUp({Key key, @required this.namae, this.mimoto}) : super(key: key);

  @override
  _TopUpState createState() {
    return _TopUpState(this.namae, this.mimoto);
  }
}

class _TopUpState extends State<TopUp> {

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot> futureBalances;


  final namae;
  final mimoto;



  int currentBal;

  _TopUpState(this.namae, this.mimoto);





  @override
  Widget build(BuildContext context) {

    return StreamProvider<List<Balance>>.value(
        value: DatabaseService().bal,
        initialData: null,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.close_rounded),
              color: Colors.white,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            title: Text("Top-up balance"),
            backgroundColor: Colors.pink[800],
          ),
          body: BalanceList(currentbal: currentBal, name: namae, id:mimoto),
        ));
  }
}
