class Activities {
  int activitiesId = 0;
  String description = '';
  bool status = false;
  String usersId = '';

  Activities(
      {this.activitiesId = 0,
      this.description = '',
      this.status = false,
      this.usersId = ''});

  Activities.fromJson(Map<String, dynamic> json) {
    activitiesId = json['activitiesId'];
    description = json['description'];
    status = json['status'];
    usersId = json['usersId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['activitiesId'] = activitiesId;
    data['description'] = description;
    data['status'] = status;
    data['usersId'] = usersId;
    return data;
  }
}
