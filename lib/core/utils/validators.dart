// File: lib/core/utils/validators.dart

/// Utility class for common validation functions
class Validators {
  /// Validates email format
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  /// Validates pet name
  static String? validatePetName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Pet name is required';
    }

    if (name.length > 50) {
      return 'Pet name must be 50 characters or less';
    }

    if (name.trim().length < 2) {
      return 'Pet name must be at least 2 characters';
    }

    return null;
  }

  /// Validates display name
  static String? validateDisplayName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Display name is required';
    }

    if (name.length > 50) {
      return 'Display name must be 50 characters or less';
    }

    return null;
  }

  /// Validates currency amount
  static String? validateCurrencyAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Amount is required';
    }

    final numericAmount = int.tryParse(amount);
    if (numericAmount == null) {
      return 'Please enter a valid number';
    }

    if (numericAmount < 0) {
      return 'Amount cannot be negative';
    }

    return null;
  }

  /// Validates user age
  static String? validateAge(String? age) {
    if (age == null || age.isEmpty) {
      return 'Age is required';
    }

    final numericAge = int.tryParse(age);
    if (numericAge == null) {
      return 'Please enter a valid age';
    }

    if (numericAge < 13) {
      return 'You must be at least 13 years old';
    }

    if (numericAge > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }
}
