import 'package:car_pool_driver/Views/tabPages/support_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../authentication/login_screen.dart';
import '../../global/global.dart';
import '../../widgets/profile_widget.dart';

class ProfileTabPage extends StatefulWidget {
  const ProfileTabPage({Key? key}) : super(key: key);

  @override
  State<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends State<ProfileTabPage> {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('users');
  late String name,email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
          stream: ref.child(currentFirebaseUser!.uid.toString()).onValue,
          builder: (context, AsyncSnapshot snapshot){

          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          else if(snapshot.hasData){
            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            name = map['name'];
            email = map['email'];
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 20,),
                ProfileWidget(
                    imagePath: map['userImage'],
                    onClicked: () async {}),

                const SizedBox(height: 15,),
                buildName(),
                const Divider(),
                const SizedBox(height: 15,),
                settingsTile(context),

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
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
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
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('325'),
            ),
            Text('ratings'),
          ],
        )
      ],
    ),
  );
}
Widget settingsTile(BuildContext context) {
  return Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
      child: ListTile(
        onTap: () {},
        leading: const Icon(Icons.person),
        title: const Text('Edit Account'),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
      child:  ListTile(
        onTap: () {},
        leading: const Icon(Icons.notifications),
        title: const Text('Notifications'),
      ),
    ),
    const Divider(
      endIndent: 18,
      indent: 18,
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
      child:  ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const MyFeedback()));
        },
        leading: const Icon(Icons.feedback),
        title: const Text('Feedback'),
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
      child:  ListTile(
        onTap: () {},
        leading: const Icon(Icons.receipt),
        title: const Text('Terms & Conditions'),
      ),
    ),
    const Divider(
      endIndent: 18,
      indent: 18,
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(8, 1, 8, 8),
      child:  ListTile(
        onTap: () {
          fAuth.signOut();
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
        },
        leading: const Icon(Icons.logout),
        title: const Text('Logout'),
      ),
    ),
  ]);
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
            trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),

          )
        ],
      ),
    );
  }
}


