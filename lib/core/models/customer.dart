class Customer {
  final int id;
  final String name;
  final String phoneNumber;
  final String userEmail;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.userEmail,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      userEmail: json['user_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'user_email': userEmail,
    };
  }
}
