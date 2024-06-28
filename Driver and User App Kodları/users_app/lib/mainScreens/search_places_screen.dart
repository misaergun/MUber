import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/models/predicted_places.dart';
import 'package:users_app/widgets/place_prediction_tile.dart';

import '../global/map_key.dart';

class SearchPlacesScreen extends StatefulWidget {

  @override
  _SearchPlacesScreenState createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen>
{
  List<PredictedPlaces> placePredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async
  {
    if(inputText.length > 1)
      {
        String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:TR";

        var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

        if(responseAutoCompleteSearch == "Error occured. Failed. No response.")
          {
            return;
          }

        if(responseAutoCompleteSearch["status"] == "OK")
        {
          var placePredictions = responseAutoCompleteSearch["predictions"];

          //converting predictions to list
          var placesPredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

          setState(() {
            placePredictedList = placesPredictionsList;
          });
        }

      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
      children:[
        //search place ui
        Container(
          height: 180,
          decoration:const BoxDecoration(
            color: Colors.black87,
            boxShadow: [
              BoxShadow(
                color: Colors.white54,
                blurRadius: 8,
                spreadRadius: 0.5,
                offset: Offset(
                  0.7,
                  0.7,
                ),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [

                const SizedBox(height: 25.0),

                Stack(
                  children: [
                    GestureDetector(
                      onTap:()
                      {
                        Navigator.pop(context);
                      },
                      child:const Icon(
                        Icons.arrow_back,
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 10,),

                    const Center(
                      child: Text(
                        "Search & Set Drop-Off Location",
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0),

                Row(
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      color: Colors.white54,
                    ),

                    const SizedBox(width: 18.0,),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged:(valueTyped)
                          {
                            findPlaceAutoCompleteSearch(valueTyped);
                          },
                          decoration:const InputDecoration(
                            hintText: "Search",
                            fillColor: Colors.white54,
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 11.0,
                              top: 8.0,
                              bottom: 8.0,
                            )

                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        //display place predictions result
        (placePredictedList.length > 0)
            ? Expanded(
          child: ListView.separated(
            itemCount: placePredictedList.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index)
            {
              return PlacePredictionTileDesign
                (
                  predictedPlaces: placePredictedList[index],
                );
            },
            separatorBuilder: (BuildContext context, int index)
            {
              return const Divider(
                height: 1,
                color: Colors.grey,
                thickness: 1,
              );
            },
          ),
        )
            : Container(),
       ],
      ),
    );
  }
}
