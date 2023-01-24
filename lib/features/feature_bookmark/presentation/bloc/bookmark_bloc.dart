import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:weather/core/resources/data_state.dart';
import 'package:weather/core/usecase/use_case.dart';
import 'package:weather/features/feature_bookmark/domain/use_cases/delet_city_usecase.dart';
import 'package:weather/features/feature_bookmark/domain/use_cases/get_all_city_usecase.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/delete_city_status.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/get_all_city_status.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/get_city_status.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/save_city_status.dart';

import '../../domain/use_cases/get_city_usecase.dart';
import '../../domain/use_cases/save_city_usecase.dart';

part 'bookmark_event.dart';

part 'bookmark_state.dart';

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  GetCityUseCase getCityUseCase;
  SaveCityUseCase saveCityUseCase;
  GetAllCityUseCase getAllCityUseCase;
  DeleteCityUseCase deleteCityUseCase;

  BookmarkBloc(this.getCityUseCase, this.saveCityUseCase, this.getAllCityUseCase,
      this.deleteCityUseCase)
      : super(BookmarkState(
            getCityStatus: GetCityLoading(),
            saveCityStatus: SaveCityInitial(),
            getAllCityStatus: GetAllCityLoading(),
            deleteCityStatus: DeleteCityInitial())) {


    ///get All city
    on<GetAllCityEvent>((event,emit)async{

      emit(state.copyWith(newGetAllCityStatus: GetAllCityLoading()));
      DataState dataState=await getAllCityUseCase(NoParams());

      ///emit Complete state
      if(dataState is DataSuccess){
        emit(state.copyWith(newGetAllCityStatus: GetAllCityCompleted(dataState.data)));
      }

      ///emit Error state
      if(dataState is DataFailed){
        emit(state.copyWith(newGetAllCityStatus: GetAllCityError(dataState.error)));
      }

    });


    /// City Delete Event
    on<DeleteCityEvent>((event, emit) async {
      /// emit Loading state
      emit(state.copyWith(newDeleteCityStatus: DeleteCityLoading()));

      DataState dataState = await deleteCityUseCase(event.name);

      /// emit Complete state
      if(dataState is DataSuccess){
        emit(state.copyWith(newDeleteCityStatus: DeleteCityCompleted(dataState.data)));
      }

      /// emit Error state
      if(dataState is DataFailed){
        emit(state.copyWith(newDeleteCityStatus: DeleteCityError(dataState.error)));
      }
    });



    ///get city by name
    on<GetCityByNameEvent>((event, emit) async {
      ///emit loading state
      emit(state.copyWith(newCityStatus: GetCityLoading()));

      DataState dataState = await getCityUseCase(event.cityName);

      ///emit complete state
      if (dataState is DataSuccess) {
        emit(state.copyWith(newCityStatus: GetCityCompleted(dataState.data)));
      }

      ///emit Error state
      if (dataState is DataFailed) {
        emit(state.copyWith(newCityStatus: GetCityError(dataState.error)));
      }
    });

    /// save city event
    on<SaveCwEvent>((event, emit) async {
      emit(state.copyWith(newSaveStatus: SaveCityLoading()));

      DataState dataState = await saveCityUseCase(event.name);

      ///emit Comlete state
      if (dataState is DataSuccess) {
        emit(state.copyWith(newSaveStatus: SaveCityCompleted(dataState.data)));
      }

      if (dataState is DataFailed) {
        emit(state.copyWith(newSaveStatus: SaveCityError(dataState.error)));
      }
    });

    /// set to init again SaveCity (برای بار دوم و سوم و غیره باید وضعیت دوباره به حالت اول برگرده وگرنه بوکمارک پر خواهد ماند)
    on<SaveCityInitialEvent>((event, emit) async {
      emit(state.copyWith(newSaveStatus: SaveCityInitial()));
    });
  }
}
