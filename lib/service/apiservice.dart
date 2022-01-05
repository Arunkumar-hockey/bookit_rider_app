import 'dart:convert';
import 'dart:math';
import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/constants/baseconstants.dart';
import 'package:bookit_rider_app/helper/appdata.dart';
import 'package:bookit_rider_app/model/address.dart';
import 'package:bookit_rider_app/model/allusers.dart';
import 'package:bookit_rider_app/model/directiondetails.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;


class APIService {
  var dio = Dio();
  Future<dynamic> getRequest(String url) async {
    final response = await dio.get(url);

    try {
      if (response.statusCode == 200) {
        String jsonData = response.data;
        var decodeData = json.decode(jsonData);
        return decodeData;
      } else {
        return "failed";
      }
    } catch (e) {
      print(e.toString());
      return "failed";
    }
  }

  Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";

    var response = await dio.get(url);
    if(response.statusCode == 200){
     /* st1 = response.data["results"][0]["address_components"][3]["long_name"].toString();
      st2 = response.data["results"][0]["address_components"][4]["long_name"].toString();
      st3 = response.data["results"][0]["address_components"][5]["long_name"].toString();
      st4 = response.data["results"][0]["address_components"][6]["long_name"].toString();*/
      st4 = response.data["results"][0]["formatted_address"].toString();
      //placeAddress = st1 + "," + st2 + "," + st3 + "," + st4;
      placeAddress = st4;

      Address userPickupAddress = Address(placeFormattedAddress: "", placeName: "", placeId: "", latitude: 0.0, longitude: 0.0);
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickupAddress);
    }
    return placeAddress;
  }

  void getPlaceAddressDetails(String placeId, context) async{
    Get.defaultDialog(
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(width: 15),
          Text('Setting Dropoff, Please wait')
        ],
      ),
      contentPadding: const EdgeInsets.all(10),
      title: '',
    );

    String placeDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapkey";

    var response = await dio.get(placeDetailsUrl);
    Get.back();
    if(response.statusCode == 200) {
      Address address = Address(placeFormattedAddress: "", placeName: "", placeId: "", latitude: 0.0, longitude: 0.0);
      address.placeName = response.data["result"]["name"];
      address.placeId = placeId;
      address.latitude = response.data["result"]["geometry"]["location"]["lat"];
      address.longitude = response.data["result"]["geometry"]["location"]["lng"];

      Provider.of<AppData>(context, listen: false).updateDropoffLocationAddress(address);
      print("This is Drop Off LOcation ::");
      print(address.placeName);
      Navigator.pop(context, "obtainDirection");
      //Get.back(result: "obtainDirection");
    } else {
      return null;
    }
  }

   Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async{
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?destination=${finalPosition.latitude},${finalPosition.longitude}&origin=${initialPosition.latitude},${initialPosition.longitude}&key=$mapkey";

    var response = await dio.get(directionUrl);

    if(response.statusCode == 200) {
      DirectionDetails directionDetails = DirectionDetails(
          distanceValue: 0,
          durationValue: 0,
          distanceText: "",
          durationText: "",
          encodedPoints: "");

      directionDetails.encodedPoints = response.data["routes"][0]["overview_polyline"]["points"];
      directionDetails.distanceText = response.data["routes"][0]["legs"][0]["distance"]["text"];
      directionDetails.distanceValue = response.data["routes"][0]["legs"][0]["distance"]["value"];
      directionDetails.durationText = response.data["routes"][0]["legs"][0]["duration"]["text"];
      directionDetails.durationValue = response.data["routes"][0]["legs"][0]["duration"]["value"];

      return directionDetails;
    } else {
      return null;
    }


  }

   int calculateFares(DirectionDetails directionDetails) {
    double timeTraveledFare = (directionDetails.durationValue / 60) * 0.20;
    double distanceTraveledFare = (directionDetails.distanceValue / 1000) * 0.20;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    //Local Currency
    //1$ = 160 RS
    //double totalLocalAmount = totalFareAmount * 160

    return totalFareAmount.truncate();

  }

    void getCurrentOnlineUserInfo() async{
   firebaseUser = await FirebaseAuth.instance.currentUser!;
   String userId = firebaseUser.uid;
   DatabaseReference reference = FirebaseDatabase.instance.reference().child("users").child(userId);

   reference.once().then((DataSnapshot dataSnapShot) {
     if(dataSnapShot.value != null) {
       userCurrentInfo = Users.fromSnapshot(dataSnapShot);
     }
   });
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

   sendNotificationToDriver(String token,context, String ride_request_id) async{
    var destination = Provider.of<AppData>(context,listen: false).dropoffLocation;
   Map<String, String> headerMap = {
     'Content-Type' : 'application/json',
     'Authorization' : serverToken,
  };

   Map notificationMap = {
     'body' : 'Dropoff Address, ${destination?.placeName ?? ''}',
     'title' : 'New Ride Request'
  };

   Map dataMap = {
     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
     'id': '1',
     'status': 'done',
     'ride_request_id': ride_request_id,
   };

   Map sendNotificationMap = {
     "notification": notificationMap,
     "data": dataMap,
     "priority": "high",
     "to": token,
   };

    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
   var response = await http.post(
       url,
       headers: headerMap,
     body: jsonEncode(sendNotificationMap),
   );
  // return response;
  }

  static String formatTripDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";

    return formattedDate;
  }

}

