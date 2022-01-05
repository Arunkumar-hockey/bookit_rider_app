import 'package:bookit_rider_app/controller/authcontroller.dart';
import 'package:bookit_rider_app/constants/colorconstants.dart';

import '../allpackages.dart';
import 'loginscreen.dart';

class CreateAccount extends GetView<AuthController> {
  CreateAccount({Key? key}) : super(key: key);
  final controller = Get.put(AuthController());
  static const String idScreen = "Register";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNoController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(PRIMARY_COLOUR),
        title:
        Image.asset('assets/appbarlogo.png', fit: BoxFit.contain,width: 200),
        automaticallyImplyLeading: false,
      ),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.hardEdge,
              fit: StackFit.loose,
              overflow: Overflow.visible,
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Container(
                    height: 220,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/topbackground.png'),
                            fit: BoxFit.fitHeight
                        )),
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 40),
                        Row(
                          children: const <Widget>[],
                        ),
                        const SizedBox(height: 60),
                        const Text(
                          'Please complete your profile to \n connect to your neighbourhood',
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(width: 2, color: const Color(PRIMARY_COLOUR))),
                      child: Container(
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/nearlelauncherround.png'),
                                fit: BoxFit.contain)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Profile',
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person, color: Colors.grey,size: 25),
                      border: OutlineInputBorder(),
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                      hintText: "Type your name here..",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      nameController.text = value!;
                      print(value);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail, color: Colors.grey),
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
                        return 'Enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: phoneNoController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                      border: OutlineInputBorder(),
                      labelText: "Phone No",
                      labelStyle: TextStyle(color: Colors.grey,fontSize: 18),
                      hintText: "Type your phone numner here..",
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      phoneNoController.text = value!;
                      print(value);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      prefixIcon:
                      Icon(Icons.lock, color: Colors.grey),
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
                        return 'Enter your password';
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
                      controller.createUser(
                          nameController.text,
                          emailController.text,
                          phoneNoController.text,
                          passwordController.text);
                      // if (formKey.currentState!.validate()) {
                      //   controller.firstname =
                      //       controller.firstnameController.text;
                      //   controller.lastname =
                      //       controller.lastnameController.text;
                      //   controller.email = controller.emailController.text;
                      //   controller.mobilenumber =
                      //       controller.mobilnumberController.text;
                      //   controller.getUserSignup();
                      //   Fluttertoast.showToast(
                      //       msg: "Account Created",
                      //       toastLength: Toast.LENGTH_SHORT,
                      //       gravity: ToastGravity.CENTER,
                      //       timeInSecForIosWeb: 1);
                      //   Get.to(NavigationBar());
                      // } else {
                      //   //throw RxStatus.error();
                      //   Fluttertoast.showToast(
                      //       msg: "Fill form to continue",
                      //       toastLength: Toast.LENGTH_SHORT,
                      //       gravity: ToastGravity.BOTTOM,
                      //       timeInSecForIosWeb: 1);
                      // }
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color(SECONDARY_COLOUR)),
                      child: const Center(
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Lato'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Already have an account",
                        style: TextStyle(fontSize: 20),
                      ),
                      TextButton(
                          onPressed: () {
                            Get.to(LoginScreen());
                          },
                          child: const Text(
                            'Login',
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
        ),
      ),
    );
  }
}