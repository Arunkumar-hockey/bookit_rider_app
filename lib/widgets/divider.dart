import 'package:bookit_rider_app/allpackages.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1.0,
      color: Colors.black,
      thickness: 1.0,
    );
  }
}
