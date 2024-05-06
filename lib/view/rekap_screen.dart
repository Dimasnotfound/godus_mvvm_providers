import 'package:flutter/material.dart';

class RekapScreen extends StatelessWidget {
  const RekapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Screen'),
      ),
      body: const Center(
        child: Text('Rekap Content'),
      ),
    );
  }
}
