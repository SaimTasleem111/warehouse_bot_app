import 'package:flutter/material.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/inventory/inventoryScreen.dart';
import '../screens/robots/robot_analytics_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/jobs/job_tracking_screen.dart';
import 'app_theme.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  const BottomNav({super.key, this.currentIndex = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    JobTrackingScreen(),
    InventoryScreen(),
    RobotAnalyticsScreen(),
    OrdersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, "Home"),
                _buildNavItem(1, Icons.work_rounded, Icons.work_outline_rounded, "Jobs"),
                _buildNavItem(2, Icons.inventory_2_rounded, Icons.inventory_2_outlined, "Stock"),
                _buildNavItem(3, Icons.precision_manufacturing_rounded, Icons.precision_manufacturing_outlined, "Bots"),
                _buildNavItem(4, Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, "Orders"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon, String label) {
    final isSelected = _currentIndex == index;
    
    Color getIconColor() {
      if (!isSelected) return AppTheme.textTertiary;
      switch (index) {
        case 0: return AppTheme.primary;
        case 1: return AppTheme.warning;
        case 2: return AppTheme.success;
        case 3: return AppTheme.purple;
        case 4: return AppTheme.error;
        default: return AppTheme.primary;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 6),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? getIconColor().withOpacity(0.15) 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  color: getIconColor(),
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? getIconColor() : AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}