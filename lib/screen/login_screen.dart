import 'package:bullionprod/main.dart';
import 'package:bullionprod/model/CusomerSignupModel.dart';
import 'package:bullionprod/model/CustomerLoginModel.dart';
import 'package:bullionprod/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import 'package:bullionprod/screen/purchase_item_screen.dart';
import 'package:bullionprod/service/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool hasError = false;
  bool isSignup = false;
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  int custId = -1;
  String errorText = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custId = prefs.getInt('customerId') ?? -1;

  }

  int getSelectedCustomerId() {
    return custId;
  }

  @override
  //#007bff
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (custId != -1) {
        logger.d('Customer ID is $custId');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      // Or open a dialog / snackbar
    });

    String mobileNumber = '';
    String mobilepassword = '';
    String username = '';
    String tradename = '';
    String userpassword = '';

    Future<void> validateUser() async {
      // get mobile number
      logger.d('Mobile number is $mobileNumber');
      // validate mobile number
      if (mobileNumber.isEmpty) {
        logger.d('Mobile number is empty');
        return;
      }

      final loginService = LoginService();
      Customerloginmodel loginModel = Customerloginmodel(username: mobileNumber, password: mobilepassword);
      final customerId = await loginService.getCustomerId(loginModel);

      if (!context.mounted) return;

      if (customerId != null && customerId != -1) {
        setState(() {
          hasError = false;
        });
        logger.d('Customer ID is $customerId');

        await prefs.setInt('customerId', customerId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          hasError = true;
          errorText= 'You are not a customer of TD Jewellery.';
        });
        logger.d('hasError is $hasError');
      }
    }

    Future<void> signup() async {
      // get mobile number
      logger.d('Name is $username');
      // validate mobile number
      if (username.isEmpty) {
        logger.d('Name is empty');
        return;
      }

      if (tradename.isEmpty) {
        logger.d('Trade name is empty');
        return;
      }

      if (mobileNumber.isEmpty) {
        logger.d('Mobile number is empty');
        return;
      }

      if (mobilepassword.isEmpty) {
        logger.d('Mobile password is empty');
        return;
      }

      final loginService = LoginService();
      CustomerSignup customersignup = CustomerSignup(
        id: -1,
        name: username,
        tradename: tradename,
        type: '1',
        mobileno: mobileNumber,
        typename: 'Customer',
        address: '',
        identitytype: '',
        identityvalue: '',
        passwd: mobilepassword,
      );
      final customerId = await loginService.signup(customersignup);

      if (!context.mounted) return;

      if (customerId != null && customerId != -1) {
        setState(() {
          hasError = false;
        });
        logger.d('Customer ID is $customerId');

        await prefs.setInt('customerId', customerId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          hasError = true;
        });
        logger.d('hasError is $hasError');
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4300),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'THE TD',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'JEWELS',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,

      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Welcome to TD Jewellery',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          if (hasError)
            Center(

              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child:  Text(
                  '$errorText',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
          const SizedBox(height: 5),
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Text(
                //   'Login',
                //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                // ),
                const SizedBox(height: 20),
                if(isSignup)
                Center(
                  child: SizedBox(
                    width: 300, // Set the desired width
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        errorStyle: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        } else {
                          username = value;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if(isSignup)
                const SizedBox(height: 20),
                if(isSignup)
                Center(
                  child: SizedBox(
                    width: 300, // Set the desired width
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Trade Name',
                        errorStyle: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your trade name';
                        } else {
                          tradename = value;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                if(isSignup)
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 300, // Set the desired width
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        errorStyle: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your mobile number';
                        } else {
                          mobileNumber = value;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 300, // Set the desired width
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        errorStyle: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else {
                          mobilepassword = value;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(!isSignup)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Sets background to blue
                        foregroundColor: Colors.white, // Sets text and icon color to white
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process the login
                          logger.d('Login button pressed');
                          validateUser();
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(width: 20),
                    if(!isSignup)
                    Center(
                      child: new InkWell(
                          child: new Text('Sign Up',
                          style: TextStyle(color: Colors.red),
                          ),
                          onTap: () => {
                              setState(() {
                                isSignup = true;
                              })
      }


                      ),

                    ),
                    if(isSignup)
                    Center(
                      child: new InkWell(
                          child: new Text('Login'),
                          onTap: () => {
                            setState(() {
                              isSignup = false;
                            })
                          }


                      ),

                    ),
                    const SizedBox(width: 10),
                    if(isSignup)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Sets background to blue
                        foregroundColor: Colors.white, // Sets text and icon color to white
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Process the login
                          logger.d('Login button pressed');
                          signup();
                        }
                      },
                      child: const Text('Sign Up'
                      , style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),



              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Handle the action for the floating action button
      //     logger.d('Floating action button pressed');
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
