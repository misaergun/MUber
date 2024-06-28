import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/trips_history_model.dart';
import 'package:users_app/models/user_model.dart';

import '../infoHandler/app_info.dart';

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
  static void readCurrentOnlineUserInfo()
  {
    currentFirebaseUser = fAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child("users").child(currentFirebaseUser!.uid);


    userRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
        {
          userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);

        }
    });
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

  static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {
    double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.5;
    double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.5;

    // 1 USD = 32 TL
    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double localCurrencyTotalFare = totalFareAmount * 32;

    return double.parse(localCurrencyTotalFare.toStringAsFixed(1)); //double olduğu için virgülden sonra 1 sayı olsun diye yaptım sonra tekrar double'a çevirip döndürdük
  }

  //retrieve the trips keys for online user
  //trip key =ride request key

  static void readTripKeysForOnlineUser(context)
  {
    FirebaseDatabase.instance.ref()
        .child("All Ride Requests")
        .orderByChild("userName")
        .equalTo(userModelCurrentInfo!.name)
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
        Provider.of<AppInfo>(context, listen:false).updateOverAllTripsHistoryInformation(eachTripHistory);


      });
    }

  }
}