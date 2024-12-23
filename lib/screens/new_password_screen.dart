import 'package:flutter/material.dart';
import 'successful_update_dialog.dart';

class NewPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Image.asset('assets/images/logo.png', width: 40, height: 40),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/new_password.png',
                height: 150,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Create a New Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Confirm"),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => SuccessfulUpdateDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
