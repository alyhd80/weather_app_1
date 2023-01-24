import 'package:dio/dio.dart';
import 'package:weather/core/resources/data_state.dart';
import 'package:weather/features/feature_weather/data/data_source/local/forecast_params.dart';
import 'package:weather/features/feature_weather/data/data_source/remote/api_provider.dart';
import 'package:weather/features/feature_weather/data/models/CurrentCityModel.dart';
import 'package:weather/features/feature_weather/data/models/fore_cast_days_model.dart';
import 'package:weather/features/feature_weather/data/models/suggest_city_model.dart';
import 'package:weather/features/feature_weather/domain/entities/current_city_entity.dart';
import 'package:weather/features/feature_weather/domain/entities/forecase_days_entity.dart';
import 'package:weather/features/feature_weather/domain/entities/suggest_city_entity.dart';
import 'package:weather/features/feature_weather/domain/repository/weather_repository.dart';

class WeatherRepositoryImpl extends WeatherRepository {
  ApiProvider _apiProvider;
  WeatherRepositoryImpl(this._apiProvider);

  @override
  Future<DataState<CurrentCityEntity>> fetchCurrentData(String cityName) async {

    try{
      Response response = await _apiProvider.callCurrentWeather(cityName);

      if(response.statusCode == 200){
        CurrentCityEntity currentCityEntity = CurrentCityModel.fromJson(response.data);
        return DataSuccess(currentCityEntity);
      }else{
        return const DataFailed("Something Went Wrong. try again...");
      }
    }catch(e){
      return const DataFailed("please check your connection...");
    }
  }

  @override
  Future<DataState<ForecastDaysEntity>> fetchForecastWeatherData(ForeCastParams params) async{

    try{
      Response response=await _apiProvider.sendRequest7DaysForecast(params);

      if(response.statusCode==200){
        ForecastDaysEntity forecastDaysEntity=ForecastDaysModel.fromJson(response.data);
        return DataSuccess(forecastDaysEntity);
      }else{
        return const DataFailed("Something went wrong. try again..");
      }


    }catch(e){
      print(e.toString());
      return const DataFailed("please check your connection...");

    }

  }

  @override
  Future<List<Data>> fetchSuggestData(cityName) async{
    // TODO: implement fetchSuggestData
    Response response=await _apiProvider.sendRequestCitySuggestion(cityName);
    SuggestCityEntity suggestCityEntity=SuggestCityModel.fromJson(response.data);
    return suggestCityEntity.data!;
  }
}
