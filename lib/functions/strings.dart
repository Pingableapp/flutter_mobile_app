String capitalize(String string) {
  if (string == null) {
    throw ArgumentError.notNull('string');
  }

  if (string.isEmpty) {
    return string;
  }

  return string[0].toUpperCase() + string.substring(1);
}

String formatPhoneNumber(String string) {
  // Expected input '[country_code][phone_number]' (ex. '+12817034575')
  // Output example '1-281-703-4575'
  String countryCode = string.substring(1, string.length - 10);
  String firstThree = string.substring(string.length - 10, string.length - 7);
  String middleThree = string.substring(string.length - 7, string.length - 4);
  String lastFour = string.substring(string.length - 4);

  return '$countryCode-$firstThree-$middleThree-$lastFour';
}