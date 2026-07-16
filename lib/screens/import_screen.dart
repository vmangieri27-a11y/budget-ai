import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../services/document_reader.dart';
import '../services/gemini_service.dart';
import '../models/transaction.dart' as model;
import '../providers/transaction_provider.dart';


class ImportScreen extends StatefulWidget {

  const ImportScreen({super.key});


  @override
  State<ImportScreen> createState() => _ImportScreenState();

}



class _ImportScreenState extends State<ImportScreen> {


  bool loading = false;

  String? error;


  List<model.Transaction> transactions = [];



  Future<void> pickFile() async {


    setState(() {

      loading = true;

      error = null;

      transactions = [];

    });



    try {


      final result =
          await FilePicker.platform.pickFiles(

        type: FileType.custom,

        allowedExtensions: [

          'xlsx',
          'xls',
          'csv'

        ],

        withData: true,

      );



      if(result == null){

        setState(() {

          loading=false;

        });

        return;

      }




      final file =
          result.files.single;




      final text =
          await DocumentReader.read(file);




      if(text.trim().isEmpty){

        throw Exception(
          "Il file è vuoto"
        );

      }




      final resultAI =
          await GeminiService.analyzeDocument(
            text,
          );



      if(!mounted)return;



      setState(() {

        transactions = resultAI;

        loading=false;

      });



    }

    catch(e){


      if(!mounted)return;


      setState(() {

        error=e.toString();

        loading=false;

      });


    }


  }






  Future<void> saveTransactions() async {


    final provider =
        Provider.of<TransactionProvider>(
          context,
          listen:false,
        );



    for(final t in transactions){


      await provider.addTransaction(t);


    }




    if(!mounted)return;



    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(

        content: Text(
          "${transactions.length} movimenti importati"
        ),

      ),

    );



    setState(() {

      transactions=[];

    });



  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
          "Importa estratto conto AI"
        ),

      ),



      body:

      transactions.isEmpty

          ?

      buildUpload()


          :

      buildPreview(),



    );


  }








  Widget buildUpload(){


    return Center(

      child:Padding(

        padding:
        const EdgeInsets.all(30),


        child:Column(

          mainAxisSize:
          MainAxisSize.min,


          children:[



            const Icon(

              Icons.auto_awesome,

              size:80,

            ),




            const SizedBox(
              height:20,
            ),




            const Text(

              "Carica qualsiasi file finanziario\n\nExcel, CSV\n\nGemini analizzerà automaticamente le transazioni",

              textAlign:
              TextAlign.center,

            ),




            const SizedBox(
              height:20,
            ),




            if(error!=null)

              Text(

                error!,

                style:
                const TextStyle(
                  color:Colors.red,
                ),

                textAlign:
                TextAlign.center,

              ),




            const SizedBox(
              height:20,
            ),




            ElevatedButton.icon(


              onPressed:
              loading
                  ?

              null

                  :

              pickFile,



              icon:

              loading

                  ?

              const SizedBox(

                width:18,

                height:18,

                child:
                CircularProgressIndicator(),

              )

                  :

              const Icon(
                Icons.upload_file
              ),




              label:

              Text(

                loading

                    ?

                "Analisi AI..."

                    :

                "Carica documento"

              ),


            )


          ],


        ),


      ),

    );


  }









  Widget buildPreview(){


    return Column(

      children:[



        Padding(

          padding:
          const EdgeInsets.all(16),


          child:Text(

            "${transactions.length} movimenti trovati da Gemini",

            style:
            const TextStyle(

              fontWeight:
              FontWeight.bold,

              fontSize:18,

            ),

          ),

        ),





        Expanded(

          child:ListView.builder(

            itemCount:
            transactions.length,


            itemBuilder:(context,index){


              final t =
                  transactions[index];



              return Card(

                margin:
                const EdgeInsets.symmetric(

                  horizontal:16,

                  vertical:6,

                ),


                child:ListTile(


                  title:
                  Text(
                    t.description
                  ),



                  subtitle:
                  Text(

                    "${t.date.day}/${t.date.month}/${t.date.year}\n${t.category}",

                  ),




                  trailing:

                  Text(

                    "€ ${t.amount.toStringAsFixed(2)}",

                    style:

                    TextStyle(

                      fontWeight:
                      FontWeight.bold,

                      color:

                      t.amount < 0

                          ?

                      Colors.red

                          :

                      Colors.green,

                    ),

                  ),


                ),


              );



            },


          ),


        ),





        Padding(

          padding:
          const EdgeInsets.all(16),


          child:SizedBox(

            width:
            double.infinity,


            child:
            ElevatedButton.icon(


              onPressed:
              saveTransactions,


              icon:
              const Icon(
                Icons.save,
              ),


              label:
              const Text(
                "Salva movimenti",
              ),


            ),

          ),

        )



      ],

    );


  }



}