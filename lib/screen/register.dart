import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:loginsystem/model/profile.dart';
import 'package:loginsystem/screen/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  Profile profile = Profile(email: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Error"),
              ),
              body: Center(
                child: Text("${snapshot.error}"),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("สร้างบัญชีผู้ใช้ระบบ"),
              ),
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("อีเมล", style: TextStyle(fontSize: 20)),
                          TextFormField(
                            validator: MultiValidator([
                              RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                              EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง")
                            ]),
                            keyboardType: TextInputType.emailAddress,
                            onSaved: (String? email) {
                              profile.email = email!;
                            },
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text("รหัสผ่าน", style: TextStyle(fontSize: 20)),
                          TextFormField(
                            validator: RequiredValidator(
                                errorText: "กรุณาป้อนรหัสผ่าน"),
                            obscureText: true,
                            onSaved: (String? password) {
                              profile.password = password!;
                            },
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Text("ลงทะเบียน",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  try {
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                            email: profile.email,
                                            password: profile.password
                                            ).then((value) {
                                      formKey.currentState!.reset();
                                      Fluttertoast.showToast(
                                          msg: "สร้างบัญชีผู้ใช้เรียบร้อยแล้ว",
                                          gravity: ToastGravity.TOP);
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return HomeScreen();
                                      }));
                                    });
                                  } on FirebaseAuthException catch (e) {
                                    print(e.code);
                                    String? message;
                                    // print(e.message);
                                    if (e.code == 'email-already-in-use') {
                                      message =
                                          "มีอีเมลนี้ในระบบแล้ว โปรดใช้อีเมลอื่น";
                                    } else if (e.code == 'weak-password') {
                                      message =
                                          "รหัสผ่านต้องมีความยาว 6 ตัวอักษรขึ้นไป";
                                    }
                                    Fluttertoast.showToast(
                                        msg: message!,
                                        gravity: ToastGravity.CENTER);
                                  }
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
