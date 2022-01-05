import 'package:bookit_rider_app/controller/authcontroller.dart';
import 'package:bookit_rider_app/constants/colorconstants.dart';
import 'package:bookit_rider_app/view/createaccount.dart';

import '../allpackages.dart';

class LoginScreen extends GetView<AuthController> {
  LoginScreen({Key? key}) : super(key: key);

  static const String idScreen = "Login";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(PRIMARY_COLOUR),
          title: Image.asset('assets/appbarlogo.png',fit: BoxFit.contain,width: 200,),
          automaticallyImplyLeading: false,
        ),
        resizeToAvoidBottomInset: true,
        body: ListView(
          children: [
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Color(PRIMARY_COLOUR),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  )),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 25),
                  Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 2, color: Colors.white)),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage('assets/welcome.png'),
                                fit: BoxFit.cover
                            )
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Login to continue',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lato'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.grey,size: 25),
                      border: OutlineInputBorder(),
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                      hintText: "Type your email here..",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      emailController.text = value!;
                      print(value);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.grey),
                      border: OutlineInputBorder(),
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                      hintText: "Type your password here..",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      passwordController.text = value!;
                      print(value);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(height: 30),
                  InkWell(
                    splashColor: Colors.grey,
                    onTap: () {
                      controller.login(emailController.text, passwordController.text);
                      //Get.to(OTPVerifyScreen());
                      //controller.getUserSignIn();
                    },
                    child: Container(
                      //margin: EdgeInsets.only(left: 20,right: 20),
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: const Color(SECONDARY_COLOUR)),
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Don't have an account",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextButton(
                          onPressed: () {
                            Get.to(CreateAccount());
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                                color: Color(SECONDARY_COLOUR),
                                fontFamily: 'Lato',
                                fontSize: 20),
                          ))
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }
}