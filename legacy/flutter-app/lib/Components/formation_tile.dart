import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormationTile extends StatelessWidget {
  final String Nomformations;
  final String NomInstitut;
  final String formationimg;
  final String Rating;
  FormationTile({super.key, required this.Nomformations, required this.NomInstitut, required this.formationimg,required Null Function() onPressed, required this.Rating,});

  @override
  Widget build(BuildContext context) {
    return  
    Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
      
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          
          children: [
            // item image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
               
              ),
                child: Image.asset(
                  formationimg,
                  height: 184,
                  width: 250,
                  
                ),
              
            ),
             Padding(
               padding: const EdgeInsets.only(top :8.0),
               child: Container(
                constraints: BoxConstraints(maxWidth: 200.0),
                 child: Text(style: GoogleFonts.notoSerif(fontSize: 18,fontWeight: FontWeight.bold),
                    Nomformations
                  ),
               ),
             ),
           
            Padding(
              padding: const EdgeInsets.only(top : 8.0),
              child: Text(NomInstitut,
              style: GoogleFonts.lora(fontSize: 12,color: Colors.black87,),
                        
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                  children: [
                  Icon(Icons.star,color: Colors.yellow,),
                  Icon(Icons.star,color: Colors.yellow,),
                  Icon(Icons.star,color: Colors.yellow,),
                  Icon(Icons.star,color: Colors.yellow,),
                  Icon(Icons.star,color: Colors.yellow,),
                  Text(Rating),
                  ],
                ),
            ),
            
            
          ],)
      ),
    );
  }
}