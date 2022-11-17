class Token {
  String token = '';
  String expiration = '';
  String idUser = '';
  String nameUser = '';

  Token(
      {required this.token,
      required this.expiration,
      required this.idUser,
      required this.nameUser});

  Token.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expiration = json['expiracion'];
    idUser = json['idUser'];
    nameUser = json['nameUser'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['expiracion'] = expiration;
    data['idUser'] = idUser;
    data['nameUser'] = nameUser;
    return data;
  }
}
