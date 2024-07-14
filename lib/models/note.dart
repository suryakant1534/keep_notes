class Note {
  late int id;
  final String title;
  final String description;
  final String dateTime;
  final int priority;
  final String firebaseId;

  Note({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.priority,
    required this.firebaseId,
  });

  set setId(int id) => this.id = id;

  Note.withId({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.priority,
    required this.firebaseId,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['dateTime'] = dateTime;
    map['priority'] = priority;
    map['firebaseId'] = firebaseId;
    return map;
  }

  Note.fromMapObj(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'],
        dateTime = map['dateTime'],
        firebaseId = map['firebaseId'] ?? "",
        priority = map['priority'];

  @override
  String toString() {
    return 'Note{id: $id, title: $title, description: $description, dateTime: $dateTime, priority: $priority, firebaseId: $firebaseId}';
  }

  bool equal(Note note) {
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (other is! Note) return false;
    if (other.runtimeType != runtimeType) return false;
    if (other.title != title) return false;
    if (other.priority != priority) return false;
    if (other.description != description) return false;

    return true;
  }

  @override
  int get hashCode {
    int value = 0;
    value += firebaseId.hashCode;
    value += title.hashCode;
    value += priority.hashCode;
    value += description.hashCode;
    value += id.hashCode;
    value += dateTime.hashCode;
    return value.hashCode;
  }
}
