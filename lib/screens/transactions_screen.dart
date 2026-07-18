import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;
import '../theme/app_theme.dart';
import '../utils/category_icons.dart';
import '../widgets/period_filter_bar.dart';

enum _Filter { tutti, entrate, uscite }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  _Filter _filter = _Filter.tutti;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    var transactions = provider.transactionsForPeriod;

    if (_filter == _Filter.entrate) {
      transactions = transactions.where((t) => t.amount > 0).toList();
    } else if (_filter == _Filter.uscite) {
      transactions = transactions.where((t) => t.amount < 0).toList();
    }

    if (_selectedCategory != null) {
      transactions =
          transactions.where((t) => t.category == _selectedCategory).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movimenti'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<_Filter>(
                value: _filter,
                borderRadius: BorderRadius.circular(14),
                items: const [
                  DropdownMenuItem(value: _Filter.tutti, child: Text('Tutti')),
                  DropdownMenuItem(value: _Filter.entrate, child: Text('Entrate')),
                  DropdownMenuItem(value: _Filter.uscite, child: Text('Uscite')),
                ],
                onChanged: (v) => setState(() => _filter = v!),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PeriodFilterBar(),
                const SizedBox(height: 10),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _selectedCategory,
                    hint: const Text('Tutte le categorie'),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(14),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tutte le categorie'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem<String?>(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedCategory = value),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? const Center(
                        child: Text('Nessuna transazione',
                            style: TextStyle(color: AppColors.grey)))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                    final t = transactions[index];
                    final isExpense = t.amount < 0;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: categoryColor(t.category).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(categoryIcon(t.category), color: categoryColor(t.category), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.description,
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
                                const SizedBox(height: 2),
                                Text('${t.category} · ${t.date.day}/${t.date.month}/${t.date.year}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                              ],
                            ),
                          ),
                          Text(
                            '${isExpense ? '-' : '+'}€ ${t.amount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isExpense ? AppColors.softRed : AppColors.softGreen,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.grey, size: 20),
                            onPressed: () {
                              if (t.id != null) provider.deleteTransaction(t.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = categories.first;
    bool isExpense = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nuova transazione',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(labelText: 'Descrizione'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Importo', hintText: 'es. 1.50'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Spesa'),
                              selected: isExpense,
                              onSelected: (_) => setState(() => isExpense = true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Entrata'),
                              selected: !isExpense,
                              onSelected: (_) => setState(() => isExpense = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: const InputDecoration(labelText: 'Categoria'),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => selectedCategory = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Annulla'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final rawAmount = amountController.text.trim().replaceAll(',', '.');
                              final parsedAmount = double.tryParse(rawAmount);

                              if (descController.text.trim().isEmpty || parsedAmount == null || parsedAmount == 0) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(content: Text('Compila descrizione e importo valido')),
                                );
                                return;
                              }

                              final finalAmount = isExpense ? -parsedAmount.abs() : parsedAmount.abs();
                              final provider = Provider.of<TransactionProvider>(context, listen: false);

                              final success = await provider.addTransaction(
                                model.Transaction(
                                  date: DateTime.now(),
                                  description: descController.text.trim(),
                                  amount: finalAmount,
                                  category: selectedCategory,
                                  isManual: true,
                                ),
                              );

                              if (!dialogContext.mounted) return;
                              if (success) {
                                Navigator.pop(dialogContext);
                              }
                            },
                            child: const Text('Salva'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}