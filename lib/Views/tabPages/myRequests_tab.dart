import 'package:car_pool_driver/Models/request.dart';
import 'package:car_pool_driver/global/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../Models/trip.dart';

final databaseReference = FirebaseDatabase.instance.ref('requests');

Future<List<Request>> getPendingRequests() async {
  List<Request> itemList = [];
  // Get a reference to the Firebase database

  try {
    final dataSnapshot = await databaseReference.once();

    Map<dynamic, dynamic> values =
        dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    values.forEach((key, value) {
      final item = Request(
          requestID: value['requestID'],
          tripID: value['tripID'],
          driverID: value['driverID'],
          userID: value['userID'],
          status: value['status']);
      itemList.add(item);
    });
  } catch (e) {
    // Log the error and return an empty list
    print('Error: $e');
  }
  return itemList;
}

class MyRequests extends StatefulWidget {
  const MyRequests({Key? key}) : super(key: key);

  @override
  State<MyRequests> createState() => _MyRequestsState();
}

class _MyRequestsState extends State<MyRequests> {
  List<Request> requests = [];

  void initState() {
    // TODO: implement initState
    super.initState();
    getRequests();
  }

  Future<void> getRequests() async {
    List<Request> requests = await getPendingRequests();
    setState(() {
      this.requests = requests;
    });
  }

  final ref = FirebaseDatabase.instance.ref('trips');
  final driverRef = FirebaseDatabase.instance.ref('drivers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return buildTripDetail(index);
          }),
    );
  }

  Widget buildTripDetail(int index) => StreamBuilder(
        stream: ref.child(requests[index].tripID).onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData ||
              snapshot.data?.snapshot?.value == null) {
            return Container();
          } else {
            Map<dynamic, dynamic> trip = snapshot.data.snapshot.value;
            return buildDriverData(index, trip);
          }
        },
      );

  Widget buildDriverData(int index, Map<dynamic, dynamic> trip) =>
      StreamBuilder(
        stream: driverRef.child(requests[index].driverID).onValue,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData ||
              snapshot.data?.snapshot?.value == null) {
            return Container();
          } else {
            Map<dynamic, dynamic> driver = snapshot.data.snapshot.value;
            return buildList(index, trip, driver);
          }
        },
      );

  Widget buildList(int index, Map<dynamic, dynamic> trip,
          Map<dynamic, dynamic> driver) =>
      Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Row(children: [
            Image.asset(
              "images/PickUpDestination.png",
              width: 40,
              height: 50,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  trip['destinationLocation'],
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Divider(),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  trip['pickUpLocation'],
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
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(trip['time']),
                  Text(trip['date']),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          Row(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      driver['driver_image'],
                    ),
                    radius: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(driver['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            )),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 0, 3.0, 0),
                          child: Text(driver['phone']),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () {
                    cancelRequest(requests[index]);
                  },
                  child: Text('Cancel'))
            ],
          ),

        ]),
      );

  void cancelRequest(Request request) {
    FirebaseDatabase.instance
        .ref("requests")
        .child(request.requestID)
        .update({"status": "cancelled"});
  }
}
