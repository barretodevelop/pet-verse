import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

class ItemEffectEntity extends Equatable {
  final ItemEffectType type;
  final int value;
  final Duration? duration;
  final bool isInstant;

  const ItemEffectEntity({
    required this.type,
    required this.value,
    this.duration,
    this.isInstant = true,
  });

  @override
  List<Object?> get props => [type, value, duration, isInstant];
}
