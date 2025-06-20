import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Registration successful.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController familyPhoneController = TextEditingController();
  final TextEditingController locationUrlController = TextEditingController();

  Future<void> goToMainScreen() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('name', nameController.text);
      await prefs.setString('age', ageController.text);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString('familyPhone', familyPhoneController.text);
      await prefs.setString('locationUrl', locationUrlController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade100,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'WAYA',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.black),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en'
                  ? Locale('ar')
                  : Locale('en');
              context.setLocale(newLocale);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth =
          constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth * 0.95;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Container(
                width: maxWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'welcome'.tr(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'enter_data'.tr(),
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      SizedBox(height: 20),
                      buildTextField(
                        labelKey: 'name',
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'error_name'.tr();
                          }
                          return null;
                        },
                      ),
                      buildTextField(
                        labelKey: 'age',
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'error_age'.tr();
                          }
                          if (int.tryParse(value) == null) {
                            return 'error_age'.tr();
                          }
                          return null;
                        },
                      ),
                      buildPhoneField(
                        labelKey: 'phone',
                        controller: phoneController,
                        errorEmptyKey: 'error_phone',
                        errorInvalidKey: 'error_phone',
                      ),
                      buildPhoneField(
                        labelKey: 'family_phone',
                        controller: familyPhoneController,
                        errorEmptyKey: 'error_family_phone',
                        errorInvalidKey: 'error_family_phone',
                      ),
                      buildTextField(
                        labelKey: 'location_url',
                        controller: locationUrlController,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'يرجى إدخال رابط العنوان';
                          }
                          return null; // مهم جدًا ترجّع null لو الفالديشن ناجح
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: goToMainScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD4AF37),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'continue'.tr(),
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField({
    required String labelKey,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: labelKey.tr(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }

  Widget buildPhoneField({
    required String labelKey,
    required TextEditingController controller,
    required String errorEmptyKey,
    required String errorInvalidKey,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return errorEmptyKey.tr();
          }
          if (value.length < 9) {
            return errorInvalidKey.tr();
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelKey.tr(),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }
}
