import 'package:bullionprod/environment.dart';
import 'package:bullionprod/main.dart';
import 'package:bullionprod/model/CusomerSignupModel.dart';
import 'package:bullionprod/model/CustomerLoginModel.dart';
import 'package:bullionprod/screen/ChngePasswd.dart';
import 'package:bullionprod/screen/bottombar.dart';

import 'package:bullionprod/screen/home1.dart';
import 'package:bullionprod/screen/selectedproduct.dart';
import 'package:bullionprod/service/APIServices.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscured = true;
  bool hasError = false;
  bool isSignup = false;
  bool _isLoggingIn = false;
  var logger = Logger();
  final _formKey = GlobalKey<FormState>();
  int custId = -1;
  String errorText = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    custId = prefs.getInt('customerId') ?? -1;
  }

  int getSelectedCustomerId() {
    return custId;
  }

  Future<void> _showChangePasswordDialog() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Chngepasswd()),
    );
  }

  @override
  //#007bff
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (custId != -1) {
        logger.d('Customer ID is $custId');
        
        logger.d("Customer Logged in");

      }
      // Or open a dialog / snackbar
    });

    String mobileNumber = '';
    String mobilepassword = '';
    String username = '';
    String tradename = '';

    Future<void> validateUser() async {
       // get mobile number
       logger.d('Mobile number is $mobileNumber');
       // validate mobile number
       if (mobileNumber.isEmpty) {
         logger.d('Mobile number is empty');
         return;
       }

       setState(() {
         _isLoggingIn = true;
         hasError = false;
         errorText = '';
       });


       Customerloginmodel loginModel = Customerloginmodel(username: mobileNumber, password: mobilepassword);

       int? customerId;
       const int maxAttempts = 2;

       for (int attempt = 1; attempt <= maxAttempts; attempt++) {
         logger.d('Login attempt $attempt');

         ApiService _apiService = ApiService();
         customerId = await _apiService.getCustomerId(loginModel);
         if (customerId != null && customerId != -1) break;
         // brief delay before retry
         if (attempt < maxAttempts) await Future.delayed(const Duration(seconds: 1));
       }

       if (!context.mounted) return;

       setState(() {
         _isLoggingIn = false;
       });

       if (customerId != null && customerId != -1) {
         final validCustomerId = customerId;
         setState(() {
           hasError = false;
           custId = validCustomerId;
         });
         logger.d('Customer ID is $customerId');

         await prefs.setInt('customerId', customerId);

         Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => const HomeScreen1()),
         );
       } else {
         setState(() {
           hasError = true;
           errorText = 'Unable to login. Please check credentials or try again.';
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


      CustomerSignup customersignup = CustomerSignup(
        id: -1,
        name: username,
        tradename: tradename,
        type: '1',
        mobileno: mobileNumber,
        typename: 'Customer',
        address: [],
        identitytype: '',
        identityvalue: '',
        passwd: mobilepassword,
      );

      final customerId = await _apiService.customerSignUp(customersignup);

      if (!context.mounted) return;

      if (customerId != null && customerId != -1) {
        final validCustomerId = customerId;
        setState(() {
          hasError = false;
          custId = validCustomerId;
        });
        logger.d('Customer ID is $customerId');

        await prefs.setInt('customerId', customerId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen1()),
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
      bottomNavigationBar: custId != -1 ? const Bottombar(selectedIndex: 0) : null,
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
          if (custId != -1)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SelectedProduct()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F6FEB),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(170, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      elevation: 4,
                      shadowColor: Colors.blue.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Selected Items'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showChangePasswordDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C4300),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(190, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      elevation: 4,
                      shadowColor: const Color(0xFF5C4300).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Change Password'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await prefs.remove(AppConfig.CUSTOMERID);
                      setState(() {
                        prefs.setInt(AppConfig.CUSTOMERID, -1);
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen1()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD64545),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(155, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      elevation: 4,
                      shadowColor: Colors.red.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SelectedProduct()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA000),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      elevation: 4,
                      shadowColor: Colors.orange.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ],
              ),
            )
          else
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  if (isSignup)
                    Center(
                      child: SizedBox(
                        width: 300,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Color(0xFFD9C7A3), width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Color(0xFF5C4300), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
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
                  if (isSignup) const SizedBox(height: 20),
                  if (isSignup)
                    Center(
                      child: SizedBox(
                        width: 300,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Shop Name',
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Color(0xFFD9C7A3), width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Color(0xFF5C4300), width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your shop name';
                            } else {
                              tradename = value;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  if (isSignup) const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: 'Enter your mobile number',
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Color(0xFFD9C7A3), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Color(0xFF5C4300), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.red, width: 1.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
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

                      // child: TextFormField(
                      //   decoration: InputDecoration(
                      //     labelText: 'Enter your text',
                      //     hintText: 'Type something...',
                      //     // The base border design
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //     ),
                      //     // Border design when the field is active but not focused
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //       borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                      //     ),
                      //     // Border design when the user clicks/taps into the field
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //       borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                      //     ),
                      //     // Border design when validation fails
                      //     errorBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //       borderSide: const BorderSide(color: Colors.red, width: 1.0),
                      //     ),
                      //     focusedErrorBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(20.0),
                      //       borderSide: const BorderSide(color: Colors.red, width: 2.0),
                      //     ),
                      //   ),
                      // )
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Color(0xFFD9C7A3), width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Color(0xFF5C4300), width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.red, width: 1.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscured ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                          ),
                        ),
                        obscureText: _isObscured,
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
                      if (!isSignup)
                        _isLoggingIn
                            ? const SizedBox(
                                width: 120,
                                height: 40,
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1F6FEB),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(140, 48),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  elevation: 4,
                                  shadowColor: Colors.blue.withValues(alpha: 0.35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    logger.d('Login button pressed');
                                    validateUser();
                                  }
                                },
                                child: const Text('Login'),
                              ),
                      const SizedBox(width: 20),
                      if (!isSignup)
                        Center(
                          child: InkWell(
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              setState(() {
                                isSignup = true;
                              });
                            },
                          ),
                        ),
                      if (isSignup)
                        Center(
                          child: InkWell(
                            child: const Text('Login'),
                            onTap: () {
                              setState(() {
                                isSignup = false;
                              });
                            },
                          ),
                        ),
                      const SizedBox(width: 10),
                      if (isSignup)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F6FEB),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(140, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            elevation: 4,
                            shadowColor: Colors.blue.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              logger.d('Login button pressed');
                              signup();
                            }
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    
    );
  }
}
