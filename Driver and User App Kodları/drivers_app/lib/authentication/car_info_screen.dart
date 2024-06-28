import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/splashScreen/splash_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {

  TextEditingController carModelTextEditingController =TextEditingController();
  TextEditingController carNumberTextEditingController =TextEditingController();
  TextEditingController carColorTextEditingController =TextEditingController();

  List<String> carTypesList = ["uber-x", "uber-go", "bike"];
  String? selectedCarType;

  saveCarInfo()
  {
    Map driverCarInfoMap = {
      "car_color":carColorTextEditingController.text.trim(),
      "car_number":carNumberTextEditingController.text.trim(),
      "car_model":carModelTextEditingController.text.trim(),
      "type":selectedCarType,
    };

    DatabaseReference driversRef = FirebaseDatabase.instance.ref().child("drivers");
    driversRef.child(currentFirebaseUser!.uid).child("car_details").set(driverCarInfoMap);

    Fluttertoast.showToast(msg: "Car details has been saved.");
    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [

              const SizedBox(height: 24,),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/logo1.png"),
              ),

              const SizedBox(height: 10,),

              const Text(
                "Write Car Details",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TextField(
                controller: carModelTextEditingController,
                style: const TextStyle(
                    color:Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Car Model",
                  hintText: "Car Model",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),

                ),
              ),

              TextField(
                controller: carNumberTextEditingController,
                style: const TextStyle(
                    color:Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Car Plate Number",
                  hintText: "Car Plate Number",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),

                ),
              ),

              TextField(
                controller: carColorTextEditingController,
                style: const TextStyle(
                    color:Colors.grey
                ),
                decoration: const InputDecoration(
                  labelText: "Car Color",
                  hintText: "Car Color",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),

                ),
              ),

              const SizedBox(height: 20,),

              DropdownButton(
                iconSize: 35,
                dropdownColor: Colors.white24,
                hint: const Text(
                  "Please choose Car Type",
                  style:TextStyle(
                    fontSize: 20.0,
                    color: Colors.grey,
                  ),
                ),
                value: selectedCarType,
                onChanged: (newValue)
                  {
                    setState(() {
                      selectedCarType= newValue.toString();
                    });
                  },
                items: carTypesList.map((car){
                  return DropdownMenuItem(
                      child: Text(
                        car,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    value: car,
                  );
                }).toList(),
              ),

              const SizedBox(height:20,),

              ElevatedButton(
                onPressed: (){
                  if(carColorTextEditingController.text.isNotEmpty
                      && carNumberTextEditingController.text.isNotEmpty
                      && carModelTextEditingController.text.isNotEmpty
                      && selectedCarType != null)
                  {
                    saveCarInfo();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                ),
                child:const Text(
                  "Save All",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,

                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
