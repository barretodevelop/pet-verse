class AIConfig {
  String apiUrl;
  String apiKey;
  bool enabled;

  AIConfig({
    this.apiUrl = '',
    this.apiKey = '',
    this.enabled = false,
  });

  factory AIConfig.fromJson(Map<String, dynamic> json) {
    return AIConfig(
      apiUrl: json['apiUrl'] ?? '',
      apiKey: json['apiKey'] ?? '',
      enabled: json['enabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiUrl': apiUrl,
      'apiKey': apiKey,
      'enabled': enabled,
    };
  }

  AIConfig copyWith({String? apiUrl, String? apiKey, bool? enabled}) {
    return AIConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiKey: apiKey ?? this.apiKey,
      enabled: enabled ?? this.enabled,
    );
  }
}
