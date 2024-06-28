import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:drivers_app/global/global.dart';
import 'package:drivers_app/mainScreens/new_trip_screen.dart';
import 'package:drivers_app/models/user_ride_request_information.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';


class NotificationDialogBox extends StatefulWidget {

  UserRideRequestInformation? userRideRequestDetails;

  NotificationDialogBox({this.userRideRequestDetails});



  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context)
  {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation:2,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: 14,),

            Image.asset(
                "images/car_logo.png",
              width: 160,
            ),

            const SizedBox(height: 10,),

            //New Ride Request title
            const Text(
              "New Ride Request!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 12.0,),

            //origin and destination addresses
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  //origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/origin.png",
                        width: 30,
                        height: 30,
                      ),

                      const SizedBox(width: 14,),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.originAddress!,
                            style:const TextStyle(
                              fontSize: 16,

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 25.0),

                  //destination location with icon
                  Row(
                    children: [
                      Image.asset(
                        "images/destination.png",
                        width: 30,
                        height: 30,
                      ),

                      const SizedBox(width: 14,),

                      Expanded(
                        child: Container(
                          child: Text(
                            widget.userRideRequestDetails!.destinationAddress!,
                            style:const TextStyle(
                              fontSize: 16,

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),  
            ),

            //cancel and accept button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //cancel the ride request
                    FirebaseDatabase.instance.ref()
                      .child("All Ride Request")
                      .child(widget.userRideRequestDetails!.rideRequestId!)
                      .remove().then((value)
                    {
                    FirebaseDatabase.instance.ref()
                      .child("drivers")
                      .child(currentFirebaseUser!.uid)
                      .child("newRideStatus")
                      .set("idle");
                    }).then((value)
                    {
                      FirebaseDatabase.instance.ref()
                          .child("drivers")
                          .child(currentFirebaseUser!.uid)
                          .child("tripsHistory").child(widget.userRideRequestDetails!.rideRequestId!)
                          .remove();
                    }).then((value){
                      Fluttertoast.showToast(msg: "Ride request has been cancelled successfully. Restarting app now.");
                    });

                      Future.delayed(const Duration(milliseconds: 3000), ()
                      {
                        SystemNavigator.pop();
                      });

                    },
                    child: Text(
                      "Cancel".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 25.0,),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: ()
                    {
                      audioPlayer.pause();
                      audioPlayer.stop();
                      audioPlayer = AssetsAudioPlayer();

                      //accept the ride request

                      acceptRideRequest(context);

                    },
                    child: Text(
                      "Accept".toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),

                ],
              ),
            ),
            

          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context)
  {
    String getRideRequestId="";
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
        {
          getRideRequestId =snap.snapshot.value.toString();
        }
      else{
        Fluttertoast.showToast(msg: "This ride request does not exists!");
      }



      if(getRideRequestId==widget.userRideRequestDetails!.rideRequestId)
        {

          FirebaseDatabase.instance.ref()
              .child("drivers")
              .child(currentFirebaseUser!.uid)
              .child("newRideStatus")
              .set("accepted");

          AssistantMethods.pauseLiveLocationUpdates();

          //send driver to new ride screen-goes to driver trip screen
          Navigator.push(context, MaterialPageRoute(builder: (c) => NewTripScreen(
              userRideRequestDetails : widget.userRideRequestDetails,
          )));



        }
      else{
        Fluttertoast.showToast(msg: "This ride request does not exists.");
      }
    });
  }
}
