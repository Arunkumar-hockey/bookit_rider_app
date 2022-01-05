import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/model/allusers.dart';

String mapkey = "AIzaSyD6F_4FcuK6pNtgVPcNDfkJDhl6Sl_VIe4";

late User firebaseUser;

Users? userCurrentInfo;

int driverRequestTimeOut = 40;
String statusRide = "";
String rideStatus = "Driver is Coming";
String carDetailsDriver = "";
String driverName = "";
String driverPhone = "";

double starCounter = 0.0;
String title = '';
String carRideType = '';

String serverToken = "key=AAAAG-7E2fg:APA91bHZCvWdbNUsTvtTuZkxMPKGXr1vnyQ1l89opHNmWPkUG5YT1HKEhoEEsD391L-F6_Yogg0S3e_RdweZte4icVSmdjnmJX7cBv69Gv-biMiA08EHsPh7aWnGEmQW9S7idkXXVRaE";