// Classe base para minijogos
import 'package:flutter/material.dart';

abstract class MiniGame {
  String get name;
  String get description;
  IconData get icon;
  Color get color;
  Widget buildGame(BuildContext context, Function(int) onGameComplete);
}
