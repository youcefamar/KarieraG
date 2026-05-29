import 'package:Kariera/Pages/formulaire_aremplir.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormationDetailsPage2 extends StatelessWidget {
  final Map<String, dynamic> formationData;

  const FormationDetailsPage2({Key? key, required this.formationData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              formationData['imageUrl'] ?? '',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 26),
            Text(
              formationData['title'] ?? '',
              style: GoogleFonts.dmSerifDisplay(fontSize: 28, ),
            ),
            SizedBox(height: 25),
            Text("About",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Container(
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Text(
                        '${formationData['about']}',
                      style: GoogleFonts.notoSerif(fontSize: 14,color: Colors.grey[600],height: 2
                      ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                     
                        Text('Créé Par ',
                        style: GoogleFonts.notoSerif(fontSize: 12,color: Colors.black,),
                        ),
                        SizedBox(width: 3,),
                        Text(
                          '${formationData['nomInstitut']}',
                          style: GoogleFonts.lora(fontSize: 13,color: Color.fromARGB(255, 150, 38, 170),fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 25,),
                    
                     
                    Text("Ce que vous apprendrez",style: GoogleFonts.notoSerif(fontSize: 20,fontWeight: FontWeight.bold),),
                     SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.check,size: 22,),
                        SizedBox(width: 10),
                        Container(
                          constraints: BoxConstraints(maxWidth: 280),
                          child: Text(
                            '${formationData['Programe']}',
                          style: GoogleFonts.notoSerif(fontSize: 14,color: Colors.black,height: 2
                          ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled_rounded,size: 20,),
                        SizedBox(width: 10),
                        Text('Durée :',
                        style: GoogleFonts.notoSerif(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10,),
                        Text(
                          '${formationData['duree']}', 
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Icon(Icons.school,size: 20,),
                        SizedBox(width: 10),
                        Text('Prerequis :',
                        style: GoogleFonts.notoSerif(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10,),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: 190,
                          ),
                          child: Text(
                            '${formationData['prerequis']}',
                            style: GoogleFonts.lora(fontSize: 14,color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: [
                        Icon(Icons.category,size: 18,),
                        SizedBox(width: 10),
                        Text('Catégorie :',
                        style: GoogleFonts.notoSerif(fontSize: 16,color: Colors.black,fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10,),
                        Text(
                          '${formationData['categorie']}', 
                          style: GoogleFonts.lora(fontSize: 14,color: Colors.black),
                        ),
                      ],
                    ),
                       SizedBox(height: 25,),
                       Row(
                      children: [
                        Icon(Icons.place,size: 18,color: const Color.fromARGB(255, 68, 67, 67),),
                        
                        SizedBox(width: 10,),
                        Text(
                          '${formationData['localisation']}', 
                          style: GoogleFonts.lora(fontSize: 14,color: Colors.black,),
                        ),
                      ],
                    ),
                      SizedBox(height: 25,),
                       Row(
                      children: [
                        Icon(Icons.local_activity,size: 18,color: const Color.fromARGB(255, 68, 67, 67),),
                        
                        SizedBox(width: 10,),
                        Text(
                          '${formationData['type']}', 
                          style: GoogleFonts.lora(fontSize: 14,color: Colors.black,),
                        ),
                      ],
                    ),
                    
                    
                    
            SizedBox(height: 40),
                              
          ],
        ),
      ),
    );
  }
}
