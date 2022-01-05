import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/constants/baseconstants.dart';
import 'package:bookit_rider_app/helper/appdata.dart';
import 'package:bookit_rider_app/model/placepredictions.dart';
import 'package:bookit_rider_app/service/apiservice.dart';
import 'package:bookit_rider_app/widgets/divider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final pickupController = TextEditingController();

  final dropOffController = TextEditingController();

  List<PlacePredictions> placePredictionList = [];
  var dio = Dio();

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation?.placeName ?? "";
    pickupController.text = placeAddress;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Container(
              height: 215,
              decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.black54,
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7))
              ]),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 25, top: 20, right: 25, bottom: 20),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 5),
                    Stack(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                        const Center(
                          child: Text(
                            "Set Drop Off",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        //Image.asset('assets/location.png', height: 16, width: 16),
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: TextField(
                                controller: pickupController,
                                decoration: InputDecoration(
                                    hintText: "Pickup Location",
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 11, top: 8, bottom: 8)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        //Image.asset('assets/location_pin.png', height: 16, width: 16),
                        Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: TextField(
                                controller: dropOffController,
                                decoration: InputDecoration(
                                    hintText: "Where to?",
                                    fillColor: Colors.grey[400],
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 11, top: 8, bottom: 8)),
                                onChanged: (value) {
                                  findPlace(value);
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            (placePredictionList.isNotEmpty)
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListView.separated(
                      itemCount: placePredictionList.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          DividerWidget(),
                      itemBuilder: (context, index) {
                        return PredictionTile(
                            placePredictions: placePredictionList[index]);
                      },
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void findPlace(String placeName) async {
    if (placeName.length > 1) {
      String autocompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapkey&sessiontoken=1234567890&components=country:in";
      var response = await dio.get(autocompleteUrl);
      if (response.statusCode == 200) {
        var predictions = response.data["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();
        setState(() {
          placePredictionList = placesList;
        });
      } else {
        return null;
      }

    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  const PredictionTile({Key? key, required this.placePredictions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        APIService().getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
        child: Column(
          children: [
            const SizedBox(width: 10),
            Row(
              children: <Widget>[
                const Icon(Icons.add_location, color: Colors.black,),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 8),
                      Text(placePredictions.main_text,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 8),
                      Text(
                        placePredictions.secondary_text,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(width: 14)
          ],
        ),
      ),
    );
  }
}
