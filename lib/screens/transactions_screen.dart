import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart' as model;

const categories = ['Cibo', 'Trasporti', 'Casa', 'Svago', 'Salute', 'Altro'];

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Movimenti')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('Nessuna transazione ancora'))
              : ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final t = transactions[index];
                    final isExpense = t.amount < 0;
                    return ListTile(
                      leading: Icon(
                        isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isExpense ? Colors.red : Colors.green,
                      ),
                      title: Text(t.description),
                      subtitle: Text(
                        '${t.category} · ${t.date.day}/${t.date.month}/${t.date.year}',
                      ),
                      trailing: Text(
                        '€ ${t.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isExpense ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onLongPress: () {
                        if (t.id != null) provider.deleteTransaction(t.id!);
                      },
                    );
                  },
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
            return AlertDialog(
              title: const Text('Nuova transazione'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Descrizione'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Importo',
                        hintText: 'es. 1.50',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Tipo:'),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Spesa'),
                          selected: isExpense,
                          onSelected: (_) => setState(() => isExpense = true),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Entrata'),
                          selected: !isExpense,
                          onSelected: (_) => setState(() => isExpense = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => selectedCategory = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annulla'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final rawAmount =
                        amountController.text.trim().replaceAll(',', '.');
                    final parsedAmount = double.tryParse(rawAmount);

                    if (descController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Inserisci una descrizione')),
                      );
                      return;
                    }
                    if (parsedAmount == null || parsedAmount == 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Inserisci un importo valido, es. 1.50')),
                      );
                      return;
                    }

                    final finalAmount =
                        isExpense ? -parsedAmount.abs() : parsedAmount.abs();

                    final provider =
                        Provider.of<TransactionProvider>(context, listen: false);

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
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text(provider.lastError ?? 'Errore sconosciuto')),
                      );
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}