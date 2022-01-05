import 'package:bookit_rider_app/constants/baseconstants.dart';
import 'package:bookit_rider_app/controller/authcontroller.dart';
import 'package:bookit_rider_app/helper/appdata.dart';
import 'package:bookit_rider_app/helper/geofire.dart';
import 'package:bookit_rider_app/main.dart';
import 'package:bookit_rider_app/model/directiondetails.dart';
import 'package:bookit_rider_app/model/nearbyavailabledrivers.dart';
import 'package:bookit_rider_app/service/apiservice.dart';
import 'package:bookit_rider_app/view/loginscreen.dart';
import 'package:bookit_rider_app/view/profilescreen.dart';
import 'package:bookit_rider_app/view/ratingscreen.dart';
import 'package:bookit_rider_app/view/searchscreen.dart';
import 'package:bookit_rider_app/widgets/collectfaredialog.dart';
import 'package:bookit_rider_app/widgets/divider.dart';
import 'package:bookit_rider_app/widgets/nodriveravailabilitydialog.dart';
import 'package:flutter/cupertino.dart';
import '../allpackages.dart';

class MainScreen extends StatefulWidget {
  String email;
  MainScreen({Key? key, required this.email}) : super(key: key);

  static const String idScreen = "Main";
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final controller = Get.put(AuthController());
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  DirectionDetails? tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  late Position currentPosition;

  var geoLocator = Geolocator();

  double bottomPaddingOfMap = 0;

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  BitmapDescriptor? nearByIcon;

  double riderDetailsContainer = 0;
  double requestRiderContainerHeight = 0;
  double searchContainerHeight = 200;
  double driverDetailsContainerHeight = 0;

  bool drawerOpen = true;
  bool nearbyAvailableDriverKeysLoaded = false;

  late DatabaseReference rideRequestRef;

  late List<NearbyAvailableDrivers> availableDrivers;

  String state = "normal";

  late StreamSubscription<Event> rideStreamSubscription;

  bool isRequestingPositionDetails = false;

  String userName = "";

  static final List<String> items = <String> [
    'Cash',
    'Online Payment'
  ];
  String value = items.first;

  @override
  void initState() {
    super.initState();
    APIService().getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropoffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp!.latitude.toString(),
      "longitude": pickUp.longitude.toString()
    };

    Map dropOffLocMap = {
      "latitude": dropOff!.latitude.toString(),
      "longitude": dropOff.longitude.toString()
    };

    Map rideInfoMap = {
      "driver_id": "Waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": /* userCurrentInfo?.name ?? '' */ 'Arun Kumar',
      "rider_phone": /* userCurrentInfo?.phone ?? '' */ '+919659141331',
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "ride_type": carRideType
    };

    rideRequestRef.set(rideInfoMap);
    //var re = rideRequestRef.push().set(rideInfoMap);

