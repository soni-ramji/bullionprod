import 'package:bullionprod/main.dart';
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
  bool showLoginFailed = false;
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  int custId = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    custId = prefs.getInt('customerId') ?? -1;
    // if(custId != -1) {
    //   logger.d('Customer ID is $custId');
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (_) => const HomeScreen()),
    //   );
    //
    // }
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
          showLoginFailed = false;
        });
        logger.d('Customer ID is $customerId');

        await prefs.setInt('customerId', customerId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          showLoginFailed = true;
        });
        logger.d('showLoginFailed is $showLoginFailed');
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
          if (showLoginFailed)
            const Align(
              alignment: Alignment.centerLeft, // Aligns the text to the left
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 5.0,
                ), // Optional padding
                child: Text(
                  'You are not a customer of TD Jewellery.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.left, // Ensures left alignment
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process the login
                      logger.d('Login button pressed');
                      validateUser();
                    }
                  },
                  child: const Text('Login'),
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
