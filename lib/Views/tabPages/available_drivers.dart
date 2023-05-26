import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../Models/trip.dart';

class AvailableDrivers extends StatefulWidget {
  final String userLatPos;
  final String userLongPos;
  final String userDestinationLatPos;
  final String userDestinationLongPos;


  const AvailableDrivers({
    Key? key,
    required this.userLatPos,
    required this.userLongPos,
    required this.userDestinationLatPos,
    required this.userDestinationLongPos,
  }) : super(key: key, );

  @override
  State<AvailableDrivers> createState() => _AvailableDriversState();
}

class GetTrips {

  final databaseReference = FirebaseDatabase.instance.ref('trips');
  Future<List<Trip>> getItemsByColor() async {
    List<Trip> itemList = [];
    // Get a reference to the Firebase database


    try {
      // Retrieve all items with the specified color
      final dataSnapshot = await databaseReference
          .once();

      // Convert the retrieved data to a list of Item objects

      Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        final item = Trip(
            driverID: value['driver_id'],
            pickUpLatPos: value['locationLatitude'],
            pickUpLongPos: value['locationLongitude'],
            dropOffLatPos: value['destinationLatitude'],
            dropOffLongPos: value['destinationLongitude'],
            pickUpDistance: 0,
            dropOffDistance: 0,
        );
        itemList.add(item);
      });

    } catch (e) {
      // Log the error and return an empty list
      print('Error: $e');
    }
    return itemList;
  }
}


class _AvailableDriversState extends State<AvailableDrivers> {
  final GetTrips getAllTrips = GetTrips();
  List<Trip> trips = [];
  List<Trip> closeTrips = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrips();
  }



  Future<void> getTrips() async {
    List<Trip> trips = await getAllTrips.getItemsByColor();
    setState(() {
      this.trips = trips;
    });
  }

  String getDistance(String driverDestLat,String driverDestLong){
    double distance = calculateDistance(
        double.parse(widget.userLatPos),
        double.parse(widget.userLongPos),
        double.parse(driverDestLat),
        double.parse(driverDestLong)
    );
    return distance.toString();
  }

  @override
  Widget build(BuildContext context) {
    double pickUpDistance = 0 , dropOffDistance = 0;
    for(var trip in trips){

      pickUpDistance = calculateDistance(
          double.parse(widget.userLatPos),
          double.parse(widget.userLongPos),
          double.parse(trip.pickUpLatPos),
          double.parse(trip.pickUpLongPos));
      dropOffDistance = calculateDistance(
          double.parse(widget.userDestinationLatPos),
          double.parse(widget.userDestinationLongPos),
          double.parse(trip.dropOffLatPos),
          double.parse(trip.dropOffLongPos));

      if(pickUpDistance <= 2.5 &&  dropOffDistance <= 3) {
        closeTrips.add(trip);
      }
    }
    return  Scaffold(
     body:ListView.builder(
       itemCount: trips.length,
       itemBuilder: (context, index) {
         return Column(
           children: [
             Column(
               children: [
                 Text(closeTrips.length.toString()),
                 Text(trips[index].driverID),
                 Text('${widget.userLatPos} , ${widget.userDestinationLongPos}'),
                 Text('${widget.userDestinationLatPos} , ${widget.userDestinationLongPos}'),
                 Text('${trips[index].pickUpLatPos} , ${trips[index].pickUpLongPos}'),
                 Text('${trips[index].dropOffLatPos} , ${trips[index].dropOffLongPos}'),
                 Text(calculateDistance(
                     double.parse(widget.userLatPos),
                     double.parse(widget.userLongPos),
                          double.parse(trips[index].pickUpLatPos),
                          double.parse(trips[index].pickUpLongPos))
                      .toString()),
                  Text(calculateDistance(
                          double.parse(widget.userDestinationLatPos),
                          double.parse(widget.userDestinationLongPos),
                          double.parse(trips[index].dropOffLatPos),
                          double.parse(trips[index].dropOffLongPos))
                      .toString()),
                ],
             ),
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: const Divider(color: Colors.grey,),
             ),
           ],
         );
       },
     ) ,
    );
  }
  double calculateDistance(double userLat, double userLong, double destLat, double destLong){
    double distance , earthRadius = 6371;
    double lat1Rad = degreesToRadians(userLat);
    double lon1Rad = degreesToRadians(userLong);
    double lat2Rad = degreesToRadians(destLat);
    double lon2Rad = degreesToRadians(destLong);

    double latDiff = lat2Rad - lat1Rad;
    double lonDiff = lon2Rad - lon1Rad;

    num havLat = pow(sin(latDiff / 2), 2);
    num havLon = pow(sin(lonDiff / 2), 2);

    num havLat1 = pow(sin(lat1Rad), 2);
    num havLat2 = pow(sin(lat2Rad), 2);

    double hav = havLat + havLon * cos(lat1Rad) * cos(lat2Rad);

    distance = 2 * earthRadius * asin(sqrt(hav));

    return distance;
  }
  double degreesToRadians(double degrees) {
    // Helper function to convert degrees to radians
    return degrees * pi / 180;
  }
}
