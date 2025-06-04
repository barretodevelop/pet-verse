import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration =
      const Duration(seconds: 4), // Aumentado um pouco a duração padrão
}) {
  Color backgroundColor;
  IconData iconData;

  switch (type) {
    case SnackBarType.success:
      backgroundColor =
          Colors.green.shade700; // Um pouco mais escuro para contraste
      iconData = Icons.check_circle;
      break;
    case SnackBarType.error:
      backgroundColor =
          Colors.red.shade700; // Um pouco mais escuro para contraste
      iconData = Icons.error;
      break;
    case SnackBarType.info:
    default:
      backgroundColor = Colors.blueGrey.shade700;
      iconData = Icons.info;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(iconData, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontSize: 15))),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 6.0,
    ),
  );
}
