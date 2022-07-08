import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:get/get.dart';
import 'package:mahospital/screen/login_screen.dart';
import 'package:universal_html/js.dart';

class ResetPWScreen extends StatelessWidget {
  final TextEditingController emailCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // SizedBox(
            //   width: MediaQuery.of(context).size.width * 0.6,
            //   child:
            Text(
              'Receive an email to\nreset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            // )
            SizedBox(
              height: 20,
            ),
            TextFormField(
                controller: emailCont,
                textInputAction: TextInputAction.done,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: EmailValidator(errorText: 'Enter a valid email')),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
              icon: Icon(Icons.email_outlined),
              label: Text(
                'Reset Password',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () => resetPW(context),
            )
          ],
        ),
      ),
    );
  }

  void resetPW(BuildContext ctx) async {
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext context) => Center(
              child: CircularProgressIndicator(),
            ));

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailCont.text.trim());
      Get.offAll(LoginScreen());
      Get.snackbar(
        "Success",
        "Password reset email sent",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      Get.back();
    }
  }
}
