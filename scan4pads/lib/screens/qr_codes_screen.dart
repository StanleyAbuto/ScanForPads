import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';

class QRCodes extends StatefulWidget {
  @override
  _QRCodesState createState() => _QRCodesState();
}

class _QRCodesState extends State<QRCodes> {
  CollectionReference collectionReference;
  String barcode = "";
  GlobalKey globalKey = new GlobalKey();
  String fileName = 'studentQr';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('QR Codes'),
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
                          return Container(
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
                            child: ExpansionTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: size.width * 0.08,
                                    backgroundColor: Colors.transparent,
                                    child: CachedNetworkImage(
                                      imageUrl: doc['photo'] == null
                                          ? ''
                                          : doc['photo'],
                                      imageBuilder: (context, imageProvider) {
                                        return CircleAvatar(
                                            radius: size.width * 0.13,
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: imageProvider);
                                      },
                                      progressIndicatorBuilder:
                                          (context, url, downloadProgress) =>
                                              Center(
                                        child: CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('${doc['name']}'),
                                ],
                              ),
                              children: [
                                QrImage(
                                  data:
                                      "${doc['name']} ${doc['number']}\n${doc['age']} years old \n class ${doc['class']} \n Parents\'s number ${doc['phoneNumber']}\n Status ${doc['status']}",
                                  version: QrVersions.auto,
                                  size: 300.0,
                                ),
                                RaisedButton(onPressed: () {
                                  _captureAndSharePng();
                                },
                                    color: Colors.blue[800],
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: Text(
                                        'Save QR',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white),
                                      ),
                                    )

                                )
                              ],
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
              ),
      ),
    );
  }
  Future<void> _captureAndSharePng() async {
    try{
      RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.file(fileName, '$fileName.png', pngBytes, 'image/png');
    }catch (e){
      print(e.toString());
    }
  }
}
