

import 'package:weather/core/resources/data_state.dart';
import 'package:weather/features/feature_weather/data/data_source/local/forecast_params.dart';
import 'package:weather/features/feature_weather/data/models/suggest_city_model.dart';
import 'package:weather/features/feature_weather/domain/entities/current_city_entity.dart';
import 'package:weather/features/feature_weather/domain/entities/forecase_days_entity.dart';

abstract class WeatherRepository{

 Future<DataState<CurrentCityEntity>> fetchCurrentData(String cityName);

 Future<DataState<ForecastDaysEntity>> fetchForecastWeatherData(ForeCastParams params);

 Future<List<Data>> fetchSuggestData(cityName);



}