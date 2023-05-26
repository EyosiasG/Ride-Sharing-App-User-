import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../global/global.dart';
import '../../widgets/profile_widget.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  //final driver = DriverPreferences.myDriver;
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('drivers');
  late String name,email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
          stream: ref.child(currentFirebaseUser!.uid.toString()).onValue,
          builder: (context, AsyncSnapshot snapshot){

          if(!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          else if(snapshot.hasData){
            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            name = map['name'];
            email = map['email'];
            return ListView(
              physics: BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 15,),
                const Text(
                  "My Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),
                ),
                const SizedBox(height: 15,),


                ProfileWidget(
                    imagePath: map['driver_image'],
                    onClicked: () async {}),

                const SizedBox(height: 20,),
                buildName(),
                const SizedBox(height: 24,),
                buildStat(),
                const SizedBox(height: 20,),

                const Text(
                  "Car Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                ),
                ReusableRow(title: 'Car', value: map['car_make'] + ' ' + map['car_model'] + ' ' + map['car_year'], iconData: Icons.car_repair),

                ReusableRow(title: 'Plate Number', value: map['car_plateNo'], iconData: Icons.numbers),

                ReusableRow(title: 'Car Color', value: map['car_color'], iconData: Icons.color_lens),

                //DriverStats(),
              ],
            );
          }
          else{
            return Center(child:  Text('Something went wrong',
                style: Theme.of(context).textTheme.subtitle1));
          }
        }
      )
    );

}
  Widget buildName() => Column(
    children: [
      Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      const SizedBox(height: 5,),
      Text(
        email,
        style: const TextStyle(
            color:  Colors.grey
        ),
      )
    ],
  );

  Widget buildStat() => Padding(
    padding: const EdgeInsets.only(left: 2.0, right: 2.0),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, //Center Row contents horizontally,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.star, color: Colors.yellow),
            ),
            Text(
              '4.5',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
          ],
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('325'),
            ),
            Text('ratings'),
          ],
        )
      ],
    ),
  );
}
class ReusableRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;

  const ReusableRow({Key? key, required this.title, required this.value, required this.iconData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left:10.0, right: 35.0),
      child: Column(
        children: [
          ListTile(
            title:Text(title),
            leading: Icon(iconData),
            trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),

          )
        ],
      ),
    );
  }
}


