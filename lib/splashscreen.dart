import 'package:flutter/material.dart';

/// A simple welcome screen shown briefly when the app starts.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money, size: 64),
            SizedBox(height: 16),
            Text(
              'Student Expense Tracker',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Track your daily expenses as a student'),
          ],
        ),
      ),
    );
  }
}
