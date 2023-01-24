import 'package:weather/config/usecase/use_case.dart';
import 'package:weather/core/resources/data_state.dart';

import '../repository/city_repository.dart';

class DeleteCityUseCase implements UseCase<DataState<String>, String> {
  final CityRepository _cityRepository;

  DeleteCityUseCase(this._cityRepository);

  @override
  Future<DataState<String>> call(String params) {
    // TODO: implement call
    return _cityRepository.deletCityByName(params);
  }
}
