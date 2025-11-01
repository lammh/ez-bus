
class MobileMoneyAccount{
  int? id;
  String? phoneNumber, network;

  MobileMoneyAccount({
    this.id,
    this.phoneNumber,
    this.network,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'network': network,
    };
  }

  static MobileMoneyAccount fromJson(json) {
    return MobileMoneyAccount(
      id: json['id'],
      phoneNumber: json['phone_number'],
      network: json['network'],
    );
  }

}