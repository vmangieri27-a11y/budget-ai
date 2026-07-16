import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';
import '../utils/category_icons.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final byCategory = provider.expensesByCategory;

    return Scaffold(
      appBar: AppBar(title: const Text('Il tuo budget')),
      body: RefreshIndicator(
        onRefresh: provider.loadTransactions,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _BalanceCard(balance: provider.balance),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Entrate',
                    amount: provider.totalIncome,
                    color: AppColors.softGreen,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Uscite',
                    amount: provider.totalExpenses.abs(),
                    color: AppColors.softRed,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (byCategory.isNotEmpty) ...[
              const Text('Spese per categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.navy)),
              const SizedBox(height: 12),
              _CategoryPieChart(byCategory: byCategory),
              const SizedBox(height: 12),
              ...byCategory.entries.map((e) => _CategoryRow(
                    category: e.key,
                    amount: e.value,
                    total: byCategory.values.fold(0.0, (a, b) => a + b),
                  )),
            ] else
              const _EmptyState(),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyLight],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.navy.withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Saldo disponibile',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            '€ ${balance.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _StatCard({required this.label, required this.amount, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('€ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.navy)),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<String, double> byCategory;
  const _CategoryPieChart({required this.byCategory});

  @override
  Widget build(BuildContext context) {
    final total = byCategory.values.fold(0.0, (a, b) => a + b);
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 55,
          sections: byCategory.entries.map((e) {
            final pct = total == 0 ? 0 : (e.value / total * 100);
            return PieChartSectionData(
              value: e.value,
              color: categoryColor(e.key),
              title: '${pct.toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  const _CategoryRow({required this.category, required this.amount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor(category).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(categoryIcon(category), color: categoryColor(category), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(category, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
          ),
          Text('€ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.insert_chart_outlined_rounded, size: 48, color: AppColors.grey.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Nessuna spesa ancora', style: TextStyle(color: AppColors.grey)),
        ],
      ),
    );
  }
}