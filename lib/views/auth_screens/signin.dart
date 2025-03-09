import 'dart:typed_data';

import 'package:aura_techwizard/components/colors.dart';
import 'package:aura_techwizard/components/text_field_input.dart';
import 'package:aura_techwizard/components/utils.dart';
import 'package:aura_techwizard/resources/auth_methods.dart';
import 'package:aura_techwizard/views/MainLayoutScreen.dart';
import 'package:aura_techwizard/views/auth_screens/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  TimeOfDay _wakeUpTime = TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _bedTime = TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _workStartTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = TimeOfDay(hour: 17, minute: 0);
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userNameController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, String timeType) async {
    TimeOfDay initialTime;
    switch (timeType) {
      case 'wakeup':
        initialTime = _wakeUpTime;
        break;
      case 'bed':
        initialTime = _bedTime;
        break;
      case 'workstart':
        initialTime = _workStartTime;
        break;
      case 'workend':
        initialTime = _workEndTime;
        break;
      default:
        initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        switch (timeType) {
          case 'wakeup':
            _wakeUpTime = picked;
            break;
          case 'bed':
            _bedTime = picked;
            break;
          case 'workstart':
            _workStartTime = picked;
            break;
          case 'workend':
            _workEndTime = picked;
            break;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    // Assuming AuthMethods() and necessary user information are defined elsewhere
    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _userNameController.text,
      fullname: _fullNameController.text,
      contactnumber: _phoneNumberController.text,
      file: _image!,
      age: int.tryParse(_ageController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      height: double.tryParse(_heightController.text) ?? 0.0,
      wakeUpTime: _formatTimeOfDay(_wakeUpTime),
      bedTime: _formatTimeOfDay(_bedTime),
      workStartTime: _formatTimeOfDay(_workStartTime),
      workEndTime: _formatTimeOfDay(_workEndTime),
    );

    setState(() {
      _isLoading = false;
    });
    if (res != 'success') {
      showSnackBar(res, context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainLayoutScreen()),
      );
    }
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  void navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  'Sign In',
                  style: TextStyle(color: Colors.black, fontSize: 35),
                ),
                const SizedBox(height: 20),

                // Circular avatar for profile image
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                'https://i.pinimg.com/originals/65/25/a0/6525a08f1df98a2e3a545fe2ace4be47.jpg'),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.lightPink),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        const Text(
                          "Username",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your Username',
                          textEditingController: _userNameController,
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Full Name",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your Full Name',
                          textEditingController: _fullNameController,
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Contact Number",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your Contact Number',
                          textEditingController: _phoneNumberController,
                          textInputType: TextInputType.text,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Email",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your email',
                          textEditingController: _emailController,
                          textInputType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "Password",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your password',
                          textEditingController: _passwordController,
                          textInputType: TextInputType.text,
                          isPass: true,
                        ),
                        const Text(
                          "Age",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your age',
                          textEditingController: _ageController,
                          textInputType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Weight (kg)",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your weight',
                          textEditingController: _weightController,
                          textInputType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          "Height (cm)",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextFieldInput(
                          hintText: 'Enter your height',
                          textEditingController: _heightController,
                          textInputType: TextInputType.number,
                        ),
                        const SizedBox(height: 24),

                        // Time selection buttons
                        ListTile(
                          title: Text(
                              'Wake Up Time: ${_formatTimeOfDay(_wakeUpTime)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, 'wakeup'),
                          ),
                        ),
                        ListTile(
                          title:
                              Text('Bed Time: ${_formatTimeOfDay(_bedTime)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, 'bed'),
                          ),
                        ),
                        ListTile(
                          title: Text(
                              'Work Start Time: ${_formatTimeOfDay(_workStartTime)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, 'workstart'),
                          ),
                        ),
                        ListTile(
                          title: Text(
                              'Work End Time: ${_formatTimeOfDay(_workEndTime)}'),
                          trailing: IconButton(
                            icon: Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, 'workend'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      color: Colors.blue,
                    ),
                    child: !_isLoading
                        ? const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.white),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: const Text(
                          ' Log in.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
