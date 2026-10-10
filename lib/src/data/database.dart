import 'package:drift/drift.dart';

part 'database.g.dart';

class Memories extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get type => text()();

  TextColumn get exercise => text()();

  TextColumn get muscleGroup => text().nullable()();

  TextColumn get content => text()();

  TextColumn get valueJson => text()();

  RealColumn get confidence => real()();

  TextColumn get source => text()();

  TextColumn get status => text()();

  DateTimeColumn get expiresAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Memories])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
