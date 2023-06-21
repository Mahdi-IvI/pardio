import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Pardio{
  static const String appName = 'Pardio';

  static const String logoAddress = 'https://firebasestorage.googleapis.com/v0/b/smartlink-pro.appspot.com/o/logo.png?alt=media&token=a983ec96-3810-4b90-bbd2-510f1504dc20';

  static const String errorMessage = 'Something went wrong!!!';


  static late FirebaseFirestore fireStore;
  static late FirebaseApp firebaseApp;

  static const String radioCollection = 'radio';
  static const String radioName = 'name';
  static const String radioImage = 'image';
  static const String radioUrl = 'url';

}