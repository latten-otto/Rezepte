import 'package:drift/drift.dart';

class MealPlans extends Table {
  TextColumn get id => text()();
  DateTimeColumn get weekStartDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
