import 'customer.dart';

class VehicleModel {
  final int id;
  final String vehicleNumber;
  final Customer customer;

  VehicleModel({
    required this.id,
    required this.vehicleNumber,
    required this.customer,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      vehicleNumber: json['vehicle_number'],
      customer: Customer.fromJson(json['customer']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'customer': customer.toJson(),
    };
  }
}
