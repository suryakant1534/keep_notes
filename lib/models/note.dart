class Note {
  int id = -1;
  final String title;
  final String description;
  final String dateTime;
  final int priority;
  String? firebaseId;

  Note({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.priority,
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
}
