// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MemoriesTable extends Memories with TableInfo<$MemoriesTable, Memory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseMeta = const VerificationMeta(
    'exercise',
  );
  @override
  late final GeneratedColumn<String> exercise = GeneratedColumn<String>(
    'exercise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueJsonMeta = const VerificationMeta(
    'valueJson',
  );
  @override
  late final GeneratedColumn<String> valueJson = GeneratedColumn<String>(
    'value_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    exercise,
    muscleGroup,
    content,
    valueJson,
    confidence,
    source,
    status,
    expiresAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Memory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('exercise')) {
      context.handle(
        _exerciseMeta,
        exercise.isAcceptableOrUnknown(data['exercise']!, _exerciseMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('value_json')) {
      context.handle(
        _valueJsonMeta,
        valueJson.isAcceptableOrUnknown(data['value_json']!, _valueJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valueJsonMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Memory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Memory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      exercise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      valueJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_json'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class Memory extends DataClass implements Insertable<Memory> {
  final String id;
  final String userId;
  final String type;
  final String exercise;
  final String? muscleGroup;
  final String content;
  final String valueJson;
  final double confidence;
  final String source;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Memory({
    required this.id,
    required this.userId,
    required this.type,
    required this.exercise,
    this.muscleGroup,
    required this.content,
    required this.valueJson,
    required this.confidence,
    required this.source,
    required this.status,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    map['exercise'] = Variable<String>(exercise);
    if (!nullToAbsent || muscleGroup != null) {
      map['muscle_group'] = Variable<String>(muscleGroup);
    }
    map['content'] = Variable<String>(content);
    map['value_json'] = Variable<String>(valueJson);
    map['confidence'] = Variable<double>(confidence);
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      exercise: Value(exercise),
      muscleGroup: muscleGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroup),
      content: Value(content),
      valueJson: Value(valueJson),
      confidence: Value(confidence),
      source: Value(source),
      status: Value(status),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Memory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Memory(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      exercise: serializer.fromJson<String>(json['exercise']),
      muscleGroup: serializer.fromJson<String?>(json['muscleGroup']),
      content: serializer.fromJson<String>(json['content']),
      valueJson: serializer.fromJson<String>(json['valueJson']),
      confidence: serializer.fromJson<double>(json['confidence']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'exercise': serializer.toJson<String>(exercise),
      'muscleGroup': serializer.toJson<String?>(muscleGroup),
      'content': serializer.toJson<String>(content),
      'valueJson': serializer.toJson<String>(valueJson),
      'confidence': serializer.toJson<double>(confidence),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Memory copyWith({
    String? id,
    String? userId,
    String? type,
    String? exercise,
    Value<String?> muscleGroup = const Value.absent(),
    String? content,
    String? valueJson,
    double? confidence,
    String? source,
    String? status,
    Value<DateTime?> expiresAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Memory(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    exercise: exercise ?? this.exercise,
    muscleGroup: muscleGroup.present ? muscleGroup.value : this.muscleGroup,
    content: content ?? this.content,
    valueJson: valueJson ?? this.valueJson,
    confidence: confidence ?? this.confidence,
    source: source ?? this.source,
    status: status ?? this.status,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Memory copyWithCompanion(MemoriesCompanion data) {
    return Memory(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      exercise: data.exercise.present ? data.exercise.value : this.exercise,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      content: data.content.present ? data.content.value : this.content,
      valueJson: data.valueJson.present ? data.valueJson.value : this.valueJson,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Memory(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('exercise: $exercise, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('content: $content, ')
          ..write('valueJson: $valueJson, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    type,
    exercise,
    muscleGroup,
    content,
    valueJson,
    confidence,
    source,
    status,
    expiresAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Memory &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.exercise == this.exercise &&
          other.muscleGroup == this.muscleGroup &&
          other.content == this.content &&
          other.valueJson == this.valueJson &&
          other.confidence == this.confidence &&
          other.source == this.source &&
          other.status == this.status &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MemoriesCompanion extends UpdateCompanion<Memory> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String> exercise;
  final Value<String?> muscleGroup;
  final Value<String> content;
  final Value<String> valueJson;
  final Value<double> confidence;
  final Value<String> source;
  final Value<String> status;
  final Value<DateTime?> expiresAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MemoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.exercise = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.content = const Value.absent(),
    this.valueJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesCompanion.insert({
    required String id,
    required String userId,
    required String type,
    required String exercise,
    this.muscleGroup = const Value.absent(),
    required String content,
    required String valueJson,
    required double confidence,
    required String source,
    required String status,
    this.expiresAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       exercise = Value(exercise),
       content = Value(content),
       valueJson = Value(valueJson),
       confidence = Value(confidence),
       source = Value(source),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Memory> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? exercise,
    Expression<String>? muscleGroup,
    Expression<String>? content,
    Expression<String>? valueJson,
    Expression<double>? confidence,
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (exercise != null) 'exercise': exercise,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (content != null) 'content': content,
      if (valueJson != null) 'value_json': valueJson,
      if (confidence != null) 'confidence': confidence,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String>? exercise,
    Value<String?>? muscleGroup,
    Value<String>? content,
    Value<String>? valueJson,
    Value<double>? confidence,
    Value<String>? source,
    Value<String>? status,
    Value<DateTime?>? expiresAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MemoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      exercise: exercise ?? this.exercise,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      content: content ?? this.content,
      valueJson: valueJson ?? this.valueJson,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (exercise.present) {
      map['exercise'] = Variable<String>(exercise.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (valueJson.present) {
      map['value_json'] = Variable<String>(valueJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('exercise: $exercise, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('content: $content, ')
          ..write('valueJson: $valueJson, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutPlansTable extends WorkoutPlans
    with TableInfo<$WorkoutPlansTable, WorkoutPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledDateMeta = const VerificationMeta(
    'scheduledDate',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledDate =
      GeneratedColumn<DateTime>(
        'scheduled_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    dayOfWeek,
    createdAt,
    syncStatus,
    scheduledDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('scheduled_date')) {
      context.handle(
        _scheduledDateMeta,
        scheduledDate.isAcceptableOrUnknown(
          data['scheduled_date']!,
          _scheduledDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      scheduledDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_date'],
      ),
    );
  }

  @override
  $WorkoutPlansTable createAlias(String alias) {
    return $WorkoutPlansTable(attachedDatabase, alias);
  }
}

class WorkoutPlan extends DataClass implements Insertable<WorkoutPlan> {
  final String id;
  final String userId;
  final String title;
  final int dayOfWeek;
  final DateTime createdAt;
  final String syncStatus;
  final DateTime? scheduledDate;
  const WorkoutPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.dayOfWeek,
    required this.createdAt,
    required this.syncStatus,
    this.scheduledDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || scheduledDate != null) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate);
    }
    return map;
  }

  WorkoutPlansCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlansCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      dayOfWeek: Value(dayOfWeek),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      scheduledDate: scheduledDate == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledDate),
    );
  }

  factory WorkoutPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlan(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      scheduledDate: serializer.fromJson<DateTime?>(json['scheduledDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'scheduledDate': serializer.toJson<DateTime?>(scheduledDate),
    };
  }

  WorkoutPlan copyWith({
    String? id,
    String? userId,
    String? title,
    int? dayOfWeek,
    DateTime? createdAt,
    String? syncStatus,
    Value<DateTime?> scheduledDate = const Value.absent(),
  }) => WorkoutPlan(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    createdAt: createdAt ?? this.createdAt,
    syncStatus: syncStatus ?? this.syncStatus,
    scheduledDate: scheduledDate.present
        ? scheduledDate.value
        : this.scheduledDate,
  );
  WorkoutPlan copyWithCompanion(WorkoutPlansCompanion data) {
    return WorkoutPlan(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      scheduledDate: data.scheduledDate.present
          ? data.scheduledDate.value
          : this.scheduledDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlan(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('scheduledDate: $scheduledDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    title,
    dayOfWeek,
    createdAt,
    syncStatus,
    scheduledDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlan &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.dayOfWeek == this.dayOfWeek &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.scheduledDate == this.scheduledDate);
}

class WorkoutPlansCompanion extends UpdateCompanion<WorkoutPlan> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<int> dayOfWeek;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<DateTime?> scheduledDate;
  final Value<int> rowid;
  const WorkoutPlansCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.scheduledDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutPlansCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required int dayOfWeek,
    required DateTime createdAt,
    required String syncStatus,
    this.scheduledDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       dayOfWeek = Value(dayOfWeek),
       createdAt = Value(createdAt),
       syncStatus = Value(syncStatus);
  static Insertable<WorkoutPlan> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<int>? dayOfWeek,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? scheduledDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (scheduledDate != null) 'scheduled_date': scheduledDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutPlansCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<int>? dayOfWeek,
    Value<DateTime>? createdAt,
    Value<String>? syncStatus,
    Value<DateTime?>? scheduledDate,
    Value<int>? rowid,
  }) {
    return WorkoutPlansCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (scheduledDate.present) {
      map['scheduled_date'] = Variable<DateTime>(scheduledDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlansCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('scheduledDate: $scheduledDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedExercisesTable extends PlannedExercises
    with TableInfo<$PlannedExercisesTable, PlannedExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseMeta = const VerificationMeta(
    'exercise',
  );
  @override
  late final GeneratedColumn<String> exercise = GeneratedColumn<String>(
    'exercise',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _muscleGroupMeta = const VerificationMeta(
    'muscleGroup',
  );
  @override
  late final GeneratedColumn<String> muscleGroup = GeneratedColumn<String>(
    'muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialWeightMeta = const VerificationMeta(
    'initialWeight',
  );
  @override
  late final GeneratedColumn<double> initialWeight = GeneratedColumn<double>(
    'initial_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planId,
    exercise,
    muscleGroup,
    sortOrder,
    targetSets,
    targetReps,
    initialWeight,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('exercise')) {
      context.handle(
        _exerciseMeta,
        exercise.isAcceptableOrUnknown(data['exercise']!, _exerciseMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseMeta);
    }
    if (data.containsKey('muscle_group')) {
      context.handle(
        _muscleGroupMeta,
        muscleGroup.isAcceptableOrUnknown(
          data['muscle_group']!,
          _muscleGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSetsMeta);
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetRepsMeta);
    }
    if (data.containsKey('initial_weight')) {
      context.handle(
        _initialWeightMeta,
        initialWeight.isAcceptableOrUnknown(
          data['initial_weight']!,
          _initialWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialWeightMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      exercise: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise'],
      )!,
      muscleGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_group'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      )!,
      initialWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_weight'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $PlannedExercisesTable createAlias(String alias) {
    return $PlannedExercisesTable(attachedDatabase, alias);
  }
}

class PlannedExercise extends DataClass implements Insertable<PlannedExercise> {
  final String id;
  final String planId;
  final String exercise;
  final String muscleGroup;
  final int sortOrder;
  final int targetSets;
  final int targetReps;
  final double initialWeight;
  final String syncStatus;
  const PlannedExercise({
    required this.id,
    required this.planId,
    required this.exercise,
    required this.muscleGroup,
    required this.sortOrder,
    required this.targetSets,
    required this.targetReps,
    required this.initialWeight,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['exercise'] = Variable<String>(exercise);
    map['muscle_group'] = Variable<String>(muscleGroup);
    map['sort_order'] = Variable<int>(sortOrder);
    map['target_sets'] = Variable<int>(targetSets);
    map['target_reps'] = Variable<int>(targetReps);
    map['initial_weight'] = Variable<double>(initialWeight);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  PlannedExercisesCompanion toCompanion(bool nullToAbsent) {
    return PlannedExercisesCompanion(
      id: Value(id),
      planId: Value(planId),
      exercise: Value(exercise),
      muscleGroup: Value(muscleGroup),
      sortOrder: Value(sortOrder),
      targetSets: Value(targetSets),
      targetReps: Value(targetReps),
      initialWeight: Value(initialWeight),
      syncStatus: Value(syncStatus),
    );
  }

  factory PlannedExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedExercise(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      exercise: serializer.fromJson<String>(json['exercise']),
      muscleGroup: serializer.fromJson<String>(json['muscleGroup']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetReps: serializer.fromJson<int>(json['targetReps']),
      initialWeight: serializer.fromJson<double>(json['initialWeight']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'exercise': serializer.toJson<String>(exercise),
      'muscleGroup': serializer.toJson<String>(muscleGroup),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetReps': serializer.toJson<int>(targetReps),
      'initialWeight': serializer.toJson<double>(initialWeight),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  PlannedExercise copyWith({
    String? id,
    String? planId,
    String? exercise,
    String? muscleGroup,
    int? sortOrder,
    int? targetSets,
    int? targetReps,
    double? initialWeight,
    String? syncStatus,
  }) => PlannedExercise(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    exercise: exercise ?? this.exercise,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    sortOrder: sortOrder ?? this.sortOrder,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    initialWeight: initialWeight ?? this.initialWeight,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  PlannedExercise copyWithCompanion(PlannedExercisesCompanion data) {
    return PlannedExercise(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      exercise: data.exercise.present ? data.exercise.value : this.exercise,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      initialWeight: data.initialWeight.present
          ? data.initialWeight.value
          : this.initialWeight,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedExercise(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('exercise: $exercise, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('initialWeight: $initialWeight, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planId,
    exercise,
    muscleGroup,
    sortOrder,
    targetSets,
    targetReps,
    initialWeight,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedExercise &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.exercise == this.exercise &&
          other.muscleGroup == this.muscleGroup &&
          other.sortOrder == this.sortOrder &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps &&
          other.initialWeight == this.initialWeight &&
          other.syncStatus == this.syncStatus);
}

class PlannedExercisesCompanion extends UpdateCompanion<PlannedExercise> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> exercise;
  final Value<String> muscleGroup;
  final Value<int> sortOrder;
  final Value<int> targetSets;
  final Value<int> targetReps;
  final Value<double> initialWeight;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const PlannedExercisesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.exercise = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.initialWeight = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlannedExercisesCompanion.insert({
    required String id,
    required String planId,
    required String exercise,
    required String muscleGroup,
    required int sortOrder,
    required int targetSets,
    required int targetReps,
    required double initialWeight,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       exercise = Value(exercise),
       muscleGroup = Value(muscleGroup),
       sortOrder = Value(sortOrder),
       targetSets = Value(targetSets),
       targetReps = Value(targetReps),
       initialWeight = Value(initialWeight),
       syncStatus = Value(syncStatus);
  static Insertable<PlannedExercise> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? exercise,
    Expression<String>? muscleGroup,
    Expression<int>? sortOrder,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<double>? initialWeight,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (exercise != null) 'exercise': exercise,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (initialWeight != null) 'initial_weight': initialWeight,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlannedExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<String>? exercise,
    Value<String>? muscleGroup,
    Value<int>? sortOrder,
    Value<int>? targetSets,
    Value<int>? targetReps,
    Value<double>? initialWeight,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return PlannedExercisesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      exercise: exercise ?? this.exercise,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sortOrder: sortOrder ?? this.sortOrder,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      initialWeight: initialWeight ?? this.initialWeight,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (exercise.present) {
      map['exercise'] = Variable<String>(exercise.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(muscleGroup.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (initialWeight.present) {
      map['initial_weight'] = Variable<double>(initialWeight.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedExercisesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('exercise: $exercise, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('initialWeight: $initialWeight, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoggedSetsTable extends LoggedSets
    with TableInfo<$LoggedSetsTable, LoggedSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoggedSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIndexMeta = const VerificationMeta(
    'setIndex',
  );
  @override
  late final GeneratedColumn<int> setIndex = GeneratedColumn<int>(
    'set_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedbackTextMeta = const VerificationMeta(
    'feedbackText',
  );
  @override
  late final GeneratedColumn<String> feedbackText = GeneratedColumn<String>(
    'feedback_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    setIndex,
    weight,
    reps,
    feedbackText,
    loggedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logged_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoggedSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('set_index')) {
      context.handle(
        _setIndexMeta,
        setIndex.isAcceptableOrUnknown(data['set_index']!, _setIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_setIndexMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('feedback_text')) {
      context.handle(
        _feedbackTextMeta,
        feedbackText.isAcceptableOrUnknown(
          data['feedback_text']!,
          _feedbackTextMeta,
        ),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoggedSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoggedSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      setIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_index'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      feedbackText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feedback_text'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $LoggedSetsTable createAlias(String alias) {
    return $LoggedSetsTable(attachedDatabase, alias);
  }
}

class LoggedSet extends DataClass implements Insertable<LoggedSet> {
  final String id;
  final String exerciseId;
  final int setIndex;
  final double weight;
  final int reps;
  final String? feedbackText;
  final DateTime loggedAt;
  final String syncStatus;
  const LoggedSet({
    required this.id,
    required this.exerciseId,
    required this.setIndex,
    required this.weight,
    required this.reps,
    this.feedbackText,
    required this.loggedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['set_index'] = Variable<int>(setIndex);
    map['weight'] = Variable<double>(weight);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || feedbackText != null) {
      map['feedback_text'] = Variable<String>(feedbackText);
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  LoggedSetsCompanion toCompanion(bool nullToAbsent) {
    return LoggedSetsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      setIndex: Value(setIndex),
      weight: Value(weight),
      reps: Value(reps),
      feedbackText: feedbackText == null && nullToAbsent
          ? const Value.absent()
          : Value(feedbackText),
      loggedAt: Value(loggedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory LoggedSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoggedSet(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      setIndex: serializer.fromJson<int>(json['setIndex']),
      weight: serializer.fromJson<double>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      feedbackText: serializer.fromJson<String?>(json['feedbackText']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'setIndex': serializer.toJson<int>(setIndex),
      'weight': serializer.toJson<double>(weight),
      'reps': serializer.toJson<int>(reps),
      'feedbackText': serializer.toJson<String?>(feedbackText),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  LoggedSet copyWith({
    String? id,
    String? exerciseId,
    int? setIndex,
    double? weight,
    int? reps,
    Value<String?> feedbackText = const Value.absent(),
    DateTime? loggedAt,
    String? syncStatus,
  }) => LoggedSet(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    setIndex: setIndex ?? this.setIndex,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    feedbackText: feedbackText.present ? feedbackText.value : this.feedbackText,
    loggedAt: loggedAt ?? this.loggedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  LoggedSet copyWithCompanion(LoggedSetsCompanion data) {
    return LoggedSet(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      setIndex: data.setIndex.present ? data.setIndex.value : this.setIndex,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      feedbackText: data.feedbackText.present
          ? data.feedbackText.value
          : this.feedbackText,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoggedSet(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('feedbackText: $feedbackText, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    setIndex,
    weight,
    reps,
    feedbackText,
    loggedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoggedSet &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.setIndex == this.setIndex &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.feedbackText == this.feedbackText &&
          other.loggedAt == this.loggedAt &&
          other.syncStatus == this.syncStatus);
}

class LoggedSetsCompanion extends UpdateCompanion<LoggedSet> {
  final Value<String> id;
  final Value<String> exerciseId;
  final Value<int> setIndex;
  final Value<double> weight;
  final Value<int> reps;
  final Value<String?> feedbackText;
  final Value<DateTime> loggedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const LoggedSetsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.setIndex = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.feedbackText = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoggedSetsCompanion.insert({
    required String id,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int reps,
    this.feedbackText = const Value.absent(),
    required DateTime loggedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       setIndex = Value(setIndex),
       weight = Value(weight),
       reps = Value(reps),
       loggedAt = Value(loggedAt),
       syncStatus = Value(syncStatus);
  static Insertable<LoggedSet> custom({
    Expression<String>? id,
    Expression<String>? exerciseId,
    Expression<int>? setIndex,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<String>? feedbackText,
    Expression<DateTime>? loggedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (setIndex != null) 'set_index': setIndex,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (feedbackText != null) 'feedback_text': feedbackText,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoggedSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? exerciseId,
    Value<int>? setIndex,
    Value<double>? weight,
    Value<int>? reps,
    Value<String?>? feedbackText,
    Value<DateTime>? loggedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return LoggedSetsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setIndex: setIndex ?? this.setIndex,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      feedbackText: feedbackText ?? this.feedbackText,
      loggedAt: loggedAt ?? this.loggedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (setIndex.present) {
      map['set_index'] = Variable<int>(setIndex.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (feedbackText.present) {
      map['feedback_text'] = Variable<String>(feedbackText.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoggedSetsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setIndex: $setIndex, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('feedbackText: $feedbackText, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseProgressCachesTable extends ExerciseProgressCaches
    with TableInfo<$ExerciseProgressCachesTable, ExerciseProgressCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseProgressCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastTrainedDateMeta = const VerificationMeta(
    'lastTrainedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastTrainedDate =
      GeneratedColumn<DateTime>(
        'last_trained_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _topWeightMeta = const VerificationMeta(
    'topWeight',
  );
  @override
  late final GeneratedColumn<double> topWeight = GeneratedColumn<double>(
    'top_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topRepsMeta = const VerificationMeta(
    'topReps',
  );
  @override
  late final GeneratedColumn<int> topReps = GeneratedColumn<int>(
    'top_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSetsMeta = const VerificationMeta(
    'totalSets',
  );
  @override
  late final GeneratedColumn<int> totalSets = GeneratedColumn<int>(
    'total_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    exerciseName,
    lastTrainedDate,
    topWeight,
    topReps,
    totalSets,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_progress_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseProgressCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('last_trained_date')) {
      context.handle(
        _lastTrainedDateMeta,
        lastTrainedDate.isAcceptableOrUnknown(
          data['last_trained_date']!,
          _lastTrainedDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastTrainedDateMeta);
    }
    if (data.containsKey('top_weight')) {
      context.handle(
        _topWeightMeta,
        topWeight.isAcceptableOrUnknown(data['top_weight']!, _topWeightMeta),
      );
    } else if (isInserting) {
      context.missing(_topWeightMeta);
    }
    if (data.containsKey('top_reps')) {
      context.handle(
        _topRepsMeta,
        topReps.isAcceptableOrUnknown(data['top_reps']!, _topRepsMeta),
      );
    } else if (isInserting) {
      context.missing(_topRepsMeta);
    }
    if (data.containsKey('total_sets')) {
      context.handle(
        _totalSetsMeta,
        totalSets.isAcceptableOrUnknown(data['total_sets']!, _totalSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalSetsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, exerciseName};
  @override
  ExerciseProgressCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseProgressCache(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      lastTrainedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_trained_date'],
      )!,
      topWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}top_weight'],
      )!,
      topReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}top_reps'],
      )!,
      totalSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sets'],
      )!,
    );
  }

  @override
  $ExerciseProgressCachesTable createAlias(String alias) {
    return $ExerciseProgressCachesTable(attachedDatabase, alias);
  }
}

class ExerciseProgressCache extends DataClass
    implements Insertable<ExerciseProgressCache> {
  final String userId;
  final String exerciseName;
  final DateTime lastTrainedDate;
  final double topWeight;
  final int topReps;
  final int totalSets;
  const ExerciseProgressCache({
    required this.userId,
    required this.exerciseName,
    required this.lastTrainedDate,
    required this.topWeight,
    required this.topReps,
    required this.totalSets,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['last_trained_date'] = Variable<DateTime>(lastTrainedDate);
    map['top_weight'] = Variable<double>(topWeight);
    map['top_reps'] = Variable<int>(topReps);
    map['total_sets'] = Variable<int>(totalSets);
    return map;
  }

  ExerciseProgressCachesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseProgressCachesCompanion(
      userId: Value(userId),
      exerciseName: Value(exerciseName),
      lastTrainedDate: Value(lastTrainedDate),
      topWeight: Value(topWeight),
      topReps: Value(topReps),
      totalSets: Value(totalSets),
    );
  }

  factory ExerciseProgressCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseProgressCache(
      userId: serializer.fromJson<String>(json['userId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      lastTrainedDate: serializer.fromJson<DateTime>(json['lastTrainedDate']),
      topWeight: serializer.fromJson<double>(json['topWeight']),
      topReps: serializer.fromJson<int>(json['topReps']),
      totalSets: serializer.fromJson<int>(json['totalSets']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'lastTrainedDate': serializer.toJson<DateTime>(lastTrainedDate),
      'topWeight': serializer.toJson<double>(topWeight),
      'topReps': serializer.toJson<int>(topReps),
      'totalSets': serializer.toJson<int>(totalSets),
    };
  }

  ExerciseProgressCache copyWith({
    String? userId,
    String? exerciseName,
    DateTime? lastTrainedDate,
    double? topWeight,
    int? topReps,
    int? totalSets,
  }) => ExerciseProgressCache(
    userId: userId ?? this.userId,
    exerciseName: exerciseName ?? this.exerciseName,
    lastTrainedDate: lastTrainedDate ?? this.lastTrainedDate,
    topWeight: topWeight ?? this.topWeight,
    topReps: topReps ?? this.topReps,
    totalSets: totalSets ?? this.totalSets,
  );
  ExerciseProgressCache copyWithCompanion(
    ExerciseProgressCachesCompanion data,
  ) {
    return ExerciseProgressCache(
      userId: data.userId.present ? data.userId.value : this.userId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      lastTrainedDate: data.lastTrainedDate.present
          ? data.lastTrainedDate.value
          : this.lastTrainedDate,
      topWeight: data.topWeight.present ? data.topWeight.value : this.topWeight,
      topReps: data.topReps.present ? data.topReps.value : this.topReps,
      totalSets: data.totalSets.present ? data.totalSets.value : this.totalSets,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseProgressCache(')
          ..write('userId: $userId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('lastTrainedDate: $lastTrainedDate, ')
          ..write('topWeight: $topWeight, ')
          ..write('topReps: $topReps, ')
          ..write('totalSets: $totalSets')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    exerciseName,
    lastTrainedDate,
    topWeight,
    topReps,
    totalSets,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseProgressCache &&
          other.userId == this.userId &&
          other.exerciseName == this.exerciseName &&
          other.lastTrainedDate == this.lastTrainedDate &&
          other.topWeight == this.topWeight &&
          other.topReps == this.topReps &&
          other.totalSets == this.totalSets);
}

class ExerciseProgressCachesCompanion
    extends UpdateCompanion<ExerciseProgressCache> {
  final Value<String> userId;
  final Value<String> exerciseName;
  final Value<DateTime> lastTrainedDate;
  final Value<double> topWeight;
  final Value<int> topReps;
  final Value<int> totalSets;
  final Value<int> rowid;
  const ExerciseProgressCachesCompanion({
    this.userId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.lastTrainedDate = const Value.absent(),
    this.topWeight = const Value.absent(),
    this.topReps = const Value.absent(),
    this.totalSets = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseProgressCachesCompanion.insert({
    required String userId,
    required String exerciseName,
    required DateTime lastTrainedDate,
    required double topWeight,
    required int topReps,
    required int totalSets,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       exerciseName = Value(exerciseName),
       lastTrainedDate = Value(lastTrainedDate),
       topWeight = Value(topWeight),
       topReps = Value(topReps),
       totalSets = Value(totalSets);
  static Insertable<ExerciseProgressCache> custom({
    Expression<String>? userId,
    Expression<String>? exerciseName,
    Expression<DateTime>? lastTrainedDate,
    Expression<double>? topWeight,
    Expression<int>? topReps,
    Expression<int>? totalSets,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (lastTrainedDate != null) 'last_trained_date': lastTrainedDate,
      if (topWeight != null) 'top_weight': topWeight,
      if (topReps != null) 'top_reps': topReps,
      if (totalSets != null) 'total_sets': totalSets,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseProgressCachesCompanion copyWith({
    Value<String>? userId,
    Value<String>? exerciseName,
    Value<DateTime>? lastTrainedDate,
    Value<double>? topWeight,
    Value<int>? topReps,
    Value<int>? totalSets,
    Value<int>? rowid,
  }) {
    return ExerciseProgressCachesCompanion(
      userId: userId ?? this.userId,
      exerciseName: exerciseName ?? this.exerciseName,
      lastTrainedDate: lastTrainedDate ?? this.lastTrainedDate,
      topWeight: topWeight ?? this.topWeight,
      topReps: topReps ?? this.topReps,
      totalSets: totalSets ?? this.totalSets,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (lastTrainedDate.present) {
      map['last_trained_date'] = Variable<DateTime>(lastTrainedDate.value);
    }
    if (topWeight.present) {
      map['top_weight'] = Variable<double>(topWeight.value);
    }
    if (topReps.present) {
      map['top_reps'] = Variable<int>(topReps.value);
    }
    if (totalSets.present) {
      map['total_sets'] = Variable<int>(totalSets.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseProgressCachesCompanion(')
          ..write('userId: $userId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('lastTrainedDate: $lastTrainedDate, ')
          ..write('topWeight: $topWeight, ')
          ..write('topReps: $topReps, ')
          ..write('totalSets: $totalSets, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiSuggestionCachesTable extends AiSuggestionCaches
    with TableInfo<$AiSuggestionCachesTable, AiSuggestionCache> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiSuggestionCachesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, jsonData, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_suggestion_caches';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiSuggestionCache> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  AiSuggestionCache map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiSuggestionCache(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AiSuggestionCachesTable createAlias(String alias) {
    return $AiSuggestionCachesTable(attachedDatabase, alias);
  }
}

class AiSuggestionCache extends DataClass
    implements Insertable<AiSuggestionCache> {
  final String cacheKey;
  final String jsonData;
  final DateTime createdAt;
  const AiSuggestionCache({
    required this.cacheKey,
    required this.jsonData,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['json_data'] = Variable<String>(jsonData);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AiSuggestionCachesCompanion toCompanion(bool nullToAbsent) {
    return AiSuggestionCachesCompanion(
      cacheKey: Value(cacheKey),
      jsonData: Value(jsonData),
      createdAt: Value(createdAt),
    );
  }

  factory AiSuggestionCache.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiSuggestionCache(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'jsonData': serializer.toJson<String>(jsonData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AiSuggestionCache copyWith({
    String? cacheKey,
    String? jsonData,
    DateTime? createdAt,
  }) => AiSuggestionCache(
    cacheKey: cacheKey ?? this.cacheKey,
    jsonData: jsonData ?? this.jsonData,
    createdAt: createdAt ?? this.createdAt,
  );
  AiSuggestionCache copyWithCompanion(AiSuggestionCachesCompanion data) {
    return AiSuggestionCache(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiSuggestionCache(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonData: $jsonData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, jsonData, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiSuggestionCache &&
          other.cacheKey == this.cacheKey &&
          other.jsonData == this.jsonData &&
          other.createdAt == this.createdAt);
}

class AiSuggestionCachesCompanion extends UpdateCompanion<AiSuggestionCache> {
  final Value<String> cacheKey;
  final Value<String> jsonData;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AiSuggestionCachesCompanion({
    this.cacheKey = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiSuggestionCachesCompanion.insert({
    required String cacheKey,
    required String jsonData,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       jsonData = Value(jsonData),
       createdAt = Value(createdAt);
  static Insertable<AiSuggestionCache> custom({
    Expression<String>? cacheKey,
    Expression<String>? jsonData,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (jsonData != null) 'json_data': jsonData,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiSuggestionCachesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? jsonData,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AiSuggestionCachesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      jsonData: jsonData ?? this.jsonData,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiSuggestionCachesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('jsonData: $jsonData, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $WorkoutPlansTable workoutPlans = $WorkoutPlansTable(this);
  late final $PlannedExercisesTable plannedExercises = $PlannedExercisesTable(
    this,
  );
  late final $LoggedSetsTable loggedSets = $LoggedSetsTable(this);
  late final $ExerciseProgressCachesTable exerciseProgressCaches =
      $ExerciseProgressCachesTable(this);
  late final $AiSuggestionCachesTable aiSuggestionCaches =
      $AiSuggestionCachesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    memories,
    workoutPlans,
    plannedExercises,
    loggedSets,
    exerciseProgressCaches,
    aiSuggestionCaches,
  ];
}

typedef $$MemoriesTableCreateCompanionBuilder = MemoriesCompanion Function({
  required String id,
  required String userId,
  required String type,
  required String exercise,
  Value<String?> muscleGroup,
  required String content,
  required String valueJson,
  required double confidence,
  required String source,
  required String status,
  Value<DateTime?> expiresAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MemoriesTableUpdateCompanionBuilder = MemoriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> type,
  Value<String> exercise,
  Value<String?> muscleGroup,
  Value<String> content,
  Value<String> valueJson,
  Value<double> confidence,
  Value<String> source,
  Value<String> status,
  Value<DateTime?> expiresAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueJson => $composableBuilder(
    column: $table.valueJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get exercise =>
      $composableBuilder(column: $table.exercise, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get valueJson =>
      $composableBuilder(column: $table.valueJson, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoriesTable,
          Memory,
          $$MemoriesTableFilterComposer,
          $$MemoriesTableOrderingComposer,
          $$MemoriesTableAnnotationComposer,
          $$MemoriesTableCreateCompanionBuilder,
          $$MemoriesTableUpdateCompanionBuilder,
          (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
          Memory,
          PrefetchHooks Function()
        > {
  $$MemoriesTableTableManager(_$AppDatabase db, $MemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> exercise = const Value.absent(),
                Value<String?> muscleGroup = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> valueJson = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion(
                id: id,
                userId: userId,
                type: type,
                exercise: exercise,
                muscleGroup: muscleGroup,
                content: content,
                valueJson: valueJson,
                confidence: confidence,
                source: source,
                status: status,
                expiresAt: expiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String type,
                required String exercise,
                Value<String?> muscleGroup = const Value.absent(),
                required String content,
                required String valueJson,
                required double confidence,
                required String source,
                required String status,
                Value<DateTime?> expiresAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                exercise: exercise,
                muscleGroup: muscleGroup,
                content: content,
                valueJson: valueJson,
                confidence: confidence,
                source: source,
                status: status,
                expiresAt: expiresAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoriesTable, Memory>(table),
                  BaseReferences<_$AppDatabase, $MemoriesTable, Memory>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoriesTable,
      Memory,
      $$MemoriesTableFilterComposer,
      $$MemoriesTableOrderingComposer,
      $$MemoriesTableAnnotationComposer,
      $$MemoriesTableCreateCompanionBuilder,
      $$MemoriesTableUpdateCompanionBuilder,
      (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
      Memory,
      PrefetchHooks Function()
    >;
typedef $$WorkoutPlansTableCreateCompanionBuilder =
    WorkoutPlansCompanion Function({
      required String id,
      required String userId,
      required String title,
      required int dayOfWeek,
      required DateTime createdAt,
      required String syncStatus,
      Value<DateTime?> scheduledDate,
      Value<int> rowid,
    });
typedef $$WorkoutPlansTableUpdateCompanionBuilder =
    WorkoutPlansCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<int> dayOfWeek,
      Value<DateTime> createdAt,
      Value<String> syncStatus,
      Value<DateTime?> scheduledDate,
      Value<int> rowid,
    });

class $$WorkoutPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledDate => $composableBuilder(
    column: $table.scheduledDate,
    builder: (column) => column,
  );
}

class $$WorkoutPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlansTable,
          WorkoutPlan,
          $$WorkoutPlansTableFilterComposer,
          $$WorkoutPlansTableOrderingComposer,
          $$WorkoutPlansTableAnnotationComposer,
          $$WorkoutPlansTableCreateCompanionBuilder,
          $$WorkoutPlansTableUpdateCompanionBuilder,
          (
            WorkoutPlan,
            BaseReferences<_$AppDatabase, $WorkoutPlansTable, WorkoutPlan>,
          ),
          WorkoutPlan,
          PrefetchHooks Function()
        > {
  $$WorkoutPlansTableTableManager(_$AppDatabase db, $WorkoutPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlansCompanion(
                id: id,
                userId: userId,
                title: title,
                dayOfWeek: dayOfWeek,
                createdAt: createdAt,
                syncStatus: syncStatus,
                scheduledDate: scheduledDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                required int dayOfWeek,
                required DateTime createdAt,
                required String syncStatus,
                Value<DateTime?> scheduledDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlansCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                dayOfWeek: dayOfWeek,
                createdAt: createdAt,
                syncStatus: syncStatus,
                scheduledDate: scheduledDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlansTable, WorkoutPlan>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutPlansTable,
                    WorkoutPlan
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlansTable,
      WorkoutPlan,
      $$WorkoutPlansTableFilterComposer,
      $$WorkoutPlansTableOrderingComposer,
      $$WorkoutPlansTableAnnotationComposer,
      $$WorkoutPlansTableCreateCompanionBuilder,
      $$WorkoutPlansTableUpdateCompanionBuilder,
      (
        WorkoutPlan,
        BaseReferences<_$AppDatabase, $WorkoutPlansTable, WorkoutPlan>,
      ),
      WorkoutPlan,
      PrefetchHooks Function()
    >;
typedef $$PlannedExercisesTableCreateCompanionBuilder =
    PlannedExercisesCompanion Function({
      required String id,
      required String planId,
      required String exercise,
      required String muscleGroup,
      required int sortOrder,
      required int targetSets,
      required int targetReps,
      required double initialWeight,
      required String syncStatus,
      Value<int> rowid,
    });
typedef $$PlannedExercisesTableUpdateCompanionBuilder =
    PlannedExercisesCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<String> exercise,
      Value<String> muscleGroup,
      Value<int> sortOrder,
      Value<int> targetSets,
      Value<int> targetReps,
      Value<double> initialWeight,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$PlannedExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $PlannedExercisesTable> {
  $$PlannedExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialWeight => $composableBuilder(
    column: $table.initialWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlannedExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlannedExercisesTable> {
  $$PlannedExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exercise => $composableBuilder(
    column: $table.exercise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialWeight => $composableBuilder(
    column: $table.initialWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlannedExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlannedExercisesTable> {
  $$PlannedExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get exercise =>
      $composableBuilder(column: $table.exercise, builder: (column) => column);

  GeneratedColumn<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get initialWeight => $composableBuilder(
    column: $table.initialWeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$PlannedExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlannedExercisesTable,
          PlannedExercise,
          $$PlannedExercisesTableFilterComposer,
          $$PlannedExercisesTableOrderingComposer,
          $$PlannedExercisesTableAnnotationComposer,
          $$PlannedExercisesTableCreateCompanionBuilder,
          $$PlannedExercisesTableUpdateCompanionBuilder,
          (
            PlannedExercise,
            BaseReferences<
              _$AppDatabase,
              $PlannedExercisesTable,
              PlannedExercise
            >,
          ),
          PlannedExercise,
          PrefetchHooks Function()
        > {
  $$PlannedExercisesTableTableManager(
    _$AppDatabase db,
    $PlannedExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<String> exercise = const Value.absent(),
                Value<String> muscleGroup = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> targetReps = const Value.absent(),
                Value<double> initialWeight = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlannedExercisesCompanion(
                id: id,
                planId: planId,
                exercise: exercise,
                muscleGroup: muscleGroup,
                sortOrder: sortOrder,
                targetSets: targetSets,
                targetReps: targetReps,
                initialWeight: initialWeight,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required String exercise,
                required String muscleGroup,
                required int sortOrder,
                required int targetSets,
                required int targetReps,
                required double initialWeight,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => PlannedExercisesCompanion.insert(
                id: id,
                planId: planId,
                exercise: exercise,
                muscleGroup: muscleGroup,
                sortOrder: sortOrder,
                targetSets: targetSets,
                targetReps: targetReps,
                initialWeight: initialWeight,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlannedExercisesTable, PlannedExercise>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlannedExercisesTable,
                    PlannedExercise
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlannedExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlannedExercisesTable,
      PlannedExercise,
      $$PlannedExercisesTableFilterComposer,
      $$PlannedExercisesTableOrderingComposer,
      $$PlannedExercisesTableAnnotationComposer,
      $$PlannedExercisesTableCreateCompanionBuilder,
      $$PlannedExercisesTableUpdateCompanionBuilder,
      (
        PlannedExercise,
        BaseReferences<_$AppDatabase, $PlannedExercisesTable, PlannedExercise>,
      ),
      PlannedExercise,
      PrefetchHooks Function()
    >;
typedef $$LoggedSetsTableCreateCompanionBuilder = LoggedSetsCompanion Function({
  required String id,
  required String exerciseId,
  required int setIndex,
  required double weight,
  required int reps,
  Value<String?> feedbackText,
  required DateTime loggedAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$LoggedSetsTableUpdateCompanionBuilder = LoggedSetsCompanion Function({
  Value<String> id,
  Value<String> exerciseId,
  Value<int> setIndex,
  Value<double> weight,
  Value<int> reps,
  Value<String?> feedbackText,
  Value<DateTime> loggedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$LoggedSetsTableFilterComposer
    extends Composer<_$AppDatabase, $LoggedSetsTable> {
  $$LoggedSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedbackText => $composableBuilder(
    column: $table.feedbackText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoggedSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LoggedSetsTable> {
  $$LoggedSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setIndex => $composableBuilder(
    column: $table.setIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedbackText => $composableBuilder(
    column: $table.feedbackText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoggedSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoggedSetsTable> {
  $$LoggedSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setIndex =>
      $composableBuilder(column: $table.setIndex, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<String> get feedbackText => $composableBuilder(
    column: $table.feedbackText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$LoggedSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoggedSetsTable,
          LoggedSet,
          $$LoggedSetsTableFilterComposer,
          $$LoggedSetsTableOrderingComposer,
          $$LoggedSetsTableAnnotationComposer,
          $$LoggedSetsTableCreateCompanionBuilder,
          $$LoggedSetsTableUpdateCompanionBuilder,
          (
            LoggedSet,
            BaseReferences<_$AppDatabase, $LoggedSetsTable, LoggedSet>,
          ),
          LoggedSet,
          PrefetchHooks Function()
        > {
  $$LoggedSetsTableTableManager(_$AppDatabase db, $LoggedSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoggedSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoggedSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoggedSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> setIndex = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<String?> feedbackText = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoggedSetsCompanion(
                id: id,
                exerciseId: exerciseId,
                setIndex: setIndex,
                weight: weight,
                reps: reps,
                feedbackText: feedbackText,
                loggedAt: loggedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String exerciseId,
                required int setIndex,
                required double weight,
                required int reps,
                Value<String?> feedbackText = const Value.absent(),
                required DateTime loggedAt,
                required String syncStatus,
                Value<int> rowid = const Value.absent(),
              }) => LoggedSetsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                setIndex: setIndex,
                weight: weight,
                reps: reps,
                feedbackText: feedbackText,
                loggedAt: loggedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoggedSetsTable, LoggedSet>(table),
                  BaseReferences<_$AppDatabase, $LoggedSetsTable, LoggedSet>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoggedSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoggedSetsTable,
      LoggedSet,
      $$LoggedSetsTableFilterComposer,
      $$LoggedSetsTableOrderingComposer,
      $$LoggedSetsTableAnnotationComposer,
      $$LoggedSetsTableCreateCompanionBuilder,
      $$LoggedSetsTableUpdateCompanionBuilder,
      (LoggedSet, BaseReferences<_$AppDatabase, $LoggedSetsTable, LoggedSet>),
      LoggedSet,
      PrefetchHooks Function()
    >;
typedef $$ExerciseProgressCachesTableCreateCompanionBuilder =
    ExerciseProgressCachesCompanion Function({
      required String userId,
      required String exerciseName,
      required DateTime lastTrainedDate,
      required double topWeight,
      required int topReps,
      required int totalSets,
      Value<int> rowid,
    });
typedef $$ExerciseProgressCachesTableUpdateCompanionBuilder =
    ExerciseProgressCachesCompanion Function({
      Value<String> userId,
      Value<String> exerciseName,
      Value<DateTime> lastTrainedDate,
      Value<double> topWeight,
      Value<int> topReps,
      Value<int> totalSets,
      Value<int> rowid,
    });

class $$ExerciseProgressCachesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseProgressCachesTable> {
  $$ExerciseProgressCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastTrainedDate => $composableBuilder(
    column: $table.lastTrainedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get topWeight => $composableBuilder(
    column: $table.topWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topReps => $composableBuilder(
    column: $table.topReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSets => $composableBuilder(
    column: $table.totalSets,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExerciseProgressCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseProgressCachesTable> {
  $$ExerciseProgressCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastTrainedDate => $composableBuilder(
    column: $table.lastTrainedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get topWeight => $composableBuilder(
    column: $table.topWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topReps => $composableBuilder(
    column: $table.topReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSets => $composableBuilder(
    column: $table.totalSets,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExerciseProgressCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseProgressCachesTable> {
  $$ExerciseProgressCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastTrainedDate => $composableBuilder(
    column: $table.lastTrainedDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get topWeight =>
      $composableBuilder(column: $table.topWeight, builder: (column) => column);

  GeneratedColumn<int> get topReps =>
      $composableBuilder(column: $table.topReps, builder: (column) => column);

  GeneratedColumn<int> get totalSets =>
      $composableBuilder(column: $table.totalSets, builder: (column) => column);
}

class $$ExerciseProgressCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseProgressCachesTable,
          ExerciseProgressCache,
          $$ExerciseProgressCachesTableFilterComposer,
          $$ExerciseProgressCachesTableOrderingComposer,
          $$ExerciseProgressCachesTableAnnotationComposer,
          $$ExerciseProgressCachesTableCreateCompanionBuilder,
          $$ExerciseProgressCachesTableUpdateCompanionBuilder,
          (
            ExerciseProgressCache,
            BaseReferences<
              _$AppDatabase,
              $ExerciseProgressCachesTable,
              ExerciseProgressCache
            >,
          ),
          ExerciseProgressCache,
          PrefetchHooks Function()
        > {
  $$ExerciseProgressCachesTableTableManager(
    _$AppDatabase db,
    $ExerciseProgressCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseProgressCachesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExerciseProgressCachesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExerciseProgressCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<DateTime> lastTrainedDate = const Value.absent(),
                Value<double> topWeight = const Value.absent(),
                Value<int> topReps = const Value.absent(),
                Value<int> totalSets = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseProgressCachesCompanion(
                userId: userId,
                exerciseName: exerciseName,
                lastTrainedDate: lastTrainedDate,
                topWeight: topWeight,
                topReps: topReps,
                totalSets: totalSets,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                required String exerciseName,
                required DateTime lastTrainedDate,
                required double topWeight,
                required int topReps,
                required int totalSets,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseProgressCachesCompanion.insert(
                userId: userId,
                exerciseName: exerciseName,
                lastTrainedDate: lastTrainedDate,
                topWeight: topWeight,
                topReps: topReps,
                totalSets: totalSets,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ExerciseProgressCachesTable,
                    ExerciseProgressCache
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ExerciseProgressCachesTable,
                    ExerciseProgressCache
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExerciseProgressCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseProgressCachesTable,
      ExerciseProgressCache,
      $$ExerciseProgressCachesTableFilterComposer,
      $$ExerciseProgressCachesTableOrderingComposer,
      $$ExerciseProgressCachesTableAnnotationComposer,
      $$ExerciseProgressCachesTableCreateCompanionBuilder,
      $$ExerciseProgressCachesTableUpdateCompanionBuilder,
      (
        ExerciseProgressCache,
        BaseReferences<
          _$AppDatabase,
          $ExerciseProgressCachesTable,
          ExerciseProgressCache
        >,
      ),
      ExerciseProgressCache,
      PrefetchHooks Function()
    >;
typedef $$AiSuggestionCachesTableCreateCompanionBuilder =
    AiSuggestionCachesCompanion Function({
      required String cacheKey,
      required String jsonData,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AiSuggestionCachesTableUpdateCompanionBuilder =
    AiSuggestionCachesCompanion Function({
      Value<String> cacheKey,
      Value<String> jsonData,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AiSuggestionCachesTableFilterComposer
    extends Composer<_$AppDatabase, $AiSuggestionCachesTable> {
  $$AiSuggestionCachesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiSuggestionCachesTableOrderingComposer
    extends Composer<_$AppDatabase, $AiSuggestionCachesTable> {
  $$AiSuggestionCachesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiSuggestionCachesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiSuggestionCachesTable> {
  $$AiSuggestionCachesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AiSuggestionCachesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiSuggestionCachesTable,
          AiSuggestionCache,
          $$AiSuggestionCachesTableFilterComposer,
          $$AiSuggestionCachesTableOrderingComposer,
          $$AiSuggestionCachesTableAnnotationComposer,
          $$AiSuggestionCachesTableCreateCompanionBuilder,
          $$AiSuggestionCachesTableUpdateCompanionBuilder,
          (
            AiSuggestionCache,
            BaseReferences<
              _$AppDatabase,
              $AiSuggestionCachesTable,
              AiSuggestionCache
            >,
          ),
          AiSuggestionCache,
          PrefetchHooks Function()
        > {
  $$AiSuggestionCachesTableTableManager(
    _$AppDatabase db,
    $AiSuggestionCachesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiSuggestionCachesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiSuggestionCachesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiSuggestionCachesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiSuggestionCachesCompanion(
                cacheKey: cacheKey,
                jsonData: jsonData,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String jsonData,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AiSuggestionCachesCompanion.insert(
                cacheKey: cacheKey,
                jsonData: jsonData,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiSuggestionCachesTable, AiSuggestionCache>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AiSuggestionCachesTable,
                    AiSuggestionCache
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiSuggestionCachesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiSuggestionCachesTable,
      AiSuggestionCache,
      $$AiSuggestionCachesTableFilterComposer,
      $$AiSuggestionCachesTableOrderingComposer,
      $$AiSuggestionCachesTableAnnotationComposer,
      $$AiSuggestionCachesTableCreateCompanionBuilder,
      $$AiSuggestionCachesTableUpdateCompanionBuilder,
      (
        AiSuggestionCache,
        BaseReferences<
          _$AppDatabase,
          $AiSuggestionCachesTable,
          AiSuggestionCache
        >,
      ),
      AiSuggestionCache,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$WorkoutPlansTableTableManager get workoutPlans =>
      $$WorkoutPlansTableTableManager(_db, _db.workoutPlans);
  $$PlannedExercisesTableTableManager get plannedExercises =>
      $$PlannedExercisesTableTableManager(_db, _db.plannedExercises);
  $$LoggedSetsTableTableManager get loggedSets =>
      $$LoggedSetsTableTableManager(_db, _db.loggedSets);
  $$ExerciseProgressCachesTableTableManager get exerciseProgressCaches =>
      $$ExerciseProgressCachesTableTableManager(
        _db,
        _db.exerciseProgressCaches,
      );
  $$AiSuggestionCachesTableTableManager get aiSuggestionCaches =>
      $$AiSuggestionCachesTableTableManager(_db, _db.aiSuggestionCaches);
}
