import 'package:flutter/material.dart';
import 'package:godus/viewModel/akun_view_model.dart';
// import 'package:provider/provider.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  AkunViewModel am = AkunViewModel();

  @override
  Widget build(BuildContext context) {
    // final preferences = Provider.of<AkunViewModel>(context);
    return const Scaffold(
      body: Center(
        child: Text('Akun Content'),
      ),
    );
  }
}
