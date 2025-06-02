// lib/shared/widgets/styled_app_bar.dart
import 'package:flutter/material.dart';

class StyledAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  const StyledAppBar({super.key, required this.title, this.actions});
  @override
  Widget build(BuildContext context) =>
      AppBar(title: Text(title), actions: actions, centerTitle: true);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
