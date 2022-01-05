import 'package:bookit_rider_app/view/homepage.dart';
import 'package:bookit_rider_app/view/loginscreen.dart';
import 'package:bookit_rider_app/main.dart';

import '../allpackages.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  void createUser(
      String name, String email, String phoneNo, String password) async {
    Get.defaultDialog(
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(width: 15),
          Text('Registering, Please wait')
        ],
      ),
      contentPadding: const EdgeInsets.all(10),
      title: '',
    );
    var credentials = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    if (credentials.user != null) {
      Map userDataMap = {
        "Name":  name.trim(),
        "Email": email.trim(),
        "Phone": phoneNo.trim(),
        "Password": password.trim()
      };
      
      userRef.child(credentials.user!.uid).set(userDataMap);

      Get.to(LoginScreen());
      Fluttertoast.showToast(
          msg: "Account Created",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1);
      print('created successfully.......');
    } else {
      print('Failed........');
    }
  }

  void login(String email, String password) async{
    Get.defaultDialog(
      content: Row(
        children: const <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          SizedBox(width: 15),
          Text('Authenticating, Please wait')
        ],
      ),
      contentPadding: const EdgeInsets.all(10),
      title: '',
    );
   var credentials =await _auth.signInWithEmailAndPassword(email: email, password: password).catchError((errMsg) {
     Get.back();
     Fluttertoast.showToast(
         msg: "Error:" + errMsg.toString(),
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.CENTER,
         timeInSecForIosWeb: 1);
   });
   if(credentials.user != null) {
     print('Login Success....');
     Get.to(MainScreen(email: credentials.user!.email!));
     // userRef.child(credentials.user!.uid).once().then((value) => (DataSnapshot snap) {
     //   if(snap.value != null) {
     //     print('snapshot......');
     //     Get.to(MainScreen());
     //     Fluttertoast.showToast(
     //         msg: "You are logged-in now",
     //         toastLength: Toast.LENGTH_SHORT,
     //         gravity: ToastGravity.BOTTOM,
     //         timeInSecForIosWeb: 1);
     //   } else{
     //     _auth.signOut();
     //     Fluttertoast.showToast(
     //         msg: "No records exists for this user. Please create account now",
     //         toastLength: Toast.LENGTH_SHORT,
     //         gravity: ToastGravity.CENTER,
     //         timeInSecForIosWeb: 1);
     //   }
     // });


   } else {
     Fluttertoast.showToast(
         msg: "Error Occured",
         toastLength: Toast.LENGTH_SHORT,
         gravity: ToastGravity.CENTER,
         timeInSecForIosWeb: 1);
     print('Login Failed');
   }
  }

  void signOut() async{
    await _auth.signOut();
    Get.offAll(LoginScreen());
  }

  RxDouble bottomPaddingOfMap = 0.0.obs;

}
