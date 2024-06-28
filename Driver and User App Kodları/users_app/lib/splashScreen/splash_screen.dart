import 'dart:async';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';import '../assistants/assistant_methods.dart';


import '../global/global.dart';
import '../mainScreens/main_screen.dart';


class MySplashScreen extends StatefulWidget
{
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
{

  startTimer()
  {
    fAuth.currentUser !=null ? AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 3), () async
    {
      Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));

      if(await fAuth.currentUser != null)
      {
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
      }
      else
      {
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }

    });
  }

  @override
  void initState() {
    super.initState();

    startTimer(); //Bu initState kısmında ne çağırırsak çağıralım başlangıçta çalışacak
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo.png"),
      
              const SizedBox(height:10,),
      
      
              const Text(
                "MUber",
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
        ),
      
      ),
    );
  }
}
