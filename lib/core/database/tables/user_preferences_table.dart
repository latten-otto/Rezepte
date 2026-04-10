import 'package:drift/drift.dart';

class UserPreferencesTable extends Table {
  @override
  String get tableName => 'user_preferences';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
