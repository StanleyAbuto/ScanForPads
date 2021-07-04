import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:pad_app/screens/top_up.dart';
import 'package:pad_app/models/students.dart';
import 'package:pad_app/widgets/circular_material_spinner.dart';


class EWallet extends StatefulWidget {
  @override
  _EWalletState createState() => _EWalletState();

}

class _EWalletState extends State<EWallet> {
  final ewalletformKey = GlobalKey<FormState>();


  @override
  void initState(){

    super.initState();
  }
  TextEditingController nameCtrl = new TextEditingController();
  var name;
  TextEditingController regnoCtrl = new TextEditingController();
  var id;

  bool loading = false;

  void dispose(){
    nameCtrl.dispose();
    regnoCtrl.dispose();
    super.dispose();
  }
  void _sendDataToTopUp(BuildContext context){
    String studentName = nameCtrl.text;
    String studentId = regnoCtrl.text;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopUp(namae: studentName, mimoto: studentId))
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("E-Wallet"),
        elevation: 0,
        backgroundColor: Colors.pink[800],
      ),
        body: SingleChildScrollView(
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white10,
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.centerRight,
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 36.0, horizontal: 110.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 7,
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.elliptical(100, 40),
                                topRight: Radius.elliptical(100, 40),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Form(
                                key: ewalletformKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 50,
                                    ),
                                    Text(
                                      "Enter student details",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 70.0,
                                    ),
                                    TextFormField(
                                      controller: nameCtrl,
                                      textInputAction: TextInputAction.next,

                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'Name is required';
                                        return null;
                                      },


                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(8.0),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: Color(0xFFe7edeb),
                                        hintText: "Student Name",
                                        prefixIcon: Icon(Icons.account_circle_rounded,
                                            color: Colors.grey[600]),
                                      ),
                                    ),

                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    TextFormField(
                                      controller: regnoCtrl,
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value.isEmpty)
                                          return 'Student ID required';
                                        if (value.length < 4)
                                          return 'Student ID should be 4 characters long';
                                        return null;
                                      },

                                      decoration: new InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Color(0xFFe7edeb),
                                          hintText: "Student ID",
                                          prefixIcon: Icon(Icons.admin_panel_settings_rounded,
                                              color: Colors.grey[600]),
                                          ),
                                    ),


                                    SizedBox(height: 25),
                                    CircularMaterialSpinner(
                                      loading: loading,
                                      color: Colors.blue[800],
                                      child: Container(
                                        width: double.infinity,
                                        child: RaisedButton(
                                            onPressed: () async {
                                              if (ewalletformKey.currentState
                                                  .validate()) {
                                                setState(() {
                                                  loading = true;
                                                  ewalletformKey.currentState.save();

                                                });
                                                _sendDataToTopUp(context);

                                                }
                                              },

                                            color: Colors.blue[800],
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 16.0),
                                              child: Text(
                                                'Submit',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                              ),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))),
                  ],
                ))));
  }
}
