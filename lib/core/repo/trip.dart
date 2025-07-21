import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logistics_customer/core/config.dart';
import 'package:logistics_customer/core/models/trip.dart';
import 'package:logistics_customer/core/utilities/localStorage.dart';
import 'package:logistics_customer/core/utilities/logger.dart';

final Dio _dio = GetIt.I<Dio>();

Future<bool> createTrip(TripModel data, String vehicleNumber) async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response tripResponse = await _dio.get("${UrlConfig.baseurl}/trip/",
      queryParameters: {"vehicle_number": vehicleNumber},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    List<TripViewModel> trips = (tripResponse.data as List)
        .map((json) => TripViewModel.fromJson(json))
        .toList();
    CustomLogger.debug(trips[0]);
    if(trips[0].detLat != null) {
      Response response = await _dio.post(
        "${UrlConfig.baseurl}/trip/create",
        data: data.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      CustomLogger.debug(response.data);
      return true;
    }else{
      return false;
    }
  } on DioException catch (e) {
    CustomLogger.error("Trip creation failed: ${e.response?.data}");
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}

Future<List<TripViewModel>> getTrips() async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response response = await _dio.get(
      "${UrlConfig.baseurl}/trip/",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    CustomLogger.debug("Response data: ${response.data}");
    List<TripViewModel> trips = (response.data as List)
        .map((json) => TripViewModel.fromJson(json))
        .toList();
    return trips;
  } on DioException catch (e) {
    CustomLogger.error("Trip creation failed: ${e.response?.data}");
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}

Future<List<TripViewModel>> getFilteredTrips(String vehicleNumber) async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response response = await _dio.get(
      "${UrlConfig.baseurl}/trip/",
      queryParameters: {"vehicle_number": vehicleNumber},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    CustomLogger.debug("Response data: ${response.data}");
    List<TripViewModel> trips = (response.data as List)
        .map((json) => TripViewModel.fromJson(json))
        .toList();
    return trips;
  } on DioException catch (e) {
    CustomLogger.error("Trip creation failed: ${e.response?.data}");
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}

Future<void> updateTrip(TripUpdateModel data, int tripId) async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response response = await _dio.put(
      "${UrlConfig.baseurl}/trip/update/$tripId",
      queryParameters: {"trip_id": tripId},
      data: (FormData.fromMap(data.toFormData())),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    CustomLogger.debug(response.data);
  } on DioException catch (e) {
    CustomLogger.error("Trip creation failed: ${e.response?.data}");
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}
