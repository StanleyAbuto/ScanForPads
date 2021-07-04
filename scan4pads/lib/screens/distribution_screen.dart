import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pad_app/screens/searchpage.dart';
import 'package:pad_app/services/database_service.dart';
import '../constants.dart';
import 'package:pad_app/models/students.dart';

class Distributions extends StatefulWidget {
  @override
  _DistributionsState createState() => _DistributionsState();
}

class _DistributionsState extends State<Distributions> with AutomaticKeepAliveClientMixin<Distributions>{
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference studentsCollection;
  Future<QuerySnapshot> futureBalances;


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

  var doc;

  //StepperType stepperType = StepperType.horizontal;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkUser(auth.currentUser.email);
    studentsCollection = FirebaseFirestore.instance
        .collection('Schools')
        .doc(kDBtoUse)
        .collection('students');
  }
  getBalance(int bal){
    Future<QuerySnapshot> balances = studentsCollection.where('Balance', isGreaterThanOrEqualTo: bal).getDocuments();
    setState(() {
      futureBalances = balances;
    });
  }


  Container displayNoBalanceScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget> [
            Icon(Icons.money_off_rounded, color: Colors.grey, size: 100,),
            Text(
              "No money to distribute",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w200, fontSize: 30.0),
            ),
          ],
        ),
      ),
    );

  }
  displayBalanceScreen(){
    return FutureBuilder(
      future: futureBalances,
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return SpinKitCircle(
            color: Colors.pink,
            size:20,
          );
        }

        List<StudentResult> searchStudentsResult = [];
        dataSnapshot.data.documents.forEach((document){
          Student eachStudent = Student.fromDocument(document);
          StudentResult studentResult = StudentResult(eachStudent);
          searchStudentsResult.add(studentResult);
        });

        return new Scaffold(

            body: studentsCollection != null?
            StreamBuilder(
              stream: studentsCollection.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                doc = snapshot.data.docs;
                if (snapshot.data == null){
                  return Column(
                    children: [
                      SizedBox(height: 25.0),
                      SpinKitWave(
                        color: Colors.brown,
                        size: 80,
                      ),
                    ],
                  );
                }else {
                  return  Column(

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
                  );
                }
              },

            ): Center(
            child: SpinKitWave(
            color: Colors.amber,
          size: 80.0,
        ),
        )
        );
      },
    );
  }
  List<Step> steps = <Step>[];
  List<Step> _getSteps(BuildContext Context) {

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
                "The Current balance in the student's profile is Ksh ${doc['Balance']}. Do you wish to continue?"),
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Distribute'),
      ),

      body: futureBalances == null ? displayNoBalanceScreen() : displayBalanceScreen(),
        );
  }
}
