import 'package:bullionprod/main.dart';
import 'package:bullionprod/model/CustChngePasswdMdl.dart';
import 'package:bullionprod/screen/bottombar.dart';
import 'package:bullionprod/screen/home1.dart';
import 'package:bullionprod/service/APIServices.dart';
import 'package:bullionprod/widget/breadcrumb.dart';
import 'package:flutter/material.dart';


class Chngepasswd extends StatefulWidget {
  const Chngepasswd({super.key});

  @override
  State<Chngepasswd> createState() => _ChngepasswdState();
}

class _ChngepasswdState extends State<Chngepasswd> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _isObscuredPassword = true;
  bool _isObscuredNewPassword = true;

  String get _customerName => prefs.getString('customerName') ?? 'Customer';

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = _passwordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both password fields.')),
      );
      return;
    }

    if (currentPassword == newPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be different from the current password.')),
      );
      return;
    }

    CustomerChangePasswordModel changePasswordModel = CustomerChangePasswordModel(
      custId: prefs.getInt('customerId'),
      oldPasswd: currentPassword,
      newPasswd: newPassword,
    );
    ApiService apiService = ApiService();
    final changed = await apiService.custChangePassword(changePasswordModel);;
    if (!context.mounted) return;
    if(changed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password Changed successfully.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen1()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password change failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4300),
        foregroundColor: Colors.white,
        title: const Text('Change Password'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Breadcrumb(
              items: [
                BreadcrumbItem(
                  'Home',
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen1()),
                      (route) => false,
                    );
                  },
                ),
                BreadcrumbItem('Change Password'),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome Mr. $_customerName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C4300),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscuredPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscuredPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscuredPassword = !_isObscuredPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _isObscuredNewPassword,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscuredNewPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscuredNewPassword = !_isObscuredNewPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a new password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C4300),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Bottombar(selectedIndex: 0),
    );
  }
}
