import 'package:firebase_auth/firebase_auth.dart';
import 'package:users_app/models/user_model.dart';
import '../models/direction_details_info.dart';

final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = []; //online driver keys info list
DirectionDetailsInfo? tripDirectionDetailsInfo;
String? chosenDriverId = "";
String driverCarDetails ="";
String driverName ="";
String driverPhone ="";
double countRatingStars=0.0;
String titleStarsRating="";
