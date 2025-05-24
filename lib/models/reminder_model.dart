enum RepeatType {
  none('none'),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly');

  const RepeatType(this.value);
  final String value;

  static RepeatType fromString(String value) {
    return RepeatType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RepeatType.none,
    );
  }
}

enum ReminderType {
  water('water'),
  mainMeal('main_meal'),
  snack('snack'),
  supplement('supplement'),
  other('other');

  const ReminderType(this.value);
  final String value;

  static ReminderType fromString(String value) {
    return ReminderType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReminderType.other,
    );
  }
}

enum ReminderStatus {
  active('active'),
  paused('paused'),
  completed('completed');

  const ReminderStatus(this.value);
  final String value;

  static ReminderStatus fromString(String value) {
    return ReminderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReminderStatus.active,
    );
  }
}

class Reminder {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String time;
  final RepeatType repeat;
  final ReminderType type;
  final ReminderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.time,
    this.repeat = RepeatType.none,
    this.type = ReminderType.other,
    this.status = ReminderStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      time: json['time'] ?? '',
      repeat: RepeatType.fromString(json['repeat'] ?? 'none'),
      type: ReminderType.fromString(json['type'] ?? 'other'),
      status: ReminderStatus.fromString(json['status'] ?? 'active'),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) return DateTime.now();

    try {
      if (dateTimeValue is String) {
        if (dateTimeValue.contains('+') || dateTimeValue.contains('Z')) {
          final dateTime = DateTime.parse(dateTimeValue);
          return dateTime.toLocal();
        } else {
          return DateTime.parse(dateTimeValue);
        }
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'time': time,
      'repeat': repeat.value,
      'type': type.value,
      'status': status.value,
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? time,
    RepeatType? repeat,
    ReminderType? type,
    ReminderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
