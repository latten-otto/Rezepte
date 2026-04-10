/// Utility class for German cooking unit conversions.
abstract final class UnitConverter {
  /// Conversion factors: maps (fromUnit, toUnit) → factor.
  /// amount_in_toUnit = amount_in_fromUnit * factor
  static const Map<(String, String), double> _conversions = {
    ('g', 'kg'): 0.001,
    ('kg', 'g'): 1000,
    ('ml', 'l'): 0.001,
    ('l', 'ml'): 1000,
    ('TL', 'EL'): 1 / 3,
    ('EL', 'TL'): 3,
  };

  /// Normalizes common unit aliases to canonical German abbreviations.
  static String normalizeUnit(String unit) {
    final trimmed = unit.trim();
    switch (trimmed.toLowerCase()) {
      case 'gramm':
      case 'gram':
        return 'g';
      case 'kilogramm':
      case 'kilogram':
        return 'kg';
      case 'milliliter':
        return 'ml';
      case 'liter':
        return 'l';
      case 'teelöffel':
        return 'TL';
      case 'esslöffel':
        return 'EL';
      case 'stück':
      case 'stk':
      case 'stk.':
        return 'Stück';
      case 'prise':
      case 'prisen':
        return 'Prise';
      case 'bund':
        return 'Bund';
      case 'zehe':
      case 'zehen':
        return 'Zehe';
      case 'scheibe':
      case 'scheiben':
        return 'Scheibe';
      case 'dose':
      case 'dosen':
        return 'Dose';
      case 'becher':
        return 'Becher';
      case 'tasse':
      case 'tassen':
        return 'Tasse';
      case 'packung':
      case 'pkg':
      case 'pck':
        return 'Packung';
      default:
        // Preserve case for known abbreviations
        if (trimmed == 'g' ||
            trimmed == 'kg' ||
            trimmed == 'ml' ||
            trimmed == 'l' ||
            trimmed == 'TL' ||
            trimmed == 'EL') {
          return trimmed;
        }
        return trimmed;
    }
  }

  /// Returns true if a conversion exists between the two units.
  static bool canConvert(String unit1, String unit2) {
    final u1 = normalizeUnit(unit1);
    final u2 = normalizeUnit(unit2);
    if (u1 == u2) return true;
    return _conversions.containsKey((u1, u2));
  }

  /// Converts [amount] from [fromUnit] to [toUnit].
  /// Throws [ArgumentError] if no conversion path exists.
  static double convert(double amount, String fromUnit, String toUnit) {
    final from = normalizeUnit(fromUnit);
    final to = normalizeUnit(toUnit);

    if (from == to) return amount;

    final factor = _conversions[(from, to)];
    if (factor == null) {
      throw ArgumentError(
        'Keine Umrechnung möglich von "$fromUnit" nach "$toUnit".',
      );
    }
    return amount * factor;
  }

  /// Adds two amounts with potentially different (but convertible) units.
  ///
  /// Returns a record with the combined amount and the chosen unit.
  /// The result uses the "larger" unit when the total is big enough,
  /// otherwise the "smaller" unit.
  static ({double amount, String unit}) addAmounts(
    double amount1,
    String unit1,
    double amount2,
    String unit2,
  ) {
    final u1 = normalizeUnit(unit1);
    final u2 = normalizeUnit(unit2);

    // Same unit – just add
    if (u1 == u2) {
      return (amount: amount1 + amount2, unit: u1);
    }

    if (!canConvert(u1, u2)) {
      throw ArgumentError(
        'Kann "$unit1" und "$unit2" nicht zusammenrechnen.',
      );
    }

    // Convert amount2 to unit1, then decide which unit to use
    final totalInU1 = amount1 + convert(amount2, u2, u1);

    // Determine the preferred result unit: use larger unit if >= 1
    final preferLarger = _preferredLargerUnit(u1);
    if (preferLarger != null) {
      final totalInLarger = convert(totalInU1, u1, preferLarger);
      if (totalInLarger >= 1) {
        return (amount: totalInLarger, unit: preferLarger);
      }
    }

    return (amount: totalInU1, unit: u1);
  }

  /// Returns the "larger" sibling unit, or null if not applicable.
  static String? _preferredLargerUnit(String unit) {
    switch (unit) {
      case 'g':
        return 'kg';
      case 'ml':
        return 'l';
      case 'TL':
        return 'EL';
      default:
        return null;
    }
  }
}
