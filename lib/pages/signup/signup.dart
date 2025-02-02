import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:training_firebase/pages/login/login.dart';
import 'package:training_firebase/services/auth_services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _signin(context),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Register Account',
                      style: GoogleFonts.raleway(
                          textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 32)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Lottie.asset(
                    'assets/signup.json',
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  _emailAddress(),
                  const SizedBox(
                    height: 20,
                  ),
                  _password(),
                  const SizedBox(
                    height: 50,
                  ),
                  _signup(context),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _emailAddress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
        ),
        const SizedBox(
          height: 16,
        ),
        TextFormField(
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email tidak boleh kosong';
            }
            if (!isValidEmail(value)) {
              return 'Format email tidak valid';
            }
            return null;
          },
          decoration: InputDecoration(
              filled: true,
              hintText: 'masukkan email anda!',
              hintStyle: const TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
              fillColor: const Color.fromARGB(255, 225, 225, 255),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14))),
        )
      ],
    );
  }

  Widget _password() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 16)),
        ),
        const SizedBox(
          height: 16,
        ),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            return null;
          },
          decoration: InputDecoration(
              filled: true,
              hintText: 'masukkan password anda!',
              hintStyle: const TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 14),
              fillColor: const Color.fromARGB(255, 225, 225, 255),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(14)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )),
        )
      ],
    );
  }

  Widget _signup(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff0D6EFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
      ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          await AuthService().signup(
              email: _emailController.text,
              password: _passwordController.text,
              context: context);
        }
      },
      child: const Text(
        "Sign Up",
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
    );
  }

  Widget _signin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            const TextSpan(
              text: "Already Have Account? ",
              style: TextStyle(
                  color: Color(0xff6A6A6A),
                  fontWeight: FontWeight.normal,
                  fontSize: 16),
            ),
            TextSpan(
                text: "Log In",
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.normal,
                    fontSize: 16),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  }),
          ])),
    );
  }
}