    rideStreamSubscription = rideRequestRef.onValue.listen((event) async {
      if (event.snapshot.value == null) {
        return;
      }
      if (event.snapshot.value["car_details"] != null) {
        setState(() {
          carDetailsDriver = event.snapshot.value["car_details"].toString();
        });
      }
      if (event.snapshot.value["driver_name"] != null) {
        setState(() {
          driverName = event.snapshot.value["driver_name"].toString();
        });
      }
      if (event.snapshot.value["driver_phone"] != null) {
        setState(() {
          driverPhone = event.snapshot.value["driver_phone"].toString();
        });
      }
      if (event.snapshot.value["drivers_location"] != null) {
        setState(() {
          double driverLat = double.parse(
              event.snapshot.value["drivers_location"]["latitude"].toString());
          double driverLng = double.parse(
              event.snapshot.value["drivers_location"]["longitude"].toString());
          LatLng driverCurrentLocation = LatLng(driverLat, driverLng);
          if (statusRide == "accepted") {
            updateRideTimeToPickUpLoc(driverCurrentLocation);
          } else if (statusRide == "onride") {
            updateRideTimeToDropOffLoc(driverCurrentLocation);
          } else if (statusRide == "arrived") {
            setState(() {
              rideStatus = "Driver has Arrived";
            });
          }
        });
      }
      if (event.snapshot.value["status"] != null) {
        statusRide = event.snapshot.value["status"].toString();
      }
      if (statusRide == "accepted") {
        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGeofileMarkers();
      }
      if (statusRide == "ended") {
        if (event.snapshot.value["fares"] != null) {
          int fare = int.parse(event.snapshot.value["fares"].toString());
          var response = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  CollectFareDialog(paymentMethod: "cash", fareAmount: fare));

          String driverId = "";
          if (response == "close") {
            if (event.snapshot.value["driver_id"] != null) {
              driverId = event.snapshot.value["driver_id"].toString();
            }
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RatingScreen(driverId: driverId)));

            rideRequestRef.onDisconnect();
            // rideRequestRef = null;
            rideStreamSubscription.cancel();
            //rideStreamSubscription = null;
            resetApp();
          }
        }
      }
    });
  }

  void deleteGeofileMarkers() {
    setState(() {
      markerSet
          .removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }

  void updateRideTimeToPickUpLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;
      var positionUserLatLng =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      var details = await APIService().obtainPlaceDirectionDetails(
          driverCurrentLocation, positionUserLatLng);
      if (details == null) {
        return;
      }
      setState(() {
        rideStatus = "Driver is Coming -" + details.durationText;
      });

      isRequestingPositionDetails = false;
    }
  }

  void updateRideTimeToDropOffLoc(LatLng driverCurrentLocation) async {
    if (isRequestingPositionDetails == false) {
      isRequestingPositionDetails = true;
      var dropOff =
          Provider.of<AppData>(context, listen: false).dropoffLocation;
      var dropOffUserLatLng =
          LatLng(dropOff?.latitude ?? 0, dropOff?.longitude ?? 0);

      var details = await APIService().obtainPlaceDirectionDetails(
          driverCurrentLocation, dropOffUserLatLng);
      if (details == null) {
        return;
      }
      setState(() {
        rideStatus = "Going to Destination -" + details.durationText;
      });

      isRequestingPositionDetails = false;
    }
  }

  void cancelRideRequest() {
    rideRequestRef.remove();
    setState(() {
      state = "normal";
    });
  }

  void displayRequestRideContainer() {
    setState(() {
      requestRiderContainerHeight = 250;
      riderDetailsContainer = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  void displayDriverDetailsContainer() {
    setState(() {
      requestRiderContainerHeight = 0.0;
      riderDetailsContainer = 0.0;
      bottomPaddingOfMap = 290.0;
      driverDetailsContainerHeight = 320;
    });
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      riderDetailsContainer = 0;
      requestRiderContainerHeight = 0;
      bottomPaddingOfMap = 230;

      polylineSet.clear();
      markerSet.clear();
      circleSet.clear();
      pLineCoordinates.clear();

      statusRide = "";
      driverName = "";
      driverPhone = "";
      carDetailsDriver = "";
      rideStatus = "Driver is Coming";
      driverDetailsContainerHeight = 0.0;
    });

    locatePosition();
  }

  void displayRiderDetailsContainer() async {
    await getPlaceDirection();

    setState(() {
      searchContainerHeight = 0;
      riderDetailsContainer = 500.0;
      bottomPaddingOfMap = 360.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latlngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await APIService().searchCoordinateAddress(position, context);
    print("This is your address :: $address");
    initGeoFireListener();
    userName = userCurrentInfo?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    const colorizeColors = [
      Colors.green,
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 30.0,
      fontFamily: 'Horizon',
    );

    return Scaffold(
        key: scaffoldKey,
        drawer: Container(
          color: Colors.white,
          width: 255,
          child: Drawer(
            child: ListView(
              children: <Widget>[
                Container(
                  height: 165,
                  child: DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Row(
                      children: <Widget>[
                        Image.asset('assets/user1.png', height: 65, width: 65),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              userName,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 6),
                            Text('View Profile')
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const DividerWidget(),
                const SizedBox(height: 12),
                const ListTile(
                  leading: Icon(Icons.history),
                  title: Text(
                    'History',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                 ListTile(
                  onTap: () {
                    Get.to(ProfileScreen());
                  } ,
                  leading: Icon(Icons.person),
                  title: Text(
                    'Visit Profile',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                ListTile(
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Get.offAll(LoginScreen());
                  },
                  leading: const Icon(Icons.logout_outlined),
                  title: const Text(
                    'SignOut',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              initialCameraPosition: MainScreen._kGooglePlex,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: polylineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                //controller.bottomPaddingOfMap.value = 0;

                setState(() {
                  bottomPaddingOfMap = 300.0;
                });

                locatePosition();
              },
            ),

            //HamburgerButton for Drawer
            Positioned(
              top: 38,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  if (drawerOpen) {
                    scaffoldKey.currentState!.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 6,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      (drawerOpen) ? Icons.menu : Icons.close,
                      color: Colors.black,
                    ),
                    radius: 20,
                  ),
                ),
              ),
            ),

            //Search UI
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSize(
                  vsync: this,
                  curve: Curves.bounceIn,
                  duration: const Duration(microseconds: 160),
                  child: Container(
                    height: searchContainerHeight,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 5,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: Column(
                        children: <Widget>[
                          const Text(
                            'Where to?',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 3,
                                      spreadRadius: 0.5,
                                      offset: Offset(0.7, 0.7))
                                ]),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: <Widget>[
                                  // Icon(Icons.search,
                                  //   color: Colors.black,size: 25,),
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      Provider.of<AppData>(context)
                                                  .pickUpLocation !=
                                              null
                                          ? Provider.of<AppData>(context)
                                              .pickUpLocation!
                                              .placeName
                                          : 'Add Home',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  //Text('Search Drop Off', style: TextStyle(fontSize: 18),)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              var response = await Get.to(SearchScreen());
                              if (response == "obtainDirection") {
                                displayRiderDetailsContainer();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 3,
                                        spreadRadius: 0.5,
                                        offset: Offset(0.7, 0.7))
                                  ]),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: <Widget>[
                                    // Icon(Icons.search,
                                    //     color: Colors.black,size: 25,),
                                    Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Search Drop Off',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // const SizedBox(height: 24),
                          // Row(
                          //   children: <Widget>[
                          //     const Icon(Icons.home, color: Colors.grey),
                          //     const SizedBox(width: 12),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: <Widget>[
                          //         //Text('Add Home'),
                          //         Text(Provider.of<AppData>(context)
                          //                     .pickUpLocation !=
                          //                 null
                          //             ? Provider.of<AppData>(context)
                          //                 .pickUpLocation!
                          //                 .placeName
                          //             : 'Add Home',maxLines:2,overflow: TextOverflow.ellipsis,),
                          //         const SizedBox(height: 4),
                          //         const Text(
                          //           'Your living home address',
                          //           style: TextStyle(
                          //               color: Colors.black54, fontSize: 12),
                          //         )
                          //       ],
                          //     )
                          //   ],
                          // ),
                          // const SizedBox(height: 10),
                          // const DividerWidget(),
                          // const SizedBox(height: 16),
                          // Row(
                          //   children: <Widget>[
                          //     const Icon(Icons.work, color: Colors.grey),
                          //     const SizedBox(width: 12),
                          //     Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: const <Widget>[
                          //         Text('Add Work'),
                          //         SizedBox(height: 4),
                          //         Text(
                          //           'Your office address',
                          //           style: TextStyle(
                          //             color: Colors.black54,
                          //             fontSize: 12,
                          //           ),
                          //         )
                          //       ],
                          //     )
                          //   ],
                          // )
                        ],
                      ),
                    ),
                  ),
                )),

            //Ride Details UI
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedSize(
                  vsync: this,
                  curve: Curves.bounceIn,
                  duration: const Duration(milliseconds: 160),
                  child: Container(
                    height: riderDetailsContainer,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              blurRadius: 16,
                              spreadRadius: 0.7,
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "Choose your trip type",
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                          //Hatchback Ride
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg: "Searching Hatchback Car",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1);
                              setState(() {
                                state = "requesting";
                                carRideType = "Hatchback";
                              });
                              displayRequestRideContainer();
                              availableDrivers =
                                  GeoFireAssistant.nearByAvailableDriversList;
                              searchNearestDriver();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/hatchback.png',
                                      height: 70,
                                      width: 80,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('Car - Hatchback',
                                            style: TextStyle(fontSize: 18)),
                                        Text(
                                            ((tripDirectionDetails != null)
                                                ? tripDirectionDetails!
                                                    .distanceText
                                                : ''),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text((tripDirectionDetails != null)
                                        ? '\$${APIService().calculateFares(tripDirectionDetails!)}'
                                        : '')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 2, thickness: 2),
                          const SizedBox(height: 10),
                          //Sedan Ride
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg: "Searching Sedan Car",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1);
                              setState(() {
                                state = "requesting";
                                carRideType = "Sedan";
                              });
                              displayRequestRideContainer();
                              availableDrivers =
                                  GeoFireAssistant.nearByAvailableDriversList;
                              searchNearestDriver();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/sedan.png',
                                      height: 70,
                                      width: 80,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('Car - Sedan',
                                            style: TextStyle(fontSize: 18)),
                                        Text(
                                            ((tripDirectionDetails != null)
                                                ? tripDirectionDetails!
                                                    .distanceText
                                                : ''),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text((tripDirectionDetails != null)
                                        ? '\$${(APIService().calculateFares(tripDirectionDetails!)) * 1.5}'
                                        : '')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 2, thickness: 2),
                          const SizedBox(height: 10),
                          //XUV Ride
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg: "Searching XUV Car",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1);
                              setState(() {
                                state = "requesting";
                                carRideType = "XUV";
                              });
                              displayRequestRideContainer();
                              availableDrivers =
                                  GeoFireAssistant.nearByAvailableDriversList;
                              searchNearestDriver();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/XUV.png',
                                      height: 70,
                                      width: 80,
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        const Text('Car - XUV',
                                            style: TextStyle(fontSize: 18)),
                                        Text(
                                            ((tripDirectionDetails != null)
                                                ? tripDirectionDetails!
                                                    .distanceText
                                                : ''),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    Expanded(child: Container()),
                                    Text((tripDirectionDetails != null)
                                        ? '\$${(APIService().calculateFares(tripDirectionDetails!)) * 2}'
                                        : '')
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(height: 2, thickness: 2),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                // Icon(FontAwesomeIcons.moneyCheckAlt,
                                //     size: 18, color: Colors.black),
                                Text(
                                  "Payment Method",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: 16),
                                Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.grey)),
                                  child: DropdownButton<String>(
                                   // isExpanded: true,
                                    underline: SizedBox(),
                                    items: <String>['Cash', 'Online Payment']
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        this.value = value!;
                                      });
                                    },
                                  ),
                                )
                                // Text('Cash'),
                                // SizedBox(width: 6),
                                // Icon(Icons.keyboard_arrow_down,
                                //     color: Colors.black54, size: 16),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: 250,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.black),
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(fontSize: 20),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                )),

            //Cancel UI
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: requestRiderContainerHeight,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 0.5,
                          blurRadius: 5,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                              'Requesting a Ride...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,

                            ),
                            ColorizeAnimatedText(
                              'Please wait...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                            ColorizeAnimatedText(
                              'Finding a Driver...',
                              textStyle: colorizeTextStyle,
                              colors: colorizeColors,
                            ),
                          ],

                          isRepeatingAnimation: true,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () {
                          cancelRideRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                  width: 52, color: Colors.grey.shade300)),
                          child: const Icon(
                            Icons.close,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        child: const Text(
                          'Cancel Ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            //Display Assigned Driver Info
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: driverDetailsContainerHeight,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          spreadRadius: 0.5,
                          blurRadius: 16,
                          //color: Colors.black54,
                          offset: Offset(0.7, 0.7))
                    ]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(rideStatus, style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      SizedBox(height: 22),
                      Divider(height: 2),
                      Text(carDetailsDriver,
                          style: TextStyle(color: Colors.grey)),
                      Text(driverName, style: TextStyle(fontSize: 20)),
                      SizedBox(height: 22),
                      Divider(height: 2),
                      SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                launch(('tel://${driverPhone}'));
                              },
                              child: Padding(
                                padding: EdgeInsets.all(17),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text("Call Driver",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white)),
                                    Icon(
                                      Icons.call,
                                      color: Colors.white,
                                      size: 26,
                                    )
                                  ],
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
            )
          ],
        ));
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropoffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos!.latitude, finalPos.longitude);

    Get.defaultDialog(
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(width: 15),
          Text('Please wait')
        ],
      ),
      contentPadding: const EdgeInsets.all(10),
      title: '',
    );

    var details = await APIService()
        .obtainPlaceDirectionDetails(pickUpLatLng, dropOffLatLng);
    setState(() {
      tripDirectionDetails = details!;
    });

    Get.back();

    print("This is Encoded Points::");
    print(details!.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodePolylinePointResult.isNotEmpty) {
      decodePolylinePointResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: const PolylineId("PolylineID,"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;
    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "My Location"),
      position: pickUpLatLng,
      markerId: const MarkerId("pickUpId"),
    );

    Marker dropoffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "Dropoff Location"),
      position: dropOffLatLng,
      markerId: const MarkerId("dropoffId"),
    );

    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropoffLocMarker);
    });

    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: const CircleId("pickUpId"));

    Circle dropoffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
        circleId: const CircleId("dropOffId"));

    setState(() {
      circleSet.add(pickUpLocCircle);
      circleSet.add(dropoffLocCircle);
    });
  }

  void initGeoFireListener() {
    Geofire.initialize("availableDrivers");
    Geofire.queryAtLocation(
            currentPosition.latitude, currentPosition.longitude, 15)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(key: '', latitude: 0, longitude: 0);
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.nearByAvailableDriversList
                .add(nearbyAvailableDrivers);
            if (nearbyAvailableDriverKeysLoaded == true) {
              updateAvailableDriversOnMap();
            }

            break;

          case Geofire.onKeyExited:
            GeoFireAssistant.removeDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location
            NearbyAvailableDrivers nearbyAvailableDrivers =
                NearbyAvailableDrivers(key: '', latitude: 0, longitude: 0);
            nearbyAvailableDrivers.key = map['key'];
            nearbyAvailableDrivers.latitude = map['latitude'];
            nearbyAvailableDrivers.longitude = map['longitude'];
            GeoFireAssistant.updateDriverNearbyLocation(nearbyAvailableDrivers);
            updateAvailableDriversOnMap();

            break;

          case Geofire.onGeoQueryReady:
            // All Intial Data is loaded
            updateAvailableDriversOnMap();

            break;
        }
      }

      setState(() {});
    });
  }

  void updateAvailableDriversOnMap() {
    setState(() {
      markerSet.clear();
    });
    Set<Marker> tMarker = Set<Marker>();
    for (NearbyAvailableDrivers driver
        in GeoFireAssistant.nearByAvailableDriversList) {
      LatLng driverAvailablePosition =
          LatLng(driver.latitude, driver.longitude);

      Marker marker = Marker(
        markerId: MarkerId('driver${driver.key}'),
        position: driverAvailablePosition,
        icon: nearByIcon!,
        rotation: APIService.createRandomNumber(360),
      );

      tMarker.add(marker);
    }

    setState(() {
      markerSet = tMarker;
    });
  }

  Future<BitmapDescriptor> createIconMarker() async {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size(2, 2));
      var resultImage = await BitmapDescriptor.fromAssetImage(
          imageConfiguration, 'assets/car.png');
      nearByIcon = resultImage;
    }
    return nearByIcon!;
  }

  void noDriverFound() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const NoDriverAvailabilityDialog());
  }

  void searchNearestDriver() {
    if (availableDrivers.length == 0) {
      cancelRideRequest();
      resetApp();
      noDriverFound();
      return;
    }

    var driver = availableDrivers[0];

    driverRef
        .child(driver.key)
        .child("car_details")
        .child("type")
        .once()
        .then((DataSnapshot snapshot) async {
      if (await snapshot.value != null) {
        String carType = snapshot.value.toString();
        if (carType == carRideType) {
          notifyDriver(driver);
          availableDrivers.removeAt(0);
        } else {
          Fluttertoast.showToast(
              msg: "${carRideType} drivers not available. Try again",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1);
        }
      } else {
        Fluttertoast.showToast(
            msg: "No car found. Try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1);
      }
    });
  }

  void notifyDriver(NearbyAvailableDrivers driver) {
    driverRef.child(driver.key).child("newRide").set(rideRequestRef.key);
    driverRef
        .child(driver.key)
        .child("token")
        .once()
        .then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String token = snapshot.value.toString();
        APIService()
            .sendNotificationToDriver(token, context, rideRequestRef.key);
      } else {
        return;
      }

      const oneSecondPassed = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecondPassed, (timer) {
        if (state != "requesting") {
          driverRef.child(driver.key).child("newRide").set("cancelled");
          driverRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();
        }

        driverRequestTimeOut = driverRequestTimeOut - 1;

        driverRef.child(driver.key).child("newRide").onValue.listen((event) {
          if (event.snapshot.value.toString() == "accepted") {
            driverRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 40;
            timer.cancel();
          }
        });

        if (driverRequestTimeOut == 0) {
          driverRef.child(driver.key).child("newRide").set("timeout");
          driverRef.child(driver.key).child("newRide").onDisconnect();
          driverRequestTimeOut = 40;
          timer.cancel();

          searchNearestDriver();
        }
      });
    });
  }
}
