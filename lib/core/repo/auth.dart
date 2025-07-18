import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../config.dart';
import '../utilities/logger.dart';

final Dio _dio = GetIt.I<Dio>();

Future<String> signIn(String email, String password) async {
  try {
    Response response = await _dio.post(
      '${UrlConfig.baseurl}/customer/auth/login',
      data: {"user_email": email, "password": password},
    );
    CustomLogger.info("${response.data["access_token"]}}");
    return response.data["access_token"];
  } catch (e) {
    CustomLogger.error(e);
    rethrow;
  }
}
