import 'package:drivers_app/mainScreens/trips_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';

class EarningsTabPage extends StatefulWidget {
  const EarningsTabPage({super.key});

  @override
  State<EarningsTabPage> createState() => _EarningsTabPageState();
}

class _EarningsTabPageState extends State<EarningsTabPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child:Column(
        children: [

          Container(
            color: Colors.black,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Column(
                children: [
                  const Text(
                    "Total Earnings",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 10,),

                  Text(
                    "\$ 200",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,

                    ),
                  )
                ],
              ),
            ),
          ),

          //total number of trips
          ElevatedButton(
              onPressed: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (c) => TripsHistoryScreen()));
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white54,
            ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Row(
                  children: [
                    Image.asset(
                      "images/car_logo.png",
                      width: 100,
                    ),

                    const SizedBox(
                      width: 20,
                    ),

                    const Text(
                      "Trips completed: ",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),

                    Expanded(
                      child: Text(
                        Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length.toString(),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
          ),

        ],
      )
    );
  }
}
