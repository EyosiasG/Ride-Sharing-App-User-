import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../Models/trip.dart';

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
          driverID: value['driver_id'],
          pickUpLatPos: value['locationLatitude'],
          pickUpLongPos: value['locationLongitude'],
          dropOffLatPos: value['destinationLatitude'],
          dropOffLongPos: value['destinationLongitude'],
          pickUpDistance: 0,
          dropOffDistance: 0,
          destinationLocation: value['destinationLocation'],
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
        backgroundColor: Color(0xFFEDEDED),
        body: ListView.builder(
            itemCount: 4,
            itemBuilder: (context, index) {
              return InkWell(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              "images/PickUpDestination.png",
                              width: 40,
                              height: 50,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lideta Condominium',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  Divider(),
                                  Text(
                                    'Nefas Silk Lafto',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  )
                                ]),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Distance '),
                                  Text('0.8 kms'),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Cost'),
                                  Text('50 br.'),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ]),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Arrival Time'),
                                  Text('7 mins'),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ]),

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
                                Text('Thursday, March 2023'),
                              ],
                            ),
                            RatingBarIndicator(
                              itemBuilder: (context, index) => Icon(
                                Icons.person,
                                color: Colors.greenAccent,
                              ),
                              rating: 3.0,
                              itemSize: 18,
                              itemCount: 4,
                            ),
                          ],
                        ),
                        SizedBox(height: 30,),
                        Divider(),
                        Row(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    'https://img.freepik.com/free-photo/indoor-shot-glad-young-bearded-man-mustache-wears-denim-shirt-smiles-happily_273609-8698.jpg?w=1060&t=st=1684762104~exp=1684762704~hmac=f48dc7b69b41deac29bbf849e5020a36b4e19b7f2c32048e2950f9f6028927bf',
                                  ),
                                  radius: 35,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text('Abebe Kebede',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          )),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0.0, 0, 3.0, 0),
                                            child: Text('Blue'),
                                          ),
                                          Text('Toyota Vitz'),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10.0),
                                        child: RatingBarIndicator(
                                          itemBuilder: (context, index) => Icon(
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
                            Spacer(),
                            ElevatedButton(
                                onPressed: () {},
                                child: Text(
                                  'Book Seat',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.greenAccent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  onTap: () {});
            }));

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
}
