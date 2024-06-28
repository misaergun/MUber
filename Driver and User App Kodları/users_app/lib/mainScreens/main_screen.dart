// import 'dart:html';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/assistants/geofire_assistant.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/global/global.dart';
import 'package:users_app/main.dart';
import 'package:users_app/mainScreens/rate_driver_screen.dart';
import 'package:users_app/mainScreens/search_places_screen.dart';
import 'package:users_app/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:users_app/models/active_nearby_available_drivers.dart';
import 'package:users_app/models/direction_details_info.dart';
import 'package:users_app/widgets/my_drawer.dart';
import 'package:provider/provider.dart';
import 'package:users_app/widgets/pay_fare_amount_dialog.dart';
import 'package:users_app/widgets/progress_dialog.dart';
import '../infoHandler/app_info.dart';
import '../push_notifications/push_notification_service.dart';


class MainScreen extends StatefulWidget
{

  @override
  State<MainScreen> createState() => _MainScreenState();
}




class _MainScreenState extends State<MainScreen>
{
  final Completer<GoogleMapController> _controllerGoogleMap =
  Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight= 260.0;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circlesSet = {};

  String userName = "Your Name";
  String userEmail = "Your E-mail";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearbyAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;
  String  driverRideStatus ="Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus ="";
  bool requestPositionInfo = true;



  blackThemeGoogleMap()
  {
    newGoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  checkIfLocationPermissionAllowed() async
  {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied)
      {
       _locationPermission = await Geolocator.requestPermission();
      }
  }

  locateUserPosition() async
  {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom:16);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(userCurrentPosition! , context);
    print("this is your address= " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail =userModelCurrentInfo!.email!;

    initializeGeofireListener();

    AssistantMethods.readTripKeysForOnlineUser(context);

  }

  @override
  void initState(){
    super.initState();

    checkIfLocationPermissionAllowed();

  }

