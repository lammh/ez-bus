
class BankAccount{
  int? id;
  String? accountNumber, beneficiaryName, beneficiaryAddress, bankName, routingNumber, iban, swift, bic;

  BankAccount({
    this.id,
    this.accountNumber,
    this.beneficiaryName,
    this.beneficiaryAddress,
    this.bankName,
    this.routingNumber,
    this.iban,
    this.swift,
    this.bic,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_number': accountNumber,
      'beneficiary_name': beneficiaryName,
      'beneficiary_address': beneficiaryAddress,
      'bank_name': bankName,
      'routing_number': routingNumber,
      'iban': iban,
      'swift': swift,
      'bic': bic,
    };
  }

  static BankAccount fromJson(json) {
    return BankAccount(
      id: json['id'],
      accountNumber: json['account_number'],
      beneficiaryName: json['beneficiary_name'],
      beneficiaryAddress: json['beneficiary_address'],
      bankName: json['bank_name'],
      routingNumber: json['routing_number'],
      iban: json['iban'],
      swift: json['swift'],
      bic: json['bic'],
    );
  }

}