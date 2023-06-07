import 'package:car_pool_driver/authentication/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../global/global.dart';
import '../mainScreens/main_screen.dart';
import '../widgets/progress_dialog.dart';

class LoginScreen extends StatelessWidget {
  @override
  static const String idScreen = "login";

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  validateForm(BuildContext context)
  async {

    if(!emailTextEditingController.text.contains("@")){
      Fluttertoast.showToast(msg: "email is not valid.");
    }
    else if(passwordTextEditingController.text.isEmpty){
      Fluttertoast.showToast(msg: "password is empty.");
    }
    else{
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext c){
            return ProgressDialog(message: "Logging in, Please wait...",);
          }
      );
      final User? firebaseUser = (
          await fAuth.signInWithEmailAndPassword(
            email: emailTextEditingController.text.trim(),
            password: passwordTextEditingController.text.trim(),
            ).catchError((msg){
              Navigator.pop(context);
              Fluttertoast.showToast(msg: "Error: " + msg.toString());
            })
          ).user;

      if(firebaseUser != null){
        currentFirebaseUser = firebaseUser;
        Fluttertoast.showToast(msg: "Login successful!");
        Navigator.push(context, MaterialPageRoute(builder: (c)=> const MainScreen()));
      }
      else{
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Login not successful!");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 24,),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Image.asset("images/splashScreen.jpg"),
                  ),

                  const SizedBox(height: 10,),
                  const Text(
                      "Welcome Back!",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold
                      )
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: Colors.grey
                    ),
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Email",

                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)
                      ),
                      hintStyle: const TextStyle(
                        color:Colors.grey,
                        fontSize: 10,
                      ),
                      labelStyle: const TextStyle(
                        color:Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: Colors.grey
                    ),
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Password",

                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10.0)
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)
                      ),
                      hintStyle: const TextStyle(
                        color:Colors.grey,
                        fontSize: 10,
                      ),
                      labelStyle: const TextStyle(
                        color:Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                    height: 50,
                    width:300,
                    child: ElevatedButton(
                        onPressed: (){
                          validateForm(context);
                          //Navigator.push(context, MaterialPageRoute(builder: (c)=> CarInfoScreen()));

                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder( //to set border radius to button
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,

                          ),
                        )),
                  ),
                  const SizedBox(height: 12.0),
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: "Dont have an account? ",
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w300,
                                fontFamily: 'Poppins',
                                color: Colors.black)),
                        TextSpan(
                            text: "Sign Up",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (c)=> SignUpScreen())),
                            style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                                color: Colors.lightBlue)),
                      ])),
                ],
              ),
            )
        )
    );
  }
}
