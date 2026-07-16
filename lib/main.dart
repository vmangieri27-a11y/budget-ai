import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/transaction_provider.dart';
import 'db/database_helper.dart';
import 'theme/app_theme.dart';

import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/import_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.init();

  runApp(const MyApp());

}



class MyApp extends StatelessWidget {

  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(

      create: (_) => TransactionProvider()..loadTransactions(),

      child: MaterialApp(

        title: 'Budget AI',

        debugShowCheckedModeBanner: false,

        theme: AppTheme.theme,

        home: const HomeShell(),

      ),

    );

  }

}




class HomeShell extends StatefulWidget {

  const HomeShell({super.key});


  @override
  State<HomeShell> createState() => _HomeShellState();

}



class _HomeShellState extends State<HomeShell> {


  int _index = 0;



  final _screens = const [

    DashboardScreen(),

    TransactionsScreen(),

    ImportScreen(),

  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: _screens[_index],



      bottomNavigationBar: NavigationBar(

        selectedIndex: _index,


        onDestinationSelected: (i){

          setState(() {

            _index = i;

          });

        },


        destinations: const [

          NavigationDestination(

            icon: Icon(Icons.pie_chart),

            label: 'Dashboard',

          ),


          NavigationDestination(

            icon: Icon(Icons.list),

            label: 'Movimenti',

          ),


          NavigationDestination(

            icon: Icon(Icons.upload_file),

            label: 'Importa',

          ),

        ],

      ),

    );


  }

}