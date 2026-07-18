import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class PeriodFilterBar extends StatelessWidget {
  const PeriodFilterBar({super.key});

  static const _labels = {
    DateFilterPeriod.tutti: 'Tutti',
    DateFilterPeriod.questoMese: 'Questo mese',
    DateFilterPeriod.meseScorso: 'Mese scorso',
    DateFilterPeriod.questoAnno: "Quest'anno",
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DateFilterPeriod.values.map((period) {
          final selected = provider.selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_labels[period]!),
              selected: selected,
              onSelected: (_) => provider.setPeriod(period),
              selectedColor: AppColors.navy,
              labelStyle: TextStyle(
                color: selected ? Colors.white : AppColors.navy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.navy.withOpacity(0.15)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}