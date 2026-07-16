import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transaction.dart';
import '../utils/category_icons.dart';


class GeminiService {


  static Future<List<Transaction>> analyzeDocument(
      String documentText
      ) async {


    final prompt = """

Sei un assistente finanziario.

Analizza questo estratto conto bancario.

Estrai tutti i movimenti e restituisci SOLO JSON valido.

Formato:

[
 {
  "description":"descrizione movimento",
  "amount":-25.50,
  "date":"2026-01-15",
  "category":"Salute"
 }
]


Categorie disponibili per le SPESE (usa esattamente questi nomi):

${expenseCategories.join('\n')}


Categorie disponibili per le ENTRATE (usa esattamente questi nomi):

${incomeCategories.join('\n')}


Regole:

- spese negative
- entrate positive
- data formato YYYY-MM-DD
- usa SOLO le categorie elencate sopra, esattamente come scritte
- nessun testo fuori dal JSON


Estratto conto:

$documentText

""";



    final url = ApiConfig.proxyUrl;



    print("URL PROXY:");
    print(url);



    final response = await http.post(

      Uri.parse(url),

      headers: {

        "Content-Type": "application/json",

        "X-App-Secret": ApiConfig.appSharedSecret,

      },

      body: jsonEncode({

        "contents":[

          {

            "parts":[

              {

                "text": prompt

              }

            ]

          }

        ],

        "generationConfig":{

          "temperature":0.1

        }

      }),

    );



    print("======================");
    print("STATUS GEMINI:");
    print(response.statusCode);

    print("RISPOSTA GEMINI:");
    print(response.body);

    print("======================");



    if(response.statusCode != 200){

      throw Exception(
        "Errore Gemini ${response.statusCode}"
      );

    }



    final data =
        jsonDecode(response.body);



    String text =
        data["candidates"][0]
        ["content"]
        ["parts"][0]
        ["text"];



    text = text
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();



    final List<dynamic> result =
        jsonDecode(text);



    return result.map((item){


      final rawCategory =
          item["category"] as String;


      final category =
          categories.contains(rawCategory)
              ? rawCategory
              : 'Altro';


      return Transaction(

        description:
        item["description"],


        amount:
        (item["amount"] as num)
            .toDouble(),


        date:
        DateTime.parse(
          item["date"],
        ),


        category:
        category,

      );


    }).toList();


  }


}