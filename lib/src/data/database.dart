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

@DriftDatabase(tables: [Memories, WorkoutPlans, PlannedExercises, LoggedSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;
}

class WorkoutPlans extends Table {
  TextColumn get id => text()();

  TextColumn get userId => text()();

  TextColumn get title => text()();

  IntColumn get dayOfWeek => integer()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlannedExercises extends Table {
  TextColumn get id => text()();

  TextColumn get planId => text()();

  TextColumn get exercise => text()();

  TextColumn get muscleGroup => text()();

  IntColumn get sortOrder => integer()();

  IntColumn get targetSets => integer()();

  IntColumn get targetReps => integer()();

  RealColumn get initialWeight => real()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class LoggedSets extends Table {
  TextColumn get id => text()();

  TextColumn get exerciseId => text()();

  IntColumn get setIndex => integer()();

  RealColumn get weight => real()();

  IntColumn get reps => integer()();

  TextColumn get feedbackText => text().nullable()();

  DateTimeColumn get loggedAt => dateTime()();

  TextColumn get syncStatus => text()();

  @override
  Set<Column> get primaryKey => {id};
}
