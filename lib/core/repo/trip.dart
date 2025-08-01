import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logistics_customer/core/config.dart';
import 'package:logistics_customer/core/models/trip.dart';
import 'package:logistics_customer/core/utilities/localStorage.dart';
import 'package:logistics_customer/core/utilities/logger.dart';

final Dio _dio = GetIt.I<Dio>();

Future<bool> createTrip(TripModel data, String vehicleNumber, String qr) async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response tripResponse = await _dio.get(
      "${UrlConfig.baseurl}/trip/",
      queryParameters: {"device_qr": qr},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    List<TripViewModel> trips = (tripResponse.data as List)
        .map((json) => TripViewModel.fromJson(json))
        .toList();
    if (trips.isEmpty || trips[0].detLat != null) {
      Response response = await _dio.post(
        "${UrlConfig.baseurl}/trip/create",
        data: data.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      CustomLogger.debug(response.data);
      return true;
    } else {
      return false;
    }
  } on DioException catch (e) {
    CustomLogger.error("Trip creation failed: ${e.response?.data}, ${e.response?.statusCode}");
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}

Future<List<TripViewModel>> getTrips() async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    int offset = 0;
    int limit = 50;
    List<TripViewModel> dataAll = [];
    while(true) {
      Response response = await _dio.get(
        "${UrlConfig.baseurl}/trip/",
        queryParameters: {"offset": offset, "limit": limit},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      CustomLogger.debug("Response data: ${response.data}");
      List<TripViewModel> trips = (response.data as List)
          .map((json) => TripViewModel.fromJson(json))
          .toList();

      if (trips.isEmpty) break;

      dataAll.addAll(trips);

      if (trips.length < limit) break; // No more data to fetch

      offset += limit;
    }
      dataAll.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return dataAll;
  } on DioException catch (e) {
    CustomLogger.error("Trip get failed: ${e.response?.data}");
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
    CustomLogger.error(
      "Trip Update failed: ${e.response?.data}, ${e.response?.statusCode}",
    );
    rethrow;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}

Future<bool> updateTripStatus(TripUpdateModel data,int tripId, String token) async {
  try {
    CustomLogger.debug("Sending updateTripStatus payload: ${data.toFormData()}");
    Response response = await _dio.put(
      "${UrlConfig.baseurl}/trip/update/$tripId",
      queryParameters: {"trip_id": tripId},
      data: (FormData.fromMap(data.toFormData())),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    CustomLogger.debug(response.data);
    return true;
  } catch (e) {
    CustomLogger.error(e);
    return false;
  }
}
