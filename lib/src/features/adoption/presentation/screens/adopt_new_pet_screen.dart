import 'package:flutter/material.dart';

class AdoptNewPetScreen extends StatelessWidget {
  const AdoptNewPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adotar Novo Pet')),
      body: const Center(child: Text('Tela para Adotar Novo Pet')),
    );
  }
}
