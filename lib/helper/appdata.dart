import 'dart:html';

import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/model/address.dart';

class AppData extends ChangeNotifier{
   Address? pickUpLocation, dropoffLocation;

   String earnings = "0";
   int counterTrips = 0;
   List<String> tripHistoryKeys = [];
   List<History> tripHistoryDataList = [];

  void updatePickUpLocationAddress(Address pickupAddress) {
    pickUpLocation =  pickupAddress;
    notifyListeners();
  }

  void updateDropoffLocationAddress(Address dropoffAddress) {
    dropoffLocation = dropoffAddress;
    notifyListeners();
  }

   void updateEarnings(String updatedEarnings) {
     earnings = updatedEarnings;
     notifyListeners();
   }

   void updateTripCounter(int tripCounter) {
     counterTrips = tripCounter;
     notifyListeners();
   }

   void updateTripKeys(List<String> newKeys) {
     tripHistoryKeys = newKeys;
     notifyListeners();
   }

   void updateTripHistoryData(History eachHistory) {
     tripHistoryDataList.add(eachHistory);
     notifyListeners();
   }

}