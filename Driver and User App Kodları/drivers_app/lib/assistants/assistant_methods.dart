import 'package:drivers_app/assistants/request_assistant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import '../models/trips_history_model.dart';
import '../models/user_model.dart';

class AssistantMethods
{
  static Future<String> searchAddressForGeographicCoordinates(Position position, context)async
  {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error occured. Failed. No response.")
      {
        humanReadableAddress = requestResponse["results"][0]["formatted_address"];

        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationLatitude = position.latitude.toString();
        userPickUpAddress.locationLongitude = position.longitude.toString();
        userPickUpAddress.locationName = humanReadableAddress;

        Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);



      }

    return humanReadableAddress;

  }

  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async
  {
    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";


   var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

   if(responseDirectionApi == "Error occured. Failed. No response.")
     {
       return null;
     }

   DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
   directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];
   directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
   directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

   directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
   directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

   return directionDetailsInfo;
  }

  static pauseLiveLocationUpdates()
  {
    streamSubscriptionPosition!.pause();
    Geofire.removeLocation(currentFirebaseUser!.uid);

  }

  static resumeLiveLocationUpdates()
  {
    streamSubscriptionPosition!.resume();
    Geofire.setLocation(
        currentFirebaseUser!.uid,
        driverCurrentPosition!.latitude,
        driverCurrentPosition!.longitude);

  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.5;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.5;

    // 1 USD = 32 TL
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 32;

    if(driverVehicleType == "bike")
    {
      double resultFareAmount = (localCurrencyTotalFare.truncate()) / 2.0;
      return resultFareAmount;
    }
    else if(driverVehicleType == "uber-go")
    {
      return localCurrencyTotalFare.truncate().toDouble();
    }
    else if(driverVehicleType == "uber-x")
    {
      double resultFareAmount = (localCurrencyTotalFare.truncate()) *2.0;
      return resultFareAmount;
    }
    else
    {
      return localCurrencyTotalFare.truncate().toDouble();
    }

  }

  static void readTripKeysForOnlineDriver(context)
  {
    FirebaseDatabase.instance.ref()
        .child("All Ride Requests")
        .orderByChild("driverId")
        .equalTo(fAuth.currentUser!.uid)
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number of trips and share it whit provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen:false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trip keys with provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key,value)
        {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen:false).updateOverAllTripsKeys(tripsKeysList);

        //read trips history info
        readTripsHistoryInformation(context);



      }
    });
  }

  static void readTripsHistoryInformation (context)
  {
    var tripsAllKeys = Provider.of<AppInfo>(context, listen:false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys) //we did this for look over all of the keys
        {
      FirebaseDatabase.instance.ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);
        
        if((snap.snapshot.value as Map)["status"] == "ended")
          {
            Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
          }

      });
    }
  }
  //readDriverEarnings
  static void readDriverEarnings(context)
  {
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("earnings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String driverEarnings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverTotalEarnings(driverEarnings);
      }
    });

    readTripKeysForOnlineDriver(context);
  }

  static void readDriverRatings(context)
  {

    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(fAuth.currentUser!.uid)
        .child("ratings")
        .once()
        .then((snap)
    {
      if(snap.snapshot.value != null)
      {
        String driverRatings = snap.snapshot.value.toString();
        Provider.of<AppInfo>(context, listen: false).updateDriverAverageEarnings(driverRatings);
      }
    });
  }

}