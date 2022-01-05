import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/constants/baseconstants.dart';

class RatingScreen extends StatefulWidget {
  final String driverId;
  const RatingScreen({Key? key, required this.driverId}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(5),
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:  <Widget>[
              const SizedBox(height: 22),

              const Text("Rate this Driver", style: TextStyle(fontSize: 20, color: Colors.black54),),

              const SizedBox(height: 22),

              const Divider(height: 2, thickness: 2),

              const SizedBox(height: 16),

              // SmoothStarRating(
              //   rating: starCounter,
              //   color: Colors.amber,
              //   allowHalfRating: false,
              //   starCount: 5,
              //   size: 45,
              //   onRated: (value) {
              //     starCounter = value;
              //     if(starCounter == 1) {
              //       setState(() {
              //         title = "Very Bad";
              //       });
              //     }
              //     else if(starCounter == 2) {
              //       setState(() {
              //         title = "Bad";
              //       });
              //     }
              //    else if(starCounter == 3) {
              //       setState(() {
              //         title = "Good";
              //       });
              //     }
              //     else if(starCounter == 4) {
              //       setState(() {
              //         title = "Very Good";
              //       });
              //     }
              //    else if(starCounter == 5) {
              //       setState(() {
              //         title = "Excellent";
              //       });
              //     } else {
              //      return null;
              //     }
              //   },
              // ),

            RatingBar.builder(
              initialRating: starCounter,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (value) {
                starCounter = value;
                if(starCounter == 1) {
                  setState(() {
                    title = "Very Bad";
                  });
                }
                else if(starCounter == 2) {
                  setState(() {
                    title = "Bad";
                  });
                }
                else if(starCounter == 3) {
                  setState(() {
                    title = "Good";
                  });
                }
                else if(starCounter == 4) {
                  setState(() {
                    title = "Very Good";
                  });
                }
                else if(starCounter == 5) {
                  setState(() {
                    title = "Excellent";
                  });
                } else {
                  return null;
                }
              },
            ),

              const SizedBox(height: 14),

              Text(title, style: TextStyle(fontSize: 55, color: Colors.amber),),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    DatabaseReference driverRatingRef = FirebaseDatabase.instance.reference().child("drivers").child(widget.driverId).child("ratings");
                    driverRatingRef.once().then((DataSnapshot snapshot) {
                      if(snapshot.value != null) {
                        double oldRatings = double.parse(snapshot.value.toString());
                        double addRatings = oldRatings + starCounter;
                        double averageRatings = addRatings/2;
                        driverRatingRef.set(averageRatings.toString());
                      }  else {
                        driverRatingRef.set(starCounter.toString());
                      }
                    });

                    Get.back();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:  const <Widget>[
                      Text(
                        "Submit",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 26,
                      )
                    ],
                  ),
                  style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
