class DriverData
{
  String? firstName, lastName, phoneNumber, address, email, licenseNumber;
  String? responseMessage;

  DriverData(
      {
        this.firstName,
        this.lastName,
        this.phoneNumber,
        this.address,
        this.email,
        this.licenseNumber,
        this.responseMessage
      });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'address': address,
      'email': email,
      'license_number': licenseNumber,
      'response': responseMessage
    };
  }

  static DriverData fromJson(json) {
    return DriverData(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      email: json['email'],
      licenseNumber: json['license_number'],
      responseMessage: json['response'],
    );
  }

}