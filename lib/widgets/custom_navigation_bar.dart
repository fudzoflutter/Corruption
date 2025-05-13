import 'package:corruption2/viewmodels/status_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) async {
        // Holat sahifasiga o'tayotganda avtomatik yangilash
        if (index == 1) {
          final statusVM = Provider.of<StatusViewModel>(context, listen: false);
          await statusVM.loadReports();
        }
        onTap(index);
      },
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      backgroundColor: const Color(0xFF2E3B4E),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Hisobot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Holat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Sozlamalar',
        ),
      ],
    );
  }
}