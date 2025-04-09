import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phonenumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Image(image: 
            AssetImage("assets/icons/van.png")),
            const SizedBox(height: 20),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username',
              border: OutlineInputBorder(
                borderRadius:BorderRadius.circular(20)
              )),
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _phonenumberController,
              decoration: InputDecoration(labelText: 'PhoneNumber',
              border: OutlineInputBorder(
                borderRadius:BorderRadius.circular(20)
              )),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: 120,
              height: 56,
              child: ElevatedButton(
              child: const Text('SIGN IN',
              style: TextStyle(
                color:Colors.white,
              ),),
              onPressed: () {
                // Handle login logic here
                String username = _usernameController.text;
                String phonenumber = _phonenumberController.text;
                print('Username: $username, Phonenumber: $phonenumber');
              },
              style:ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                padding: EdgeInsets.symmetric(vertical: 20),
                backgroundColor: Colors.deepPurple,
              )
            ),
            ),
            const SizedBox(height: 20),
            Text("Terms and conditions",style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),),
          ],
        ),
      
        
        )
      )
    );
  }
}