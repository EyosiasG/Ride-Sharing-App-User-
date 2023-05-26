import 'dart:core';
import 'dart:core';

import 'package:car_pool_driver/Views/tabPages/available_drivers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../Models/trip.dart';
import '../../global/global.dart';

class TripHistoryTabPage extends StatefulWidget {
  const TripHistoryTabPage({Key? key}) : super(key: key);

  @override
  State<TripHistoryTabPage> createState() => _TripHistoryTabPageState();
}

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


class _TripHistoryTabPageState extends State<TripHistoryTabPage> {
  final GetTrips firebaseService = GetTrips();
  List<Trip> trips = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrips();

  }


  Future<void> getTrips() async {
    List<Trip> trips = await firebaseService.getItemsByColor();
    setState(() {
      this.trips = trips;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(trips[index].driverID.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent
                      ),),
                  ),
                  title : Text(trips[index].pickUpLatPos.toString() + ',' + trips[index].pickUpLongPos.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w100,
                    ),),
                  subtitle:Text(trips[index].dropOffLongPos.toString() +' at ' + trips[index].dropOffLatPos.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),),

                  trailing: const Icon(Icons.arrow_forward),
                  onTap: (){
                    //Navigator.of(context).push(MaterialPageRoute(
                      //builder: (context) => TripHistoryDetails(item:trips[index]),
                    //));
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Divider(color: Colors.grey,),
                ),
              ],
            );
          },
        );
     /* body: Column(
        children: [
          Text(itemList.length.toString()),


          ListView.builder(
              shrinkWrap: true,
              itemCount: itemList.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index){
                final item = itemList[index];
                return Card(
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListTile(
                    title : Text(itemList[index].pickUp.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),),
                    subtitle:RichText(
                        text: const TextSpan(
                            text: "4th April , 2023 at 10:37AM",
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontFamily: 'Poppins',
                                color: Colors.black,
                                fontSize: 15),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "\nFinished",
                                  style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.green,
                                      fontSize: 15)
                              )
                            ])
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TripHistoryDetails(item:item),
                      ));
                    },
                  ),
                ),

                );
              }

              ),
        ],
      ),*/
  }
}
