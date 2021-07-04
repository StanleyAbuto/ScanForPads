import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pad_app/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pad_app/models/students.dart';
import 'package:pad_app/screens/students_details.dart';


class SearchPage extends StatefulWidget{
  @override
  _SearchPageState createState() => _SearchPageState();
}



class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>
{
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference studentsCollection;

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

  emptyTheTextFormField(){
    searchTextEditingController.clear();
  }

  controlSearching(String str){
    Future<QuerySnapshot> allStudents = studentsCollection.where("name", isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futureSearchResults = allStudents;
    });
  }

  AppBar searchPageHeader()
  {
    return AppBar(
      backgroundColor: Colors.pink[400],
      title: TextFormField(
        style: TextStyle(fontSize: 20.0, color: Colors.white),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "Search students...",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(Icons.account_circle_sharp, color: Colors.white, size: 30.0,),
          suffixIcon: IconButton(icon: Icon(Icons.clear, color: Colors.white,), onPressed: emptyTheTextFormField,)
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Container displayNoSearchResultsScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget> [
            Icon(Icons.group, color: Colors.grey, size: 100,),
            Text(
              "Find a Student",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w200, fontSize: 30.0),
            ),
          ],
        ),
      ),
    );

  }

  displayStudentsFoundScreen(){
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return SpinKitCircle(
            color: Colors.pink,
            size: 20,
          );
        }

        List<StudentResult> searchStudentsResult = [];
        dataSnapshot.data.documents.forEach((document){
          Student eachStudent = Student.fromDocument(document);
          StudentResult studentResult = StudentResult(eachStudent);
          searchStudentsResult.add(studentResult);
        });
        return ListView(children: searchStudentsResult,);
      },
    );
  }
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context)
  {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: searchPageHeader(),

      body: futureSearchResults == null ? displayNoSearchResultsScreen() : displayStudentsFoundScreen(),

    );
  }
}
class StudentResult extends StatelessWidget
{
  final Student eachStudent;
  StudentResult(this.eachStudent);

  @override
  Widget build(BuildContext context) {
   return Padding(
     padding: EdgeInsets.all(3.0),
     child: Container(
       color: Colors.white,
       child: Column(
         children: <Widget>[
           GestureDetector(
             onTap: (){
               Navigator.push(context,
                   MaterialPageRoute(builder: (context) => StudentsDetails()));
             },
             child: ListTile(
               leading: CircleAvatar(backgroundColor: Colors.black, backgroundImage: CachedNetworkImageProvider(eachStudent.photo),),
               title: Text(eachStudent.name??'default value', style: TextStyle(
                 color: Colors.pink, fontSize: 16, fontWeight: FontWeight.w500,
               ),),
               subtitle: Text(eachStudent.phoneNumber??'default value', style: TextStyle(
                 color: Colors.black, fontSize: 12,
               )),

             ),
           )
         ],
       ),
     ),
   );
  }
}