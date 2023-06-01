import 'dart:ffi';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../Models/driver.dart';
import '../../Models/trip.dart';
import '../../global/global.dart';

class GetDrivers {
  final databaseReference = FirebaseDatabase.instance.ref('drivers');

  Future<List<Driver>> getDriver() async {
    List<Driver> itemList = [];
    // Get a reference to the Firebase database

    try {
      // Retrieve all items with the specified color
      final dataSnapshot = await databaseReference.once();

      // Convert the retrieved data to a list of Item objects

      Map<dynamic, dynamic> values =
          dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        final item = Driver(
            id: value['id'],
            imagePath: value['driver_image'],
            name: value['name'],
            email: value['email'],
            phone: value['phone'],
            ratings: '4.5',
            totalMileage: '6.4km',
            carMake: value['car_make'],
            carModel: value['car_model'],
            carYear: value['car_year'],
            carPlateNo: value['car_plateNo'],
            carColor: value['car_color'],
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

class AvailableDrivers extends StatefulWidget {
  final String userLatPos;
  final String userLongPos;
  final String userDestinationLatPos;
  final String userDestinationLongPos;
  final String destinationLocation;

  const AvailableDrivers({
    Key? key,
    required this.userLatPos,
    required this.userLongPos,
    required this.userDestinationLatPos,
    required this.userDestinationLongPos,
    required this.destinationLocation,
  }) : super(
          key: key,
        );

  @override
  State<AvailableDrivers> createState() => _AvailableDriversState();
}

class GetTrips {
  final databaseReference = FirebaseDatabase.instance.ref('trips');

  Future<List<Trip>> getItemsByDestination(String destinationLocation) async {
    List<Trip> itemList = [];
    // Get a reference to the Firebase database

    try {
      // Retrieve all items with the specified color
      final dataSnapshot = await databaseReference
          .orderByChild('destinationLocation')
          .equalTo(destinationLocation)
          .once();

      // Convert the retrieved data to a list of Item objects

      Map<dynamic, dynamic> values =
          dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        final item = Trip(
          tripID: value['tripID'],
          driverID: value['driver_id'],
          pickUpLatPos: value['locationLatitude'],
          pickUpLongPos: value['locationLongitude'],
          dropOffLatPos: value['destinationLatitude'],
          dropOffLongPos: value['destinationLongitude'],
          pickUpDistance: 0,
          dropOffDistance: 0,
          destinationLocation: value['destinationLocation'],
          pickUpLocation: value['pickUpLocation'],
          userIDs: [],
          price: value['price'],
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
  final GetDrivers getAllDrivers = GetDrivers();
  List<Trip> trips = [];
  List<Driver> drivers = [];
  List<Trip> closeTrips = [];
  Driver? dr;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDrivers();
    getTrips();
  }

  Future<void> getDrivers() async {
    List<Driver> drivers = await getAllDrivers.getDriver();
    setState(() {
      this.drivers = drivers;
    });
  }

  Future<void> getTrips() async {
    List<Trip> trips =
        await getAllTrips.getItemsByDestination(widget.destinationLocation);
    setState(() {
      this.trips = trips;
    });
  }

  String getDistance(String driverDestLat, String driverDestLong) {
    double distance = calculateDistance(
        double.parse(widget.userLatPos),
        double.parse(widget.userLongPos),
        double.parse(driverDestLat),
        double.parse(driverDestLong));
    return distance.toString();
  }

  @override
  Widget build(BuildContext context) {
    Driver dr;
    double rating = 4.5;
    /*double pickUpDistance = 0 , dropOffDistance = 0;
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
    }*/
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            dr = getDriver(trips[index].driverID);
            double distance = calculateDistance(
                double.parse(widget.userLatPos),
                double.parse(widget.userLongPos),
                double.parse(trips[index].pickUpLatPos),
                double.parse(trips[index].pickUpLongPos));
            double arrivalTime = calculateArrivalTime(distance);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Row(children: [
                    Image.asset(
                      "images/PickUpDestination.png",
                      width: 40,
                      height: 50,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              trips[index].destinationLocation.toString(),
                              //'Lideta Condominium',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Divider(),
                          Container(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: Text(
                              trips[index].pickUpLocation.toString(),
                              //'Nefas Silk Lafto',
                              style: const TextStyle(
                                color: Colors.grey,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ])
                  ]),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  const Text('Distance'),
                                  Text(
                                      '${distance.toStringAsPrecision(6)} kms'),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Cost'),
                            Text('50 br.'),
                            const SizedBox(
                              height: 30,
                            ),
                          ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Arrival Time'),
                          Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(arrivalTime.toStringAsPrecision(2),style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                              ),),),
                          SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('3:00 PM'),
                          Text(trips[index].tripID.toString()),
                        ],
                      ),
                      RatingBarIndicator(
                        itemBuilder: (context, index) => const Icon(
                          Icons.person,
                          color: Colors.greenAccent,
                        ),
                        rating: 3.0,
                        itemSize: 18,
                        itemCount: 4,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(dr.imagePath
                                //'https://img.freepik.com/free-photo/indoor-shot-glad-young-bearded-man-mustache-wears-denim-shirt-smiles-happily_273609-8698.jpg?w=1060&t=st=1684762104~exp=1684762704~hmac=f48dc7b69b41deac29bbf849e5020a36b4e19b7f2c32048e2950f9f6028927bf',
                                ),
                            radius: 35,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(dr.name,
                                    //'Abebe Kebede',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    )),
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0.0, 0, 3.0, 0),
                                      child: Text(dr.carColor),
                                    ),
                                    Text('${dr.carMake} ${dr.carModel}'),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: RatingBarIndicator(
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    rating: rating,
                                    itemSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          requestRide(trips[index]);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Request Ride',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            );
          }),
    );

    /*Scaffold(
     body:ListView.builder(
       itemCount: trips.length,
       itemBuilder: (context, index) {
         return Column(
           children: [
             Column(
               children: [
                 Text(trips[index].driverID),
                 Text('${widget.userLatPos} , ${widget.userDestinationLongPos}'),
                 Text('${widget.userDestinationLatPos} , ${widget.userDestinationLongPos}'),
                 Text('${trips[index].pickUpLatPos} , ${trips[index].pickUpLongPos}'),
                 Text('${trips[index].dropOffLatPos} , ${trips[index].dropOffLongPos}'),
                 Text(trips[index].destinationLocation),
                 Text(calculateDistance(
                     double.parse(widget.userLatPos),
                     double.parse(widget.userLongPos),
                          double.parse(trips[index].pickUpLatPos),
                          double.parse(trips[index].pickUpLongPos))
                      .toString()),
                  Text(calculateDistance(
                          double.parse(widget.userLatPos),
                          double.parse(widget.userLongPos),
                          double.parse(trips[index].dropOffLatPos),
                          double.parse(trips[index].dropOffLongPos))
                      .toString()),
                ],
             ),
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Divider(color: Colors.grey,),
             ),
           ],
         );
       },
     ) ,
    );*/
  }

  double calculateDistance(
      double userLat, double userLong, double destLat, double destLong) {
    double distance, earthRadius = 6371;
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

  Driver getDriver(String id) {
    Driver nullDriver = const Driver(
        id: '',
        imagePath: '',
        name: '',
        email: '',
        phone: '',
        ratings: '',
        totalMileage: '',
        carMake: '',
        carModel: '',
        carYear: '',
        carColor: '',
        carPlateNo: '',
    );
    for (var driver in drivers) {
      if (driver.id == id) {
        return driver;
      }
    }
    return nullDriver;
  }

  double calculateArrivalTime(double distance) {
    double velocity = 30, arrivalTime;
    arrivalTime = (distance / velocity) * 60;
    return arrivalTime;
  }

  void requestRide(Trip trip) {
    String requestID = currentFirebaseUser!.uid + trip.tripID;
    FirebaseDatabase.instance.reference().child("requests").child(requestID).set({
      "requestID":requestID,
      "tripID": trip.tripID,
      "driverID": trip.driverID,
      "userID": currentFirebaseUser!.uid.toString(),
      "status": "pending",
    });
  }
}
