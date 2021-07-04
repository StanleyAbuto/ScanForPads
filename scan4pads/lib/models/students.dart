import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pad_app/services/database_service.dart';

final CollectionReference studentsCollection = FirebaseFirestore.instance.collection("Schools");

class Student{
  final String age;
  final String studentClass;
  final String name;
  final String number;
  final String phoneNumber;
  final String photo;
  final String status;
  final int balance;

  Student({
    this.age,
    this.studentClass,
    this.name,
    this.number,
    this.phoneNumber,
    this.photo,
    this.status,
    this.balance
  });
  factory Student.fromDocument(DocumentSnapshot doc){
    return Student(
      age: doc.data()['age'],
      studentClass: doc.data()['class'],
      name: doc.data()['name'],
      number: doc.data()['number'],
      phoneNumber: doc.data()['phoneNumber'],
      photo: doc.data()['photo'],
      status: doc.data()['status'],
      balance: doc.data()['Balance'],
    );
  }
}
