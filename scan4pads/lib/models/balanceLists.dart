import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pad_app/models/bals.dart';
import 'package:pad_app/services/database_service.dart';
import 'package:provider/provider.dart';
import 'package:pad_app/screens/top_up.dart';

import '../constants.dart';

class BalanceList extends StatefulWidget{
  final int currentbal;
  final String name, id;
  BalanceList({Key key, @required this.currentbal, this.name, this.id}): super(key: key);

  @override
  _BalanceListState createState() {
    return _BalanceListState(this.currentbal, this.name, this.id);
  }
}
class _BalanceListState extends State<BalanceList>{
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<QuerySnapshot> futureBalances;
  final balformKey = GlobalKey<FormState>();
  TextEditingController topupCtrl = TextEditingController();
  CollectionReference studentsCollection;
  final name;
  final id;
  int currentbal;

  _BalanceListState(this.currentbal, this.name, this.id);

  void checkUser(String user) async {
    if (user == 'nabuyuni.sankan@strathmore.edu') {
      kProfileImage = 'assets/profile.jpg';
      kName = 'Nabuyuni Sankan';
      kSchool = 'Narok Primary School';
      kDBtoUse = 'Narok Primary School';
    } else if (user == 'nabuyuni@strathmore.edu') {
      kProfileImage = 'assets/profile1.jpg';
      kName = 'Nabuyuni';
      kSchool = 'Olkeri Primary school';
      kDBtoUse = 'Olkeri Primary school';
    } else if (user == 'bizeysankan@gmail.com') {
      kProfileImage = 'assets/profile2.jpg';
      kName = 'Bizey';
      kSchool = 'Masikonde Primary School';
      kDBtoUse = 'Masikonde Primary School';
    } else if (user == 'sankan@gmail.com') {
      kProfileImage = 'assets/profile3.jpg';
      kName = 'Sankan';
      kSchool = 'Siyapei Primary School';
      kDBtoUse = 'BUShus6GvovjCb9lT48X';
    }
  }
  int balance = 0;
  int balance2;
  sum(int val){
    balance = currentbal + balance;
  }

  @override
  void initState() {
    super.initState();
    checkUser(auth.currentUser.email);
    studentsCollection = FirebaseFirestore.instance
        .collection('Schools')
        .doc(kDBtoUse)
        .collection('students');
  }

  bool loading = false;

  @override
  Widget build(BuildContext context){
    balance2 = int.tryParse(topupCtrl.text);
    final bal = Provider.of<List<Balance>>(context);
    bal.forEach((bala) {
      print(bala.currentbal);
    });

    return ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Balance: '),
              Container(
                padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                width: 100.0,
                height: 40.0,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Text(
                    '$currentbal',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 25.0, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  '$name',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                Text(
                  '$id',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                  child: Form(
                    key: balformKey,
                    child: TextFormField(
                      style:
                      TextStyle(fontSize: 18.0, color: Colors.black54),
                      controller: topupCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter an amount';
                        if (value.length > 5)
                          return 'Amount should be between 30 to 1000';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter amount",
                        hintStyle: TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink[100]),
                        ),
                        filled: true,
                        prefixIcon: Icon(
                          Icons.attach_money_rounded,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 45.0,
                ),
                RaisedButton(
                  onPressed: () async {
                    if (balformKey.currentState.validate()) {
                      await DatabaseService(sid: name.sid)
                          .updateStudentData(
                        currentbal ?? balance,
                      );
                      setState(() {
                        loading = true;
                        balformKey.currentState.save();
                        currentbal = balance;
                      });
                    }
                  },
                  color: Colors.blue[800],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Send',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  }
}