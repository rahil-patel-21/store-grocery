class FoodCardResponseModel {
  FoodCardResponseModel({
    this.status,
    this.data,
    this.msg,
  });

  bool status;
  List<Datum> data;
  String msg;

  factory FoodCardResponseModel.fromJson(Map<String, dynamic> json) {
    return FoodCardResponseModel(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) {
      return Datum.fromJson(x);})),
    msg: json["msg"],
  );}

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "msg": msg,
  };
}

class Datum {
  Datum({
    this.id,
    this.userId,
    this.cardAccount,
    this.cardNumber,
  });

  int id;
  int userId;
  String cardAccount;
  String cardNumber;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
    id: json["id"],
    userId: json["user_id"],
    cardAccount: json["card_account"],
    cardNumber: json["card_number"],
  );}

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "card_account": cardAccount,
    "card_number": cardNumber,
  };
}
