import 'package:flutter/material.dart';

class AkunScreen extends StatelessWidget {
  const AkunScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Screen'),
      ),
      body: const Center(
        child: Text('Akun Content'),
      ),
    );
  }
}
