import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pad_app/screens/home_screen.dart';
import 'package:pad_app/screens/students_details.dart';
import 'package:pad_app/services/database_service.dart';
import 'package:pad_app/widgets/add_student.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../constants.dart';

class StudentsTab extends StatefulWidget {
  @override
  _StudentsTabState createState() => _StudentsTabState();
}

class _StudentsTabState extends State<StudentsTab> {
  CollectionReference collectionReference;
  final DatabaseService removeStudent = DatabaseService();

  String qrCode = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    collectionReference = FirebaseFirestore.instance
        .collection('Schools')
        .doc(kDBtoUse)
        .collection('students');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Expanded(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.pink,
            /*leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()))),*/
            leading: IconButton(
                icon: Icon(Icons.search),
                color: Colors.white,
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                }),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.qr_code_scanner_rounded),
                color: Colors.white,
                onPressed: () {
                  scanQRCode();
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.pink,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      "Add a Student",
                      textAlign: TextAlign.center,
                    ),
                    children: [AddStudent()],
                  );
                },
              );
            },
            child: Icon(Icons.add, color: Colors.white, size: 30),
          ),
          body: collectionReference != null
              ? StreamBuilder(
                  stream: collectionReference.snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.data == null) {
                      return Column(
                        children: [
                          SizedBox(height: size.height * 0.25),
                          SpinKitWave(
                            color: Colors.brown,
                            size: 80,
                          ),
                        ],
                      );
                    } else {
                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data.docs[index].data();
                            return Dismissible(
                              key: Key(doc['name']),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  final bool res = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: Text(
                                              "Are you sure you want to delete ?"),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            FlatButton(
                                              child: Text(
                                                "Delete",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                              onPressed: () {
                                                removeStudent.removeStudent(
                                                    snapshot
                                                        .data.docs[index].id);
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Student successfully deleted",
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  return null;
                                } else {
                                  return null;
                                }
                              },
                              child: Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 3),
                                          blurRadius: 5,
                                          color: Colors.black.withOpacity(0.1),
                                        ),
                                      ]),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StudentsDetails()));
                                    },
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: size.width * 0.08,
                                          backgroundColor: Colors.transparent,
                                          child: CachedNetworkImage(
                                            imageUrl: doc['photo'] == null
                                                ? ''
                                                : doc['photo'],
                                            imageBuilder:
                                                (context, imageProvider) {
                                              return CircleAvatar(
                                                  radius: size.width * 0.13,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage:
                                                      imageProvider);
                                            },
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${doc['name']}'),
                                            Text(
                                                'Admission number ${doc['number']}'),
                                            Text('${doc['age']} years old'),
                                            Text('Class ${doc['class']}'),
                                          ],
                                        ),
                                        Spacer(),
                                        QrImage(
                                          data:
                                              "${doc['name']} ${doc['number']}\n${doc['age']} years old \n class ${doc['class']} \n Parents\'s number ${doc['phoneNumber']}\n Status ${doc['status']}",
                                          version: QrVersions.auto,
                                          size: 60.0,
                                        ),
                                        //  \nAdmission number ${doc['number']}\n${doc['age']} years old\nClass ${doc['class']}
                                      ],
                                    ),
                                  )),
                              secondaryBackground: Container(
                                color: Colors.red,
                                child: Align(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                              background: Container(
                                color: Colors.white,
                                child: Align(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        " Delete",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                            );
                          });
                    }
                  })
              : Center(
                  child: SpinKitWave(
                    color: Colors.amber,
                    size: 80.0,
                  ),
                )),
    );
  }

  Future<void> scanQRCode() async {
    try {
      final qrCode = await FlutterBarcodeScanner.scanBarcode(
        '#ffc0cb',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (!mounted) return;

      setState(() {
        this.qrCode = qrCode;
        checkingValue(qrCode);
      });
    } on PlatformException {
      qrCode = 'Failed to get platform version.';
    }
  }

  checkingValue(String data) {
    if (qrCode != null || qrCode != "") {
      if (qrCode.contains("Semeyan") || qrCode.contains("Kaseaine")) {
        return Navigator.push(context,
            MaterialPageRoute(builder: (context) => StudentsDetails()));
      } else {
        Fluttertoast.showToast(
            msg: "Invalid QR image",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    } else {
      return null;
    }
  }
}

class DataSearch extends SearchDelegate<String> {
  final students = [
    "Jane Troyiye",
    "Singen Grace",
    "Semeyian Kishoyian",
    "Joyna Sherianto",
    "Tobiko  Leriari",
    "Namayian Lemphiris",
    "Napunyu Leriari",
    "Jane Wamaith"
  ];

  final recent_students = [
    "Singen Grace",
    "Semeyian Kishoyian",
    "Joyna Sherianto"
  ];

  static get doc => null;

  @override
  List<Widget> buildActions(BuildContext context) {
    // actions for searchbar
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // leading icon on the searchbar
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
    throw UnimplementedError();
  }

  @override
  Widget buildResults(BuildContext context) {
    // show some result based on the selection
    return Container(child: GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => StudentsDetails()));
      },
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // To show when someone searches fpr something
    final suggestionList = query.isEmpty
        ? recent_students
        : students.where((p) => p.startsWith(query)).toList();
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => StudentsDetails()));
        },
        leading: Icon(Icons.history, color: Colors.grey[600]),
        title: RichText(
          text: TextSpan(
            text: suggestionList[index].substring(0, query.length),
            style: TextStyle(color: Colors.black),
            children: [
              TextSpan(
                  text: suggestionList[index].substring(query.length),
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      itemCount: suggestionList.length,
    );
  }
}
