import 'package:flutter/material.dart';
import 'theme.dart';
import '../features/profile/pages/profile_setup_pages.dart';

class IntercomApp extends StatelessWidget {
  const IntercomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Intercom',
      theme: AppTheme.light,
      home: const ProfileSetupPage(),
    );
  }
}