import 'package:bookit_rider_app/allpackages.dart';

class Users {
  late String id;
  late String email;
  late String name;
  late String phone;

  Users({required this.id, required this.email, required this.name, required this.phone});

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key!;
    email = dataSnapshot.value['drivers']["email"];
    name = dataSnapshot.value['drivers']["name"];
    phone = dataSnapshot.value['drivers']["phone"];
  }

}