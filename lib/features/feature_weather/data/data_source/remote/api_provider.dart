import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:weather/core/utils/constants.dart';

import '../local/forecast_params.dart';

class ApiProvider {
  Dio _dio = Dio();
  var apiKey = Constants.apiKeys1;


  ///call weather city api
  Future<dynamic> callCurrentWeather(cityName) async {
    var response = await _dio.get(
        '${Constants.baseUrl}/data/2.5/weather',
        queryParameters: {
          'q': cityName,
          'appid': apiKey,
          'units' : 'metric'
        }
    );
    print(response.data);
    return response;
  }

  /// 7 days forecast api
  Future<dynamic> sendRequest7DaysForecast(ForeCastParams params) async {


    var response=await _dio.get(
      "${Constants.baseUrl}/data/2.5/onecall",
      queryParameters: {
        "lat":params.lat,
        "lon":params.lon,
        "exclude":"minutely,hourly",
        "appid":apiKey,
        "units":"metric"
      }
    );
    print(response);
    return response;
  }

  ///city name suggest api
  Future<dynamic> sendRequestCitySuggestion(String prefix) async{
    var response = await _dio.get(
        "http://geodb-free-service.wirefreethought.com/v1/geo/cities",
        queryParameters: {'limit': 7, 'offset': 0, 'namePrefix': prefix});

    return response;
  }
}
