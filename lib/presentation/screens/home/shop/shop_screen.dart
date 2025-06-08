// File: lib/presentation/screens/home/shop/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/screens/home/shop/enhanced_shop_screen.dart';

/// Shop screen for purchasing items and upgrades
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const EnhancedShopScreen();
  }
}
