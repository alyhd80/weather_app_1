import 'package:weather/config/usecase/use_case.dart';
import 'package:weather/core/resources/data_state.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:weather/features/feature_bookmark/domain/repository/city_repository.dart';

class SaveCityUseCase implements UseCase<DataState<City>, String> {
  final CityRepository _cityRepository;

  SaveCityUseCase(this._cityRepository);

  @override
  Future<DataState<City>> call(String params) {
    // TODO: implement call
    return _cityRepository.saveCityToDB(params);
  }
}
