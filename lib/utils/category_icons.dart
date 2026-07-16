import 'package:flutter/material.dart';
import '../theme/app_theme.dart';


const List<String> incomeCategories = [
  'Stipendio',
  'Altra Entrata',
];


const List<String> expenseCategories = [
  'Gestione Casa',
  'Salute',
  'Attività Fisica',
  'Shopping',
  'Ristoranti e Bar',
  'Trasporti',
  'Abbonamenti',
  'Viaggi',
  'Animali',
  'Altro',
];


const List<String> categories = [
  ...incomeCategories,
  ...expenseCategories,
];


IconData categoryIcon(String category) {

  switch(category){

    case 'Stipendio':
      return Icons.work;

    case 'Altra Entrata':
      return Icons.savings;

    case 'Gestione Casa':
      return Icons.home;

    case 'Salute':
      return Icons.favorite;

    case 'Attività Fisica':
      return Icons.fitness_center;

    case 'Shopping':
      return Icons.shopping_bag;

    case 'Ristoranti e Bar':
      return Icons.restaurant;

    case 'Trasporti':
      return Icons.directions_car;

    case 'Abbonamenti':
      return Icons.subscriptions;

    case 'Viaggi':
      return Icons.flight;

    case 'Animali':
      return Icons.pets;

    default:
      return Icons.receipt;
  }
}



Color categoryColor(String category){

  switch(category){

    case 'Stipendio':
      return AppColors.gold;

    case 'Gestione Casa':
      return const Color(0xff8E6C88);

    case 'Salute':
      return AppColors.softGreen;

    case 'Attività Fisica':
      return const Color(0xff5B9E8F);

    case 'Shopping':
      return const Color(0xffC15B7A);

    case 'Ristoranti e Bar':
      return const Color(0xffE0A458);

    case 'Trasporti':
      return const Color(0xff5B8FB9);

    case 'Abbonamenti':
      return const Color(0xff7A6FB0);

    case 'Viaggi':
      return const Color(0xff4A9CB5);

    case 'Animali':
      return const Color(0xffA56A43);

    default:
      return AppColors.grey;
  }

}