import 'package:bookit_rider_app/allpackages.dart';
import 'package:bookit_rider_app/constants/baseconstants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Text(
                "Profile Info",
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.blueGrey[200],
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              InfoCard(
                  text: userCurrentInfo?.name ?? '',
                  icon: Icons.person,
                  onPressed: () async {
                    print('This is Phone');
                  }),
              InfoCard(
                  text: userCurrentInfo?.phone ?? '',
                  icon: Icons.phone,
                  onPressed: () async {
                    print('This is Phone');
                  }),
              InfoCard(
                  text: userCurrentInfo?.email ?? '',
                  icon: Icons.email,
                  onPressed: () async {
                    print('This is Email');
                  }),
              TextButton(
                  onPressed: () {},
                  child: Text("Go Back"),
              )
            ],
          ),
        ));
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  InfoCard(
      {Key? key,
      required this.text,
      required this.icon,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.black87,
          ),
          title:
              Text(text, style: TextStyle(color: Colors.black87, fontSize: 16)),
        ),
      ),
    );
  }
}
