
import 'package:weather/config/usecase/use_case.dart';
import 'package:weather/features/feature_weather/domain/repository/weather_repository.dart';

import '../../../../core/resources/data_state.dart';
import '../entities/current_city_entity.dart';

class GetCurrentWeatherUseCase  extends UseCase<DataState<CurrentCityEntity>,String>{
  final WeatherRepository weatherRepository;
  GetCurrentWeatherUseCase(this.weatherRepository);
  Future<DataState<CurrentCityEntity>> call(String cityName){
    return weatherRepository.fetchCurrentData(cityName);


  }
}