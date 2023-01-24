import 'package:weather/core/resources/data_state.dart';
import 'package:weather/features/feature_bookmark/data/data_source/local/city_dao.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:weather/features/feature_bookmark/domain/repository/city_repository.dart';

class CityRepositoryImpl extends CityRepository {
  CityDao cityDao;

  CityRepositoryImpl(this.cityDao);

  @override
  Future<DataState<City>> saveCityToDB(String cityName) async {
    // TODO: implement saveCityToDB
    try {
      ///check city exist or not
      City? checkCity = await cityDao.findCityByName(cityName);
      if (checkCity != null) {
        return DataFailed("${cityName} has Already exist");
      }

      ///insert city to database
      City city = City(name: cityName);
      await cityDao.insertCity(city);
      return DataSuccess(city);
    } catch (e) {
      print(e.toString());
      return DataFailed(e.toString());
    }
  }

  @override
  Future<DataState<List<City>>> getAllCityFromDB() async {
    // TODO: implement getAllCityFromDB
    try {
      List<City> cities = await cityDao.getAllCity();
      return DataSuccess(cities);
    } catch (e) {
      return DataFailed(e.toString());
    }
  }

  @override
  Future<DataState<City?>> findCityByName(String name) async {
    // TODO: implement findCityByName
    try{
      City? city=await cityDao.findCityByName(name);
      return DataSuccess(city);
    }catch(e){
      print(e.toString());
      return DataFailed(e.toString());
    }

  }

  @override
  Future<DataState<String>> deletCityByName(String name) async {
    // TODO: implement deletCityByName
    try{
      await cityDao.deleteCityByName(name);
      return DataSuccess(name);
    }catch(e){
      print(e.toString());
      return DataFailed(e.toString());
    }
  }


}
