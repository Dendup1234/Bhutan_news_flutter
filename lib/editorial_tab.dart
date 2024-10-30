import 'package:flutter/material.dart';

class EditorialTab extends StatefulWidget {
  const EditorialTab({super.key});

  @override
  State<EditorialTab> createState() => _EditorialTabState();
}

class _EditorialTabState extends State<EditorialTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editorial Section'),
      ),
    );
  }
}