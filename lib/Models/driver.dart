import 'package:firebase_database/firebase_database.dart';

class Driver{
  final String id;
  final String imagePath;
  final String name;
  final String email;
  final String phone;
  final String ratings;
  final String totalMileage;
  final String carMake;
  final String carModel;
  final String carYear;
  final String carColor;
  final String carPlateNo;


const Driver({
  required this.id,
  required this.imagePath,
  required this.name,
  required this.email,
  required this.phone,
  required this.ratings,
  required this.totalMileage,
  required this.carMake,
  required this.carModel,
  required this.carYear,
  required this.carColor,
  required this.carPlateNo,

});
}


