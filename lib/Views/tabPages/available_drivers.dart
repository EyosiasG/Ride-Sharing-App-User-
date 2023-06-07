import 'dart:math';

import 'package:car_pool_driver/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

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
          totalMileage: '6.4km',
          carMake: value['car_make'],
          carModel: value['car_model'],
          carYear: value['car_year'],
          carPlateNo: value['car_plateNo'],
          carColor: value['car_color'],
          rating: value['averageRating'],
          noOfRatings: value['noOfRatings']
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
      final dataSnapshot = await databaseReference
          .orderByChild('destinationLocation')
          .equalTo(destinationLocation)
          .once();

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
          date: value['date'],
          time: value['time'],
          availableSeats: value['availableSeats'].toString(),
          passengers: value['passengers'].toString()
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
  bool isTripLoading = false;
  bool isDriverLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isTripLoading = true;
    isDriverLoading = true;
    getTrips().then((_) {
      setState(() {
        isTripLoading = false;
      });
    });
    getDrivers().then((_) {
      setState(() {
        isDriverLoading = false;
      });
    });
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
    double? _rating;
    IconData? _selectedIcon;
    return Scaffold(
        backgroundColor: const Color(0xFFEDEDED),
        body: Stack(
          children: [
            if (isTripLoading || isDriverLoading)
              ProgressDialog(message: "Searching Drivers",)
            else
              ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    dr = getDriver(trips[index].driverID);
                    double distance = calculateDistance(
                        double.parse(widget.userLatPos),
                        double.parse(widget.userLongPos),
                        double.parse(trips[index].pickUpLatPos),
                        double.parse(trips[index].pickUpLongPos));
                    double arrivalTime = calculateArrivalTime(distance);

                    return Container(
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
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Text(
                                    trips[index].destinationLocation.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 300),
                                  child: Text(
                                    trips[index].pickUpLocation.toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              ])
                        ]),
                        const SizedBox(
                          height:20,
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
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children:  [
                                  const Text('Cost'),
                                  Text('${trips[index].price} br.'),
                                ]),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Arrival Time'),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 100),
                                  child: Text(
                                    arrivalTime.toStringAsPrecision(2),
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trips[index].time.toString()),
                                Text(formatDate(trips[index].date.toString())),
                              ],
                            ),
                            RatingBarIndicator(
                              itemBuilder: (context, index) => const Icon(
                                Icons.person,
                                color: Colors.greenAccent,
                              ),
                              rating: int.parse(trips[index].passengers.toString()[0]) - double.parse(trips[index].availableSeats),
                              itemSize: 18,
                              itemCount: int.parse(trips[index].passengers.toString()[0]),
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
                                  backgroundImage: NetworkImage(dr.imagePath),
                                  radius: 25,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(dr.name,
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
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: RatingBarIndicator(
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          rating: double.parse(dr.rating),
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
                                backgroundColor: Colors.greenAccent,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Request',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        RatingBar.builder(
                          initialRating: _rating ?? 0.0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 50,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          itemBuilder: (context, _) => Icon(
                            _selectedIcon ?? Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) async {
                            _rating = rating;
                            double? avgRating;
                            String? numberOfRatings;
                            final ref =
                                FirebaseDatabase.instance.ref('drivers');
                            final snapshot = await ref
                                .child(trips[index].driverID)
                                .child('averageRating')
                                .get();
                            if (snapshot.exists) {
                              avgRating =
                                  double.parse(snapshot.value.toString());
                            } else {
                              const AlertDialog(
                                  semanticLabel: 'No data available.');
                            }

                            final snapshot2 = await ref
                                .child(trips[index].driverID)
                                .child('noOfRatings')
                                .get();
                            numberOfRatings = snapshot2.value.toString();

                            avgRating =
                                ((avgRating! * int.parse(numberOfRatings)) +
                                        _rating!) /
                                    (int.parse(numberOfRatings) + 1);

                            FirebaseDatabase.instance
                                .ref("drivers")
                                .child(trips[index].driverID)
                                .update({"averageRating": avgRating.toString()});
                            FirebaseDatabase.instance
                                .ref("drivers")
                                .child(trips[index].driverID)
                                .update({
                              "noOfRatings": (int.parse(numberOfRatings) + 1).toString()
                            });

                            setState(() {});
                          },
                        ),
                      ]),
                    );
                  }),
          ],
        ));
  }

  String formatDate(String inputStr) {
    // Convert the input string to a DateTime object
    DateTime date = DateTime.parse(inputStr);

    // Format the DateTime object as a String in the desired format
    String formattedStr = DateFormat('EEEE, MMMM d y').format(date);

    return formattedStr;
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
      totalMileage: '',
      carMake: '',
      carModel: '',
      carYear: '',
      carColor: '',
      carPlateNo: '',
      rating: '',
      noOfRatings: ''
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
    FirebaseDatabase.instance.ref().child("requests").child(requestID).set({
      "requestID": requestID,
      "tripID": trip.tripID,
      "driverID": trip.driverID,
      "userID": currentFirebaseUser!.uid.toString(),
      "status": "pending",
    });
  }
}
