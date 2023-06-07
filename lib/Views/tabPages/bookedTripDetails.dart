import 'dart:async';

import 'package:car_pool_driver/Models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../Constants/widgets/loading.dart';
import '../../Models/driver.dart';
import '../../Models/request.dart';
import '../../Models/trip.dart';
import '../assistants/assistant_methods.dart';
import '../data handler/app_data.dart';

class MyBookedTrips extends StatefulWidget {
  final Request request;

  const MyBookedTrips({
    Key? key,
    required this.request,
  }) : super(key: key);

  @override
  State<MyBookedTrips> createState() => _MyBookedTripsState();
}

class _MyBookedTripsState extends State<MyBookedTrips> {
  User? currentUser;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newgoogleMapController;
  static const CameraPosition _kGooglePlex =
  CameraPosition(target: LatLng(9.1450, 40.4897), zoom: 1);

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
  String driverImage = "";
  String name = "";
  List<Driver> driver = [];
  List<Trip> trip = [];
  List<Passenger> passenger = [];
  bool isLoading = false;

  Future<void> getPlaceDirection() async {
    var pickUpLatLng = LatLng(9.0299865, 38.7358369);
    var dropOffLatLng = LatLng(9.0122897, 38.7358369);
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            LoadingScreen(message: "Please wait...."));
    var details = await AssistantMethods.obtainDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResult =
    polylinePoints.decodePolyline(details!.encodedPoints.toString());
    pLineCoordinates.clear();
    if (decodePolylinePointsResult.isNotEmpty) {
      decodePolylinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.greenAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newgoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocationMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow:
        InfoWindow(title: "lideta condominium", snippet: "My location"),
        position: pickUpLatLng,
        markerId: const MarkerId(
          "pickUpId",
        ));
    Marker dropOffLocationMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: "HiLCoE", snippet: "My destination"),
        position: dropOffLatLng,
        markerId: const MarkerId(
          "dropOffId",
        ));

    setState(() {
      markersSet.add(pickUpLocationMarker);
      markersSet.add(dropOffLocationMarker);
    });

    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12.0,
        strokeWidth: 4,
        strokeColor: Colors.yellowAccent,
        circleId: const CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12.0,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
        circleId: const CircleId("dropOffId"));

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    getDrivers().then((_) {
      // Set the isLoading flag to false when the data has been retrieved
      setState(() {
        isLoading = false;
      });
    });
    getTrips();
   // getPassengers();
  }

  Future<void> getDrivers() async {
    List<Driver> driver = await getDriver();
    setState(() {
      this.driver = driver;
    });
  }

  Future<void> getTrips() async {
    List<Trip> trip = await getTrip();
    setState(() {
      this.trip = trip;
    });
  }

  /*Future<void> getPassengers() async {
    List<Passenger> passenger = await getUser(trip[0].userIDs[0].replaceAll(new RegExp(r'[^\w\s]+'),'').trim());
    setState(() {
      this.passenger = passenger;
    });
  }*/

  final databaseReference = FirebaseDatabase.instance.ref('drivers');

  Future<List<Driver>> getDriver() async {
    List<Driver> itemList = [];
    // Get a reference to the Firebase database

    try {
      // Retrieve all items with the specified color
      final dataSnapshot = await databaseReference
          .orderByChild('id')
          .equalTo(widget.request.driverID)
          .once();

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
          rating: '',
          noOfRatings: ''
        );
        itemList.add(item);
      });
    } catch (e) {
      // Log the error and return an empty list
      print('Error: $e');
    }
    return itemList;
  }

  final tripRef = FirebaseDatabase.instance.ref('trips');

  Future<List<Trip>> getTrip() async {
    List<Trip> itemList = [];

    try {
      final dataSnapshot = await tripRef
          .orderByChild('tripID')
          .equalTo(widget.request.tripID)
          .once();

      Map<dynamic, dynamic> values =
      dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        List<String> passengerIDs = value['passengerIDs'] != null ? value['passengerIDs'].toString().split(',') : [];
        passengerIDs = passengerIDs.map((id) => id.replaceAll(new RegExp(r'[\[\]\s]'), '')).toList();
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
          price: value['price'],
          userIDs: passengerIDs,
          date: value['date'],
          time: value['time'],
            availableSeats: value['availableSeats'],
          passengers: value['passengers'],
            );
        itemList.add(item);
      });
    } catch (e) {
      print('Error: $e');
    }
    return itemList;
  }
/*
 final userRef = FirebaseDatabase.instance.ref('users');

  Future<List<Passenger>> getUser(String id) async {
    List<Passenger> itemList = [];
    //String id = 'rK4BBoQjT5c7eK34FrlgOfQKr1K3';
      try {
        final dataSnapshot = await userRef
            .child(trip[0].userIDs[0].toString().trim())
            .once();


          Map<dynamic, dynamic> values =
          dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
          values.forEach((key, value) {
            final item = Passenger(
                name: value['name'],
                email: value['email'],
                phone: value['phone'],
                userImage: value['user_image']);

            itemList.add(item);
          });

      } catch (e) {
        print('Error: $e');
    }

    return itemList;
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(

        children: [
          SizedBox(height: 25,),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(children: [
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
                        trip[0].destinationLocation.toString(),
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
                        trip[0].pickUpLocation.toString(),
                        //'Nefas Silk Lafto',
                        style: const TextStyle(
                          color: Colors.grey,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ])
            ]),
          ),
          Divider(),
          SizedBox(height: 10,),
          if (isLoading)
            Center(
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: CircularProgressIndicator(),
              ),
            )
          else
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [

                      CircleAvatar(
                        backgroundImage: NetworkImage(driver[0].imagePath
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
                            Text(driver[0].name,
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
                                  child: Text(driver[0].carColor),
                                ),
                                Text('${driver[0].carMake} ${driver[0]
                                    .carModel}'),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: RatingBarIndicator(
                                itemBuilder: (context, index) =>
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                rating: 1,
                                itemSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      //requestRide(trips[index]);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.greenAccent,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Call Driver',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          SizedBox(height: 20,),
          Container(
            height: 250,
            child: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  polylines: polylineSet,
                  zoomGesturesEnabled: true,
                  markers: markersSet,
                  circles: circlesSet,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  mapToolbarEnabled: false,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    newgoogleMapController = controller;
                    getPlaceDirection();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3:00 PM'),
                    Text('Thursday 10th March 2020'),
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
          ),
          Divider(),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          const Text('Distance to driver'),
                          Text(
                              '0.8 kms'),
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
                    Text(trip[0].price.toString()),
                    const SizedBox(
                      height: 30,
                    ),
                  ]),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Distance to Drop-Off'),
                    Text('5.5 kms'),
                    const SizedBox(
                      height: 30,
                    ),
                  ]),
            ],
          ),
          SizedBox(
            height: 50,
            width: 300,
            child: ElevatedButton(
              onPressed: () {
                //requestRide(trips[index]);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cancel Ride',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
