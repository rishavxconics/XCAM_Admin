import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

void setup(String token) {
  // final Dio dioService = Dio()..interceptors.add(InterceptorsWrapper(
  //   onRequest: (options,handler){
  //     options.headers["Authorization"]=token;
  //     return handler.next(options);
  //   },
  // ));
  final Dio dioService = Dio();
  GetIt.I.registerSingleton<Dio>(dioService);
}

void deRegister() {
  if (GetIt.instance.isRegistered<Dio>()) {
    GetIt.instance.unregister<Dio>();
  }
}
