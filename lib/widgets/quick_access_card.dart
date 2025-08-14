import 'package:flutter/material.dart';
import '../globals.dart';
import '../screens/shops_view.dart';
import '../screens/people_view.dart';
import '../screens/government_screen.dart';
import '../screens/market_screen.dart';

class QuickAccessCard extends StatelessWidget {
  const QuickAccessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Access',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const _QuickAccessGrid(),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.store,
                label: 'Shops',
                color: Colors.green,
                onTap: () => navigatorKey.currentState?.pushNamed(ShopsView.routeName),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.groups,
                label: 'People',
                color: Colors.blue,
                onTap: () => navigatorKey.currentState?.pushNamed(PeopleView.routeName),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.account_balance,
                label: 'Government',
                color: Colors.purple,
                onTap: () => navigatorKey.currentState?.pushNamed(GovernmentView.routeName),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAccessButton(
                icon: Icons.shopping_cart,
                label: 'Market',
                color: Colors.orange,
                onTap: () => navigatorKey.currentState?.pushNamed(MarketView.routeName),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}