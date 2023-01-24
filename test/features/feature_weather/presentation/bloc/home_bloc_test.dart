
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather/core/resources/data_state.dart';
import 'package:weather/features/feature_weather/domain/entities/current_city_entity.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_current_weather_use_case.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_forecast_weather_usecase.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';

import 'home_bloc_test.mocks.dart';

@GenerateMocks([GetCurrentWeatherUseCase,GetForecastWeatherUseCase])
void main(){

 MockGetCurrentWeatherUseCase mockGetCurrentWeatherUseCase=MockGetCurrentWeatherUseCase();
 MockGetForecastWeatherUseCase mockGetForecastWeatherUseCase=MockGetForecastWeatherUseCase();

  String cityName="tehran";
  String error="error";

  group("cw Event test", () {
when(mockGetCurrentWeatherUseCase.call(any)).thenAnswer((_)async=>Future.value(DataSuccess(CurrentCityEntity())));

  });

}