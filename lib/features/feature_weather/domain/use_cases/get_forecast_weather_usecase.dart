


import 'package:weather/features/feature_weather/data/data_source/local/forecast_params.dart';
import 'package:weather/features/feature_weather/domain/repository/weather_repository.dart';
import '../../../../config/usecase/use_case.dart';
import '../../../../core/resources/data_state.dart';
import '../entities/forecase_days_entity.dart';

class GetForecastWeatherUseCase implements UseCase<DataState<ForecastDaysEntity>, ForeCastParams>{
  final WeatherRepository _weatherRepository;
  GetForecastWeatherUseCase(this._weatherRepository);

  @override
  Future<DataState<ForecastDaysEntity>> call(ForeCastParams params) {
    return _weatherRepository.fetchForecastWeatherData(params);
  }

}