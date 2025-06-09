// File: lib/domain/entities/daily_reward_result.dart
// COPIE ESTE CONTEÚDO EXATAMENTE

class DailyRewardResult {
  final bool success;
  final String message;
  final int coinsRewarded;
  final int gemsRewarded;
  final int xpRewarded;
  final int streakDay;
  final bool isLevelUp;

  const DailyRewardResult({
    required this.success,
    this.message = '',
    this.coinsRewarded = 0,
    this.gemsRewarded = 0,
    this.xpRewarded = 0,
    this.streakDay = 1,
    this.isLevelUp = false,
  });

  factory DailyRewardResult.success({
    required int coinsRewarded,
    required int gemsRewarded,
    int xpRewarded = 0,
    int streakDay = 1,
    bool isLevelUp = false,
  }) {
    return DailyRewardResult(
      success: true,
      message: 'Recompensa diária reivindicada com sucesso!',
      coinsRewarded: coinsRewarded,
      gemsRewarded: gemsRewarded,
      xpRewarded: xpRewarded,
      streakDay: streakDay,
      isLevelUp: isLevelUp,
    );
  }

  factory DailyRewardResult.failure(String errorMessage) {
    return DailyRewardResult(
      success: false,
      message: errorMessage,
    );
  }

  bool get hasError => !success;
  bool get hasRewards => success && (coinsRewarded > 0 || gemsRewarded > 0 || xpRewarded > 0);

  String get rewardsText {
    if (!success) return message;

    final rewards = <String>[];
    if (coinsRewarded > 0) rewards.add('$coinsRewarded 💰');
    if (gemsRewarded > 0) rewards.add('$gemsRewarded 💎');
    if (xpRewarded > 0) rewards.add('$xpRewarded XP');

    if (rewards.isEmpty) return 'Nenhuma recompensa';

    String text = 'Você ganhou: ${rewards.join(', ')}';
    if (streakDay > 1) text += ' (Streak dia $streakDay)';
    if (isLevelUp) text += ' 🎉 Level Up!';

    return text;
  }

  @override
  String toString() {
    return 'DailyRewardResult(success: $success, coins: $coinsRewarded, gems: $gemsRewarded)';
  }
}
