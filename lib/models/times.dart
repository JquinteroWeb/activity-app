class Times {
  int timesId = 0;
  int timeWork = 0;
  String date = '';
  String observation = '';
  int activitiesId = 0;

  Times(
      {required this.timesId,
      required this.timeWork,
      required this.date,
      required this.observation,
      required this.activitiesId});

  Times.fromJson(Map<String, dynamic> json) {
    timesId = json['timesId'];
    timeWork = json['timeWork'];
    date = json['date'];
    observation = json['observation'];
    activitiesId = json['activitiesId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timesId'] = timesId;
    data['timeWork'] = timeWork;
    data['date'] = date;
    data['observation'] = observation;
    data['activitiesId'] = activitiesId;
    return data;
  }
}