  Future<void> saveRideRequestInformation() async
  {
    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap=
    {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation!.locationLongitude.toString(),
    };

    Map destinationLocationMap=
    {
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation!.locationLongitude.toString(),
    };

    Map userInformationMap =
    {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    tripRideRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async
    {
      if(eventSnap.snapshot.value == null)
        {
          return;
        }
      if((eventSnap.snapshot.value as Map)["car_details"] != null)
        {
          setState(() {
            driverCarDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
          });
        }
      if((eventSnap.snapshot.value as Map)["driverPhone"] != null)
      {
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }
      if((eventSnap.snapshot.value as Map)["driverName"] != null)
      {
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"] != null)
        {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
        }

      if((eventSnap.snapshot.value as Map)["driverLocation"] != null)
        {
          double driverCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
          double driverCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

          LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

          //status == accepted
          if(userRideRequestStatus == "accepted")
            {
              updateArrivalTimeUserPickUpLocation(driverCurrentPositionLatLng);
            }

          //status == arrived
          if(userRideRequestStatus == "arrived")
          {
            driverRideStatus = "Driver has arrived.";
          }

          //status == onTrip
          if(userRideRequestStatus == "ontrip")
          {
            updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
          }

          //status == ended
          if(userRideRequestStatus == "ended")
          {
            if((eventSnap.snapshot.value as Map)["fareAmount"] != null)
              {
                double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

                var response = await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext c) => PayFareAmountDialog(
                        fareAmount: fareAmount
                    ),
                );

                if(response == "cashPayed")
                  {
                    //user can rate the driver now
                    if((eventSnap.snapshot.value as Map)["driverId"] != null)
                      {
                        String assignedDriverId =(eventSnap.snapshot.value as Map)["driverId"].toString();

                        Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen(
                          assignedDriverId: assignedDriverId,
                        )));

                        referenceRideRequest!.onDisconnect();
                        tripRideRequestInfoStreamSubscription!.cancel();


                      }

                  }


              }
          }




        }
    });


    onlineNearbyAvailableDriversList = GeofireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  updateArrivalTimeUserPickUpLocation(driverCurrentPositionLatLng) async
  {
    if(requestPositionInfo == true)
      {
        requestPositionInfo = false;

        LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

        var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpPosition
        );

        if(directionDetailsInfo == null)
          {
            return;
          }
        setState(() {
         driverRideStatus = "Driver is coming:  " + directionDetailsInfo.duration_text.toString();
        });

        requestPositionInfo = true;
      }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async
  {
    if(requestPositionInfo == true)
    {
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
          double.parse(dropOffLocation!.locationLatitude!),
          double.parse(dropOffLocation!.locationLongitude!)
      );

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition,
      );

      if(directionDetailsInfo == null)
      {
        return;
      }

      setState(() {
        driverRideStatus =  "Going towards destination: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }



  searchNearestOnlineDrivers () async
  {
    //for any active nearby drivers situation
    if(onlineNearbyAvailableDriversList.length == 0)
      {
        //cancel the ride request
        referenceRideRequest!.remove();

        setState(() {
          polyLineSet.clear();
          markerSet.clear();
          circlesSet.clear();
          pLineCoordinatesList.clear();
        });

        Fluttertoast.showToast(
          msg: "We're sorry, there are no available drivers near you at the moment. Please try again later or change your location and search again.",
          toastLength: Toast.LENGTH_LONG,  //
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,);

        Future.delayed(const Duration(milliseconds: 4000),()
        {
          SystemNavigator.pop();
        });


        return;
      }

    //for active drivers available situation
    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);

    var response = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SelectNearestActiveDriversScreen(referenceRideRequest: referenceRideRequest)));

    if(response == "driverChosed")
    {
      FirebaseDatabase.instance.ref()
          .child("drivers")
          .child(chosenDriverId!)
          .once()
          .then((snap)
      {
        if(snap.snapshot.value != null)
          {
            //send notification to that specific driver
            sendNotificationToDriver(chosenDriverId!);

            //display waiting response ui from driver
            showWaitingResponseUIFromDriver();


                      //RESPONSES

            FirebaseDatabase.instance.ref()
                .child("drivers")
                .child(chosenDriverId!)
                .child("newRideStatus")
                .onValue.listen((eventSnapshot)
            {
              //driver cancel the ride request
              // (newRideStatus = idle)
              if(eventSnapshot.snapshot.value == "idle")
              {
                Fluttertoast.showToast(msg: "The driver has cancelled your request. Please choose another driver.");

                Future.delayed(const Duration(milliseconds: 3000), ()
                {
                  Fluttertoast.showToast(msg: "Please restart app now.");

                  SystemNavigator.pop();
                });
              }

              //driver accept the rideRequest
              // (newRideStatus = accepted)
              if(eventSnapshot.snapshot.value == "accepted")
              {
                //design and display ui for displaying assigned driver information
                showUIForAssignedDriverInfo();
              }
            });
          }
        else
        {
          Fluttertoast.showToast(msg: "This driver do not exist. Try again.");
        }
      });
    }
  }

  showUIForAssignedDriverInfo()
  {
    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 240;
    });

  }

  showWaitingResponseUIFromDriver()
  {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight =260;

    });
  }

  sendNotificationToDriver(String chosenDriverId)
  {
    //spesifik olarak secilen driver'a bildirim göndermek icin yaziyorum
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(chosenDriverId!)
        .child("newRideStatus")
        .set(referenceRideRequest!.key);

    //automate the push notification service
    FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(chosenDriverId)
        .child("token").once().then((snap)
    {
      if(snap.snapshot.value != null)
        {
          String deviceRegistrationToken = snap.snapshot.value.toString();

          //sending notification
          PushNotificationService.sendNotificationToSelectedDriver(
              deviceRegistrationToken,
              context,
              referenceRideRequest!.key.toString());
        }
      else{
        Fluttertoast.showToast(msg: "Please choose another driver.");
        return;
      }
    });


  }

   retrieveOnlineDriversInformation(List onlineNearestDriversList) async
  {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for(int i=0; i<onlineNearestDriversList.length; i++)
    {
      await ref.child(onlineNearestDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot)
      {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
      });
    }
  }





  @override
  Widget build(BuildContext context)
  {
    createActiveNearbyDriverIconMarker();

    return Scaffold(
      key: sKey,
      drawer: Container(
        width:300,
        child: Theme(
          data:Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            polylines: polyLineSet,
            markers: markerSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              //for black theme google map
              blackThemeGoogleMap();

              setState(() {
                bottomPaddingOfMap = 265;
              });

              locateUserPosition();

            },
          ),

          //custom hamburger button for drawer
          Positioned(
            top: 36,
            left: 22,
            child: GestureDetector(
              onTap: ()
              {
                if(openNavigationDrawer)
                  {
                    sKey.currentState!.openDrawer();
                  }
                else
                {
                  //minimize the app
                  SystemNavigator.pop();
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child:Icon(
                  openNavigationDrawer ? Icons.menu : Icons.close,
                  color:Colors.black,
                ),
              ),
            ),
          ),

          //ui for searching location
          Positioned(
            bottom: 0,
            left:0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration:const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration:const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:24,vertical: 18),
                  child: Column(
                    children: [

                      //from
                      Row(
                        children: [
                          const Icon(Icons.add_location_alt_outlined, color: Colors.grey),
                          const SizedBox(width: 12.0,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From:",
                                style: TextStyle(color: Colors.grey,fontSize: 12),
                              ),
                              Text(
                                Provider.of<AppInfo>(context).userPickUpLocation != null
                                ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,40) + "..."
                                : "Not getting address",
                                style: const TextStyle(color: Colors.grey,fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10.0,),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16.0),

                      //to
                      GestureDetector(
                        onTap: () async
                        {
                          //go to search places screen
                          var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPlacesScreen()));


                          if(responseFromSearchScreen == "obtainedDropOff")
                            {
                              setState(() {
                                openNavigationDrawer = false;
                              });

                             //draw routes
                              await drawPolyLineFromOriginToDestination();
                            }
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.add_location_alt_outlined, color: Colors.grey),
                            const SizedBox(width: 12.0,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "To:",
                                  style: TextStyle(color: Colors.grey,fontSize: 12),
                                ),
                                Text(
                                      Provider.of<AppInfo>(context).userDropOffLocation != null
                                      ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                      : "Where to go?",
                                  style: const TextStyle(color: Colors.grey,fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10.0,),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 25.0,),

                      ElevatedButton(
                        child: const Text(
                          "Request a Ride",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: ()
                        {
                          if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null)
                            {
                              saveRideRequestInformation();
                            }
                          else
                            {
                              Fluttertoast.showToast(msg: "Please select destination location.");
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          //ui for waiting response from driver

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: waitingResponseFromDriverContainerHeight,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Waiting for Response\nfrom Driver',
                        duration: const Duration(seconds: 6),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ScaleAnimatedText(
                        'Please wait...',
                        duration: const Duration(seconds: 10),
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 32.0,
                          color: Colors.white,
                          fontFamily: 'Canterbury',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          //ui for displaying assigned driver information
          Positioned(
            bottom: 0,
            left:0,
            right: 0,
            child: Container(
              height: assignedDriverInfoContainerHeight,
              decoration:const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //status of the ride
                    Center(
                      child: Text(
                        driverRideStatus,
                        style: const TextStyle(
                          fontSize:  18,
                          fontWeight: FontWeight.bold,
                          color:Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),

                    const Divider(
                      height: 2,
                      thickness: 2,
                      color: Colors.white54,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    //driver vehicle details
                    Text(
                      driverCarDetails,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize:  16,
                        color:Colors.white54,
                      ),
                    ),

                    const SizedBox(height: 2.0,),

                    //driver name details
                    Text(
                      driverName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize:  18,
                        fontWeight: FontWeight.bold,
                        color:Colors.white54,
                      ),
                    ),

                    const SizedBox(height: 20.0,),




                    //call driver button
                    Center(
                      child: ElevatedButton.icon(
                          onPressed:()
                          {

                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(
                            Icons.phone_android,
                            color: Colors.black54,
                            size: 22,
                          ),
                          label: const Text(
                            "Call Driver",
                                style:TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                      ),
                    ),

                  ],
                ),
              ),

            ),
          )
        ],
      ),
    ) ;
  }

  Future<void> drawPolyLineFromOriginToDestination() async
  {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(double.parse(originPosition!.locationLatitude!), double.parse(originPosition.locationLongitude!));
    var destinationLatLng = LatLng(double.parse(destinationPosition!.locationLatitude!), double.parse(destinationPosition.locationLongitude!));

    showDialog(
        context: context,
        builder:(BuildContext context) => ProgressDialog(message: "Please wait..",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    pLineCoordinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
      {
        decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
        {
          pLineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
        });

        polyLineSet.clear();

        setState(() {
          Polyline polyLine = Polyline(
            color: Colors.blue,
            polylineId: const PolylineId("PolylineID"),
            jointType:  JointType.round,
            points: pLineCoordinatesList,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            geodesic: true,
          );
          polyLineSet.add(polyLine);
        });

        LatLngBounds boundsLatLng;

        //its for to see the map well. It changes the maps view angle according to the route will take.
        if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
        {
          boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
        }
        else if(originLatLng.longitude > destinationLatLng.longitude)
        {
          boundsLatLng = LatLngBounds(
              southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
              northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          );
        }
        else if(originLatLng.latitude > destinationLatLng.latitude)
        {
          boundsLatLng = LatLngBounds(
            southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
            northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          );
        }
        else
        {
          boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
        }

        newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

        Marker originMarker = Marker(
          markerId: const MarkerId("originID"),
          infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
          position: originLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );

        Marker destinationMarker = Marker(
          markerId: const MarkerId("destinationID"),
          infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
          position: destinationLatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );

        setState(() {
          markerSet.add(originMarker);
          markerSet.add(destinationMarker);
        });

        Circle originCircle = Circle(
          circleId: const CircleId("originID"),
          fillColor: Colors.indigo,
          radius: 12,
          strokeWidth: 3,
          strokeColor: Colors.white,
          center: originLatLng,
        );

        Circle destinationCircle = Circle(
          circleId: const CircleId("destinationID"),
          fillColor: Colors.red,
          radius: 12,
          strokeWidth: 3,
          strokeColor: Colors.white,
          center: destinationLatLng,
        );

        setState(() {
          circlesSet.add(originCircle);
          circlesSet.add(destinationCircle);
        });
      }
  }

  initializeGeofireListener()
  {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered: //whenever any driver become online
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude =  map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            if (!GeofireAssistant.activeNearbyAvailableDriversList.any((driver) => driver.driverId == activeNearbyAvailableDriver.driverId)) {
              GeofireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
            }
            if(activeNearbyDriverKeysLoaded == true)
            {
              displayActiveDriversOnUsersMap();
            }

            break;

          case Geofire.onKeyExited: //whenever any driver become offline
            GeofireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onKeyMoved://whenever driver moves -update driver location
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude =  map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeofireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onGeoQueryReady: //display online drivers on users map
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap()
  {
    setState(() {
      markerSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for(ActiveNearbyAvailableDrivers eachDriver in GeofireAssistant.activeNearbyAvailableDriversList)
      {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
        );

        driversMarkerSet.add(marker);
      }
      setState(() {
        markerSet = driversMarkerSet;
      });
    });
  }


  createActiveNearbyDriverIconMarker()
  {
    if(activeNearbyIcon == null)
      {
        ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2,2));
        BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png").then((value)
            {
              activeNearbyIcon = value;
            });
      }
  }
}

