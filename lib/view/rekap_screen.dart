import 'package:flutter/material.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Rekap Content'),
      ),
    );
  }
}
