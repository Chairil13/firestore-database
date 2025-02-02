// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:training_firebase/pages/login/widgets/snackbar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Enter your email address and we will send you a link to your email to reset your password.',
              style: GoogleFonts.raleway(
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Email Address",
                hintText: "Masukkan email anda!",
                labelStyle: GoogleFonts.raleway(),
                hintStyle: GoogleFonts.raleway(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (emailController.text.trim().isEmpty) {
                  showSnackBar(context, "Tolong input email anda!");
                  return;
                }
                try {
                  await auth.sendPasswordResetEmail(
                    email: emailController.text.trim(),
                  );
                  showSnackBar(
                    context,
                    "Link reset password telah dikirim ke email anda!",
                  );
                  Navigator.pop(context);
                } catch (error) {
                  showSnackBar(context, error.toString());
                }
              },
              child: Text(
                'Reset Password',
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
