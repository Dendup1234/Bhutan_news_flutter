import 'package:flutter/material.dart';

class BusinessTab extends StatefulWidget {
  const BusinessTab({super.key});

  @override
  State<BusinessTab> createState() => _BusinessTabState();
}

class _BusinessTabState extends State<BusinessTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Business Section'),  
      ),
      );
  }
}