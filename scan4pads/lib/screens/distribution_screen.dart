import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pad_app/screens/students_details.dart';
import 'package:pad_app/services/database_service.dart';
import '../constants.dart';

class Distributions extends StatefulWidget {
  @override
  _DistributionsState createState() => _DistributionsState();
}

class _DistributionsState extends State<Distributions> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference collectionReference;
  String time, user, pads, id;
  final DatabaseService setData = DatabaseService();
  final DatabaseService removeStudent = DatabaseService();

  int currentStep = 0;
  bool complete = false;

  next() {
    currentStep + 1 != steps.length
        ? goTo(currentStep + 1)
        : setState(() => complete = true);
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  //StepperType stepperType = StepperType.horizontal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    collectionReference = FirebaseFirestore.instance
        .collection('Schools')
        .doc(kDBtoUse)
        .collection('students');
  }

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

  int bal = 7000;
  deduct() {
    bal = bal - 30;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: Text('Distribute'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Stepper(
              controlsBuilder: (BuildContext context,
                  {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                return Row(children: <Widget>[
                  FlatButton(
                    onPressed: onStepContinue,
                    child: const Text('CONTINUE',
                        style: TextStyle(color: Colors.white)),
                    color: Colors.pink,
                  ),
                  new Padding(
                    padding: new EdgeInsets.all(10.0),
                  ),
                  TextButton(
                    onPressed: onStepCancel,
                    child: const Text('CANCEL',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ]);
              },
              steps: _getSteps(context),
              // type: stepperType,
              currentStep: currentStep,
              onStepContinue: next,
              onStepTapped: (step) => goTo(step),
              onStepCancel: cancel,
            ))
          ],
        ));
  }

  List<Step> steps = <Step>[];
  List<Step> _getSteps(BuildContext Context) {
    int rawDate = DateTime.now().millisecondsSinceEpoch;
    final df = new DateFormat('dd-MM-yyyy hh:mm a');
    var date =
        (df.format(new DateTime.fromMillisecondsSinceEpoch(rawDate * 1000)));

    steps = <Step>[
      Step(
          title: const Text('Transaction'),
          isActive: true,
          state: _getState(1),
          content: Column(children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text("This process will deduct Ksh 30 from the student's profile"),
            SizedBox(
              height: 20,
            ),
          ])),
      Step(
          title: const Text('Confirm'),
          isActive: true,
          state: _getState(2),
          content: Column(children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
                "The Current balance in the student's profile is Ksh $bal. Do you wish to continue?"),
            SizedBox(
              height: 20,
            ),
          ])),
      Step(
          title: const Text('Finished'),
          isActive: true,
          state: _getState(3),
          content: Column(children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text('The transaction is complete!'),
            SizedBox(
              height: 20,
            ),
          ]))
    ];
    return steps;
  }

  StepState _getState(int i) {
    if (currentStep >= i) {
      return StepState.complete;
    } else {
      return StepState.indexed;
    }
  }
}
