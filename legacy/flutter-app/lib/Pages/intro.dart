import 'package:flutter/material.dart';
import 'package:Kariera/Pages/Homepage.dart';

class intropage extends StatelessWidget {
  const intropage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
         Column(
          children:[
              Padding(
              padding: EdgeInsets.only(left: 10, top: 80,bottom: 20),
              child:
              Image.asset('assets/educ1.png',width: 300,),),
              SizedBox(height: 10,),
              Column(
              children:[
                Padding(
                padding: EdgeInsets.only(left: 10),
                child:
              Text("Voulez vous construire votre avenir ! ",textAlign: TextAlign.center,),),
                Padding(
                padding: EdgeInsets.only(left: 10),
                child:
              Text("Iseeg est la pour vous en proposant des formations professionels",style: TextStyle(fontSize: 20,color: Colors.black54,),textAlign: TextAlign.center,),),],),

              SizedBox(height: 35),
              
               GestureDetector(
                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){return Homepage();},
                ),
                ),
               child:
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.pink,),
                child: const Text("Demarrez Maintenant"),
                padding: const EdgeInsets.all(20.0),
                
                ),
              ),
              ),
             SizedBox(height: 70,), 
          ],
              ),
    );
  }
}