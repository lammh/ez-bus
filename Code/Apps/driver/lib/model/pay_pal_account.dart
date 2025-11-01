
class PayPalAccount{
  int? id;
  String? email;

  PayPalAccount({
    this.id,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  static PayPalAccount fromJson(json) {
    return PayPalAccount(
      id: json['id'],
      email: json['email'],
    );
  }

}