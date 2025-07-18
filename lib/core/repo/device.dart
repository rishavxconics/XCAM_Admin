import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logistics_customer/core/config.dart';
import 'package:logistics_customer/core/utilities/localStorage.dart';
import 'package:logistics_customer/core/utilities/logger.dart';

final Dio _dio = GetIt.I<Dio>();

Future<int?> getDeviceId(String qr) async {
  try {
    String token = await SecureLocalStorage.getValue("token");
    Response response = await _dio.get(
      "${UrlConfig.baseurl}/device/${qr}",
      queryParameters: {"qr": qr},
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    CustomLogger.debug("Response data: ${response.data}");
    final id = int.tryParse(response.data['id'].toString());
    return id;
  } on DioException catch (e) {
    CustomLogger.error(
      "Error: ${e.response?.statusCode} - ${e.response?.data}",
    );
    return null;
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}
