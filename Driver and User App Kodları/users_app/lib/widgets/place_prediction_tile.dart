//import 'dart:js';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_app/global/map_key.dart';
import 'package:users_app/infoHandler/app_info.dart';
import 'package:users_app/models/directions.dart';
import 'package:users_app/models/predicted_places.dart';
import 'package:users_app/widgets/progress_dialog.dart';

import '../assistants/request_assistant.dart';

class PlacePredictionTileDesign extends StatelessWidget
{
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

//Each of the place predicted options has a separate location,
//and I need to find their locations before making them clickable:
  getPlaceDirectionDetails(String? placeId, context) async
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
          message: "Please wait..",
    ),
    );

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);
    if(responseApi == "Error occured. Failed. No response.")
      {
        return;
      }
    if(responseApi["status"] == "OK")
    {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"].toString();
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"].toString();

        Provider.of<AppInfo>(context, listen:false).updateDropOffLocationAddress(directions);

        Navigator.pop(context, "obtainedDropOff");
      }
  }

  @override
  Widget build(BuildContext context)
  {
    return ElevatedButton(
      onPressed: ()
      {
        getPlaceDirectionDetails(predictedPlaces!.place_id, context);
      },

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,

      ),
      child: Row(
        children: [
           Icon(
            Icons.add_location,
            color: Colors.red[900],
          ),
          const SizedBox(width: 14.0,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8.0,),
                Text(
                  predictedPlaces!.main_text!,
                  overflow: TextOverflow.ellipsis,
                  style:const TextStyle(
                    fontSize: 16.0,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 2.0,),
                Text(
                    predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style:const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white54,
                    ),
                ),
                const SizedBox(height: 8.0,),


              ],
            ),
          ),
        ],
      ),
      );
  }
}

