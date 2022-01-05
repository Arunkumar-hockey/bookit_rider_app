import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/helper/appdata.dart';
import 'package:bookit_rider_app/widgets/historyitem.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trip History"),
        centerTitle: true,
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        itemCount: Provider.of<AppData>(context, listen: false).tripHistoryDataList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2.0, height: 3.0,),
        itemBuilder: (BuildContext context, int index) {
          return HistoryItem(
              history: Provider.of<AppData>(context, listen:  false).tripHistoryDataList[index].
          );
        },
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }
}
