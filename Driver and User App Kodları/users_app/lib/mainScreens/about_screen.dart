import 'package:flutter/material.dart';
import 'main_screen.dart';


class AboutScreen extends StatefulWidget
{
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(

        children: [

          Container(
            height: 230,
              child: Center(
                child: Image.asset(
                  "images/car_logo.png",
                      width:300,
                ),
              ),
          ),

          Column(
            children:[
              const Text(
                "MNE Yazılım",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(
                "Clone-Uber application developed with Flutter by Müberra Nisa Ergün.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),

              const SizedBox(
                height: 300,
              ),

              ElevatedButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(
                      color: Colors.white
                  ),
                ),
              ),

              const SizedBox(
                height: 50,
              ),

              const Text(
                "Copyright © MNE Yazılım. All Rights Reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white54,
                ),
              ),



            ],
          ),
        ],
      ),
    );
  }
}
