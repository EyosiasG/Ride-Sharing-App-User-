import 'dart:core';
import 'dart:core';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../global/global.dart';


class TripHistoryTabPage extends StatefulWidget {
  const TripHistoryTabPage({Key? key}) : super(key: key);

  @override
  State<TripHistoryTabPage> createState() => _TripHistoryTabPageState();
}

class Trip {
  String date;
  String pickUp;
  String dropOff;
  String driverId;
  String seats;
  String time;


  Trip({
    required this.pickUp,
    required this.driverId,
    required this.date,
    required this.dropOff,
    required this.seats,
    required this.time
  });
}
class FirebaseService {

  final databaseReference = FirebaseDatabase.instance.ref('trips');
  Future<List<Trip>> getItemsByColor(String driverId) async {
    List<Trip> itemList = [];
    // Get a reference to the Firebase database


    try {
      // Retrieve all items with the specified color
      final dataSnapshot = await databaseReference
          .orderByChild('driver_id')
          .equalTo(driverId)
          .once();

      // Convert the retrieved data to a list of Item objects

      Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        final item = Trip(
          pickUp: value['pick_up'],
          driverId: value['driver_id'],
          date: value['date'],
          dropOff: value['drop_off'],
          seats: value['seats'],
          time: value['time']
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


class _TripHistoryTabPageState extends State<TripHistoryTabPage> {
  final FirebaseService firebaseService = FirebaseService();
  List<Trip> trips = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrips();

  }


  Future<void> getTrips() async {
    List<Trip> trips = await firebaseService.getItemsByColor(currentFirebaseUser!.uid.toString());
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
                    child: Text("FINISHED",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent
                      ),),
                  ),
                  title : Text(trips[index].pickUp.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w100,
                    ),),
                  subtitle:Text(trips[index].date.toString() +' at ' + trips[index].time.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),),

                  trailing: const Icon(Icons.arrow_forward),
                  onTap: (){
                  //  Navigator.of(context).push(MaterialPageRoute(
                    //  builder: (context) => TripHistoryDetails(item:trips[index]),
                   // ));
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
