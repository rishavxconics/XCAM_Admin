import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logistics_customer/core/config.dart';
import 'package:logistics_customer/core/models/vehicle.dart';
import 'package:logistics_customer/core/utilities/localStorage.dart';
import 'package:logistics_customer/core/utilities/logger.dart';

final Dio _dio = GetIt.I<Dio>();

Future<List<VehicleModel>> fetchVehicle() async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response response = await _dio.get(
      "${UrlConfig.baseurl}/vehicle/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    CustomLogger.debug("Response data: ${response.data}");
    List<VehicleModel> vehicles = (response.data as List)
        .map((json) => VehicleModel.fromJson(json))
        .toList();

    return vehicles;
  } on DioException catch (e) {
    CustomLogger.error(
      "Error: ${e.response?.statusCode} - ${e.response?.data}",
    );
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}
