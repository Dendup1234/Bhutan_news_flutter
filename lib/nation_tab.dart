import 'package:flutter/material.dart';

class NationTab extends StatefulWidget {
  const NationTab({super.key});

  @override
  State<NationTab> createState() => _NationTabState();
}

class _NationTabState extends State<NationTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nation Section')
      ),
    );
  }
}