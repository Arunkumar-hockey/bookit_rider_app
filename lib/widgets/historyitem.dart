import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/model/history.dart';
import 'package:bookit_rider_app/service/apiservice.dart';

class HistoryItem extends StatelessWidget {
  final History history;
  const HistoryItem({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Image.asset('assets/location.png', height: 16, width: 16),
                    SizedBox(width: 18),
                    Expanded(
                        child: Container(
                      child: Text(
                        history.pickUp ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18),
                      ),
                    )),
                    SizedBox(width: 5),
                    Text('\$${history.fares ?? ''}', style: TextStyle(fontSize: 16, color: Colors.black87),)
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Image.asset('assets/location_pin.png', height: 16, width: 16),
                  SizedBox(width: 18),
                  Text(history.dropOff ?? '', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 15),
                  Text(APIService.formatTripDate(history.createdAt ?? ''), style: TextStyle(color: Colors.grey),)
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
