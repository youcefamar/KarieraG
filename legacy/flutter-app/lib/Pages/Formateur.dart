import 'package:Kariera/Components/textfield.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormateurPage extends StatefulWidget {
  const FormateurPage({Key? key}) : super(key: key);

  @override
  State<FormateurPage> createState() => _FormateurPageState();
}

class _FormateurPageState extends State<FormateurPage> {
  final emailController = TextEditingController();
  final _emailController = TextEditingController();
  final letterController = TextEditingController();
  final nomdinstitutController = TextEditingController();
  final numeroController = TextEditingController();

  bool _here = false;

  void _check_info_formateur() async {
    if (_emailController.text.trim().isEmpty) return;

    final documentSnapshot = await FirebaseFirestore.instance
        .collection('ourformateurs')
        .doc(_emailController.text)
        .get();
    if (documentSnapshot.exists) {
      final email = documentSnapshot['CodeVLD'];

      print(email);
      if (_emailController.text == email) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text, password: "000000");
        _emailController.clear();
        Navigator.pushReplacementNamed(context, "formateurhome");
      } else {
        AwesomeDialog(
                context: context,
                title: 'info',
                dialogType: DialogType.info,
                animType: AnimType.leftSlide,
                desc: 'You Are Not accepted Yet')
            .show();
      }
      //Navigat to add button(formation page) and my formation
    } else {
      AwesomeDialog(
              context: context,
              title: 'error',
              dialogType: DialogType.error,
              animType: AnimType.leftSlide,
              desc: 'there is a problem please try again')
          .show();
    }
  }

  void _sendinfo_formateur() async {
    if (emailController.text.trim().isEmpty &&
        letterController.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('formateurs')
        .doc(emailController.text)
        .set({
      'email': emailController.text, //gmail.com
      'numero': numeroController.text,
      'nom_dinstitut': nomdinstitutController.text,
      'letter': letterController.text,

    });
    emailController.clear();
    letterController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent,),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    children: [
                     
                       Padding(
                         padding: const EdgeInsets.only(left: 20),
                         child: Text(
                                           "Se Connecter en tant que Formateur",
                                           style: GoogleFonts.notoSerif(
                                               fontSize: 20, ),
                                         ),
                       ),
                      const SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                          width: 150,
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/formimage.jpeg'),
                            radius: 70,
                          )),
                      SizedBox(
                        height: 45,
                      ),
                    
                        textfield(
                                          hintText: "Code se termine par @kariera.com",
                                          obscureText: true,
                                          controlleer: _emailController,
                                        ),
                      
                      SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                          
                          onTap: () {
                            _check_info_formateur();
                          },
                          child:
                          Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 43, 40, 40),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Center(
                        child: Text(
                      'Sign In',
                      style: GoogleFonts.lora(fontSize: 17,color:Colors.white,fontWeight:FontWeight.bold),
                    )),
                  ), 
                          
                          
                          ),
                      const SizedBox(
                        height: 20,
                      ),
                       Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             Text('Devenez un formateur !',
                             style: GoogleFonts.lora(
                              fontSize:15,
                              color:Colors.black,
                             ),
                             ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _here = !_here;
                                });
                              },
                              child:  Text('Cliquez',
                              style: GoogleFonts.lora(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      
                      
                      _here
                          ? Column(
                              children: [
                                const Text(
                                  'file this please we will Contact you',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 186, 3, 3),
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    hintText: 'Email Personnel',
                                  ),
                                ),
                                SizedBox(height: 20,),
                                 TextField(
                                  controller: numeroController,
                                  decoration: InputDecoration(
                                    hintText: 'Numero de telephone',
                                  ),
                                ),
                                 SizedBox(height: 20,),
                                 TextField(
                                  controller: nomdinstitutController,
                                  decoration: InputDecoration(
                                    hintText: "Nom d'institut",
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextField(
                                  controller: letterController,
                                  decoration: InputDecoration(
                                    hintText: 'Registration Letter',
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                    
                                    onTap: () {
                                      //sned info to firestore fourmateur_demande
                                      _sendinfo_formateur();
                      
                                      AwesomeDialog(
                                              context: context,
                                              title: 'All Good',
                                              dialogType: DialogType.success,
                                              animType: AnimType.leftSlide,
                                              desc:
                                                  'Check your Email we send you a new email to sign in')
                                          .show();
                                    },
                                    child:Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(horizontal: 35),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 43, 40, 40),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Center(
                        child: Text(
                      'Register',
                      style: GoogleFonts.lora(fontSize: 17,color:Colors.white,fontWeight:FontWeight.bold),
                    )),
                  ), )
                              ],
                            )
                          : SizedBox(), // If not _here, display an empty SizedBox
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
