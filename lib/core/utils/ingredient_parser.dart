/// Parses ingredient strings commonly found in German recipes.
///
/// Examples:
///   "200g Mehl"       → (amount: 200, unit: "g", name: "Mehl")
///   "2 EL Olivenöl"   → (amount: 2, unit: "EL", name: "Olivenöl")
///   "1/2 TL Salz"     → (amount: 0.5, unit: "TL", name: "Salz")
///   "3 Stück Eier"    → (amount: 3, unit: "Stück", name: "Eier")
///   "Salz"            → (amount: null, unit: null, name: "Salz")
///   "1,5 kg Kartoffeln" → (amount: 1.5, unit: "kg", name: "Kartoffeln")
typedef ParsedIngredient = ({double? amount, String? unit, String name});

abstract final class IngredientParser {
  /// Known German cooking units (canonical forms).
  static const _knownUnits = {
    'g',
    'kg',
    'ml',
    'l',
    'TL',
    'EL',
    'Stück',
    'Stk',
    'Prise',
    'Prisen',
    'Bund',
    'Zehe',
    'Zehen',
    'Scheibe',
    'Scheiben',
    'Dose',
    'Dosen',
    'Becher',
    'Tasse',
    'Tassen',
    'Packung',
    'Pkg',
    'Pck',
    'Tropfen',
    'Blatt',
    'Blätter',
    'Zweig',
    'Zweige',
    'Handvoll',
    'Messerspitze',
    'Msp',
  };

  /// Set of unit strings lowercased for matching.
  static final _knownUnitsLower = _knownUnits.map((u) => u.toLowerCase()).toSet();

  /// Main regular expression to parse an ingredient line.
  ///
  /// Groups:
  ///  1 – integer or decimal amount (e.g. "200", "1,5", "1.5")
  ///  2 – fraction amount (e.g. "1/2", "3/4")
  ///  3 – unit attached to number without space (e.g. "200g" captures "g")
  ///  4 – rest of the string (unit + name, or just name)
  static final _pattern = RegExp(
    r'^'
    r'(?:(\d+[.,]?\d*)\s*' // group 1: decimal number
    r'|(\d+\s*/\s*\d+)\s*)?' // group 2: fraction
    r'([a-zA-ZäöüÄÖÜß.]+)?' // group 3: unit glued to number (e.g. "200g")
    r'\s*(.*?)' // group 4: remaining text
    r'$',
  );

  /// Parses a single ingredient string and returns structured data.
  static ParsedIngredient parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return (amount: null, unit: null, name: '');
    }

    final match = _pattern.firstMatch(trimmed);
    if (match == null) {
      return (amount: null, unit: null, name: trimmed);
    }

    final numberStr = match.group(1);
    final fractionStr = match.group(2);
    final gluedUnit = match.group(3);
    final rest = (match.group(4) ?? '').trim();

    // Parse amount
    double? amount;
    if (numberStr != null && numberStr.isNotEmpty) {
      amount = _parseNumber(numberStr);
    } else if (fractionStr != null && fractionStr.isNotEmpty) {
      amount = _parseFraction(fractionStr);
    }

    // Determine unit and name
    String? unit;
    String name;

    if (gluedUnit != null && gluedUnit.isNotEmpty) {
      if (_isKnownUnit(gluedUnit)) {
        // The glued part is a unit (e.g. "200g Mehl")
        unit = gluedUnit;
        name = rest;
      } else if (amount != null) {
        // There was a number but the glued text isn't a unit
        // e.g. "3 große Tomaten" – "große" captured as gluedUnit
        name = '$gluedUnit${rest.isNotEmpty ? ' $rest' : ''}';
      } else {
        // No number at all – everything is the name
        name = '$gluedUnit${rest.isNotEmpty ? ' $rest' : ''}';
      }
    } else {
      // No glued unit – check if rest starts with a unit
      if (rest.isNotEmpty && amount != null) {
        final parts = rest.split(RegExp(r'\s+'));
        if (parts.isNotEmpty && _isKnownUnit(parts.first)) {
          unit = parts.first;
          name = parts.skip(1).join(' ');
        } else {
          name = rest;
        }
      } else {
        name = rest;
      }
    }

    // Handle mixed numbers like "1 1/2 EL Mehl" by checking if name starts
    // with a fraction when we already have a whole number.
    if (amount != null && name.isNotEmpty) {
      final mixedMatch = RegExp(r'^(\d+\s*/\s*\d+)\s+(.*)$').firstMatch(name);
      if (mixedMatch != null) {
        final fractionPart = _parseFraction(mixedMatch.group(1)!);
        if (fractionPart != null) {
          amount = amount + fractionPart;
          final afterFraction = mixedMatch.group(2)!.trim();
          // Re-check for unit
          final parts = afterFraction.split(RegExp(r'\s+'));
          if (parts.isNotEmpty && _isKnownUnit(parts.first)) {
            unit = parts.first;
            name = parts.skip(1).join(' ');
          } else {
            name = afterFraction;
          }
        }
      }
    }

    return (amount: amount, unit: unit, name: name.trim());
  }

  /// Parses a decimal number, accepting both '.' and ',' as separators.
  static double? _parseNumber(String s) {
    final normalized = s.replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Parses a fraction string like "1/2" or "3/4".
  static double? _parseFraction(String s) {
    final parts = s.split('/');
    if (parts.length != 2) return null;
    final numerator = double.tryParse(parts[0].trim());
    final denominator = double.tryParse(parts[1].trim());
    if (numerator == null || denominator == null || denominator == 0) {
      return null;
    }
    return numerator / denominator;
  }

  /// Checks whether [s] matches a known cooking unit (case-insensitive).
  static bool _isKnownUnit(String s) {
    return _knownUnitsLower.contains(s.toLowerCase());
  }
}
