/// Verwaltet die prozentuale Aufgabenverteilung der Ameisen
class TaskAllocation {
  final int foraging;
  final int building;
  final int caregiving;
  final int defense;
  final int exploration;

  const TaskAllocation({
    required this.foraging,
    required this.building,
    required this.caregiving,
    required this.defense,
    required this.exploration,
  });

  TaskAllocation copyWith({
    int? foraging,
    int? building,
    int? caregiving,
    int? defense,
    int? exploration,
  }) {
    return TaskAllocation(
      foraging: foraging ?? this.foraging,
      building: building ?? this.building,
      caregiving: caregiving ?? this.caregiving,
      defense: defense ?? this.defense,
      exploration: exploration ?? this.exploration,
    );
  }

  factory TaskAllocation.initial() {
    return const TaskAllocation(
      foraging: 50,
      building: 20,
      caregiving: 20,
      defense: 5,
      exploration: 5,
    );
  }

  factory TaskAllocation.fromJson(Map<String, dynamic> json) {
    return TaskAllocation(
      foraging: json['foraging'] as int,
      building: json['building'] as int,
      caregiving: json['caregiving'] as int,
      defense: json['defense'] as int,
      exploration: json['exploration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foraging': foraging,
      'building': building,
      'caregiving': caregiving,
      'defense': defense,
      'exploration': exploration,
    };
  }

  int get total => foraging + building + caregiving + defense + exploration;
}
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv