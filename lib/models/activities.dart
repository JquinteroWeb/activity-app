class Activities {
  String description = '';
  bool status = false;
  String usersId = '';

  Activities(
      {required this.description, required this.status, required this.usersId});

  Activities.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    status = json['status'];
    usersId = json['usersId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['status'] = status;
    data['usersId'] = usersId;
    return data;
  }
}
