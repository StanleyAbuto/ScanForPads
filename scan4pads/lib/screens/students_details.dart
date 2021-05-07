import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pad_app/services/database_service.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import '../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StudentsDetails extends StatefulWidget {
  @override
  _StudentsDetailsState createState() => _StudentsDetailsState();
}

class _StudentsDetailsState extends State<StudentsDetails> {
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference collectionReference;
  final DatabaseService removeStudent = DatabaseService();

  String barcode = "";

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
    return Scaffold(
        appBar: AppBar(
          title: Text('Student details'),
        ),
        body: collectionReference != null
            ? StreamBuilder(
                stream: collectionReference.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data == null) {
                    return Column(children: [
                      SizedBox(height: 20),
                      SpinKitWave(
                        color: Colors.blue,
                        size: 80,
                      )
                    ]);
                  } else {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data.docs[index].data();
                        return Container(
                          key: Key(doc['name']),
                          padding: EdgeInsets.all(10),
                          height: size.height * 0.9,
                          child: ListView(children: [
                            Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    elevation: 0,
                                    margin: EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text('${doc['name']}'),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text(
                                                  'Admission number ${doc['number']}'),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text('${doc['age']} years old'),
                                              SizedBox(
                                                height: 2,
                                              ),
                                              Text('Class ${doc['class']}'),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Column(
                                          children: [
                                            Container(
                                              width: 150.0,
                                              height: 100.0,
                                              child: CachedNetworkImage(
                                                imageUrl: doc['photo'] == null
                                                    ? ''
                                                    : doc['photo'],
                                                imageBuilder:
                                                    (context, imageProvider) {
                                                  return Container(
                                                    width: 150.0,
                                                    height: 100.0,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: imageProvider,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                progressIndicatorBuilder:
                                                    (context, url,
                                                            downloadProgress) =>
                                                        Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    elevation: 0,
                                    margin: EdgeInsets.fromLTRB(
                                        16.0, 16.0, 16.0, 0),
                                    child: Row(
                                      children: <Widget>[
                                        Column(
                                          children: [
                                            Container(
                                                width: 150.0,
                                                height: 100.0,
                                                child: QrImage(
                                                  data:
                                                      "${doc['name']} ${doc['number']}\n${doc['age']} years old \n class ${doc['class']} \n Parents\'s number ${doc['phoneNumber']}\n Status ${doc['status']}",
                                                  version: QrVersions.auto,
                                                  size: 60,
                                                )),
                                          ],
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Text("Contact: " +
                                                      "${doc['phoneNumber']}"),
                                                  RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                      ),
                                                      color: Colors.amber,
                                                      onPressed: () async {
                                                        await UrlLauncher.launch(
                                                            "tel://${doc['phoneNumber']}");
                                                      },
                                                      child: new Text(
                                                        "Call Parent",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Payments",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ]),
                        );
                      },
                    );
                  }
                },
              )
            : Center(
                child: SpinKitWave(
                  color: Colors.amber,
                  size: 80.0,
                ),
              ));
  }
}
