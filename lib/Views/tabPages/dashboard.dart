import 'package:car_pool_driver/Constants/widgets/loading.dart';
import 'package:car_pool_driver/config_map.dart';
import 'package:car_pool_driver/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:car_pool_driver/Constants/styles/colors.dart';
import 'package:car_pool_driver/Views/data%20handler/app_data.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../Constants/widgets/toast.dart';
import '../assistants/assistant_methods.dart';
import '../trips/search_screen.dart';
import 'available_drivers.dart';

class Dashboard extends StatefulWidget {
  static const String idScreen = "dashboard";

  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static const String idScreen = "dashboard";
  User? currentUser;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newgoogleMapController;
  static const CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(9.1450, 40.4897), zoom: 1);

  List<LatLng> pLineCoordinates = [];

  Set<Polyline> polylineSet = {};

  late Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingMap = 0;

  String? price;

  TextEditingController pickUpLocationController = TextEditingController();
  TextEditingController destinationLocationController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController destinationLatitudeController = TextEditingController();
  TextEditingController destinationLongitudeController =
      TextEditingController();

  late String passengers;
  final _formKey = GlobalKey<FormState>();
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  void locatePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 20.0);
    newgoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    // ignore: use_build_context_synchronously
    String address =
        // ignore: use_build_context_synchronously
        await AssistantMethods.searchCoordinateAddress(position, context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? pickUpLocation =
        Provider.of<AppData>(context).pickUpLocation?.placeName;
    pickUpLocationController.text = (pickUpLocation.toString() == 'null') ? 'Retrieving Location...' : pickUpLocation.toString();
    String? destination =
        Provider.of<AppData>(context).dropOffLocation?.placeName;
    destinationLocationController.text = (destination.toString() == 'null') ? 'Enter Destination' : destination.toString();
    double? locationLatitude =
        Provider.of<AppData>(context).pickUpLocation?.latitude;
    latitudeController.text = locationLatitude.toString();
    double? locationLongitude =
        Provider.of<AppData>(context).pickUpLocation?.longitude;
    longitudeController.text = locationLongitude.toString();
    double? destinationLatitude =
        Provider.of<AppData>(context).dropOffLocation?.latitude;
    destinationLatitudeController.text = destinationLatitude.toString();
    double? destinationLongitude =
        Provider.of<AppData>(context).dropOffLocation?.longitude;
    destinationLongitudeController.text = destinationLongitude.toString();
    int count = 0;
    return Scaffold(

      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingMap),
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
              setState(() {
                bottomPaddingMap = 300.0;
              });
              locatePosition();
            },
          ),
          Positioned(
            left: 0.0,
            top: 0.0,
            right: 0.0,
            bottom: 0.0,
            child:Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/bg.jpg"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Align(
                        child: Container(
                          height: 270,
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 10.0,
                            child:Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children:
                                      <Widget>[
                                        Image.asset(
                                          "images/PickUpDestination.png",
                                          width: 20,
                                          height: 160,
                                        ),
                                        Flexible(
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8.0, 15.0, 8.0, 8.0),
                                                  child: TextFormField(
                                                    controller: pickUpLocationController,
                                                    decoration: const InputDecoration(
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.greenAccent),
                                                        ),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors.greenAccent)),
                                                        labelText: "Pick-Up",
                                                        hintStyle: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                        )),
                                                    style: const TextStyle(fontSize: 17.0),
                                                    readOnly: true,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 8.0),
                                                  child: TextFormField(
                                                    controller: destinationLocationController,
                                                    decoration: const InputDecoration(
                                                        enabledBorder: UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color: Colors.greenAccent),
                                                        ),
                                                        focusedBorder: UnderlineInputBorder(
                                                            borderSide: BorderSide(
                                                                color: Colors.greenAccent)),
                                                        labelText: 'Drop-Off',
                                                        hintStyle: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                        )),
                                                    style: const TextStyle(fontSize: 17.0),
                                                    readOnly: true,
                                                    onTap: () async {
                                                      var res = await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: ((context) =>
                                                              const SearchScreen())));
                                                      if (res == "obtainDirection") {
                                                        await getPlaceDirection();
                                                      }
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height: 10,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                          padding: const EdgeInsets.all(0),
                                          height: 70,
                                          width: double.infinity,
                                          child: ElevatedButton(
                                              style: ButtonStyle(
                                                elevation: MaterialStateProperty.all(4.0),
                                                backgroundColor:
                                                MaterialStateProperty.all(Colors.greenAccent),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(MaterialPageRoute(
                                                  builder: (context) => AvailableDrivers(
                                                    userLatPos: latitudeController.text,
                                                    userLongPos: longitudeController.text,
                                                    userDestinationLatPos: destinationLatitudeController.text,
                                                    userDestinationLongPos: destinationLongitudeController.text,
                                                    destinationLocation:  destinationLocationController.text,

                                                  )));
                                              },
                                              child: const Text(
                                                "Search",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, fontSize: 18),
                                              ))),
                                    ),
                                  )
                                ]),
                          ),

                        ),

                      ),
                    ),
                    Column(
                      children:<Widget> [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.635,),
                        Expanded(
                            child: ListView.builder(
                                itemCount: (count == 0) ? 1 : count,
                                itemBuilder: (context, index){
                                  if(count == 0){
                                    return Center(
                                      child:Column(
                                        children: [
                                          Image.asset(
                                            "images/noTrips.jpg",
                                            height: 140,
                                          ),
                                          const SizedBox(height: 5,),
                                          const Text("YOU HAVE NO BOOKED TRIPS FOR NOW!!!",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),

                                        ],
                                      ),
                                    );
                                  }
                                  else{
                                    return Center(
                                        child: Text('sjdaoo')
                                    );
                                  }

                                }
                            )
                        ),
                      ],
                    ),
                  ],
                )),

          ),

        ],
      ),
    );
  }

  Future<void> _saveToFirebase(BuildContext context) async {
    String dropdownvalue = '1 passenger';
    var currentSelectedValue;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text("Add a pool")),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: pickUpLocationController,
                      enabled: false,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            Provider.of<AppData>(context).pickUpLocation != null
                                ? Provider.of<AppData>(context)
                                    .pickUpLocation!
                                    .placeName
                                : 'Wait while fetching your location',
                      ),
                    ),
                    const SizedBox(
                      height: 13.0,
                    ),
                    TextFormField(
                      controller: destinationLocationController,
                      enabled: false,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText:
                            Provider.of<AppData>(context).dropOffLocation !=
                                    null
                                ? Provider.of<AppData>(context)
                                    .dropOffLocation!
                                    .placeName
                                : 'Wait for fetch',
                      ),
                    ),
                    const SizedBox(
                      height: 13.0,
                    ),
                    ButtonTheme(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value == null ? 'Passengers' : null,
                          value: currentSelectedValue,
                          hint: const Text('Passengers'),
                          onChanged: (newValue) {
                            setState(() {
                              currentSelectedValue = newValue;
                              this.passengers = newValue!;
                            });
                          },
                          items: <String>[
                            '1 Passenger',
                            '2 Passengers',
                            '3 Passengers',
                            '4 Passengers',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 13.0,
                    ),
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Price per passenger',
                      ),
                      onChanged: (value) {
                        this.price = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.red,
                textColor: Colors.white,
                child: const Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: const Text('Save'),
                onPressed: () {
                  setState(() {
                    _saveCarPool();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;

    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);
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
        color: Colors.pink,
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
            InfoWindow(title: initialPos.placeName, snippet: "My location"),
        position: pickUpLatLng,
        markerId: const MarkerId(
          "pickUpId",
        ));
    Marker dropOffLocationMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: "My destination"),
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

  Future<void> _saveCarPool() async {
    int index = 0;
    final _auth = FirebaseAuth.instance;
    Timer timestamp;
    String tripId = DateTime.now().microsecondsSinceEpoch.toString();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return LoadingScreen(message: "Adding to the pool...");
            });
        await tripsRef.child(tripId).set({
          "triId":tripId,
          "pickUpLocation": pickUpLocationController.text.toString(),
          "destinationLocation": destinationLocationController.text.toString(),
          "locationLatitude": latitudeController.text,
          "locationLongitude": longitudeController.text,
          "destinationLatitude": destinationLatitudeController.text,
          "destinationLongitude": destinationLongitudeController.text,
          "price": price,
          "passengers": passengers,
          "driver_id": _auth.currentUser?.uid.toString(),
        });
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        displayToastMessage(
            "Congratulations,your pool has been added", context);
      } catch (ex) {
        print("Your error is $ex");
        Navigator.pop(context);
        displayToastMessage("Pool has not been added", context);
      }
    }
  }
}
