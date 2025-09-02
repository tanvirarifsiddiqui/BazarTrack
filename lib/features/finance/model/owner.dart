class Owner {
  int? id;
  String? name;

  Owner({this.id, this.name});

  // Owner.fromJson(Map<String, dynamic> json) {
  //   id = json['id'];
  //   name = json['name'];
  // }
  factory Owner.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int)    return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Owner(
      id:      parseInt(json['id']),
      name:    json['name'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}