import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'saved_screen.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController familyPhoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController(); // ✅ جديد

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('name') ?? '';
      ageController.text = prefs.getString('age') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      familyPhoneController.text = prefs.getString('familyPhone') ?? '';
      locationController.text = prefs.getString('locationUrl') ?? ''; // ✅ جديد
    });
  }

  Future<void> saveData() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text);
      await prefs.setString('age', ageController.text);
      await prefs.setString('phone', phoneController.text);
      await prefs.setString('familyPhone', familyPhoneController.text);
      await prefs.setString('locationUrl', locationController.text); // ✅ جديد

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('data_saved'.tr())),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),
      );
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_name'.tr();
    }
    if (!RegExp(r'^[a-zA-Zأ-ي\s]+$').hasMatch(value)) {
      return 'error_invalid_name'.tr();
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'error_phone'.tr();
    }
    if (!RegExp(r'^\d{9,}$').hasMatch(value)) {
      return 'error_invalid_phone'.tr();
    }
    return null;
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
          'edit_profile'.tr(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.black),
            onPressed: () {
              final newLocale = context.locale.languageCode == 'en' ? Locale('ar') : Locale('en');
              context.setLocale(newLocale);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth * 0.95;
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Container(
                width: maxWidth,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTextFormField(
                        label: 'name'.tr(),
                        controller: nameController,
                        validator: validateName,
                      ),
                      buildTextFormField(
                        label: 'age'.tr(),
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
                      buildTextFormField(
                        label: 'phone'.tr(),
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: validatePhone,
                      ),
                      buildTextFormField(
                        label: 'family_phone'.tr(),
                        controller: familyPhoneController,
                        keyboardType: TextInputType.phone,
                        validator: validatePhone,
                      ),
                      buildTextFormField(
                        label: 'location'.tr(),
                        controller: locationController,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'error_location'.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD4AF37),
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 4,
                        ),
                        child: Text(
                          'save'.tr(),
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

  Widget buildTextFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    );
  }
}
