import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather/features/feature_bookmark/domain/entities/city_entity.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/get_all_city_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';

import '../../../../core/widgets/app_background.dart';

class BookMarkScreen extends StatelessWidget {
  final PageController pageController;
  const BookMarkScreen({Key? key,required this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<BookmarkBloc>(context).add(GetAllCityEvent());
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return BlocBuilder<BookmarkBloc, BookmarkState>(
      ///rebuild ui just when all City Status changed
      buildWhen: (previous, current) {
        if (current.getAllCityStatus == previous.getAllCityStatus) {
          return false;
        } else {
          return true;
        }
      },

      builder: (context, state) {
        ///show Loading for AllCityStatus
        if (state.getAllCityStatus is GetAllCityLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        /// show Completed for AllCityStatus
        if (state.getAllCityStatus is GetAllCityCompleted) {
          /// casting for getting cities
          GetAllCityCompleted getAllCityCompleted = state.getAllCityStatus as GetAllCityCompleted;
          List<City> cities = getAllCityCompleted.cities;

          if(cities.isEmpty){
            return Container(color: Colors.black.withOpacity(0.5),child: const Center(child: Text(  "there is no bookmark city",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),));
          }else {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  forceElevated: true,
                  floating: true,
                  // pinned: true,
                  expandedHeight: 100,
                  elevation: 0,
                  flexibleSpace: const FlexibleSpaceBar(
                    title: Text(
                      "WatchList",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {

                      return GestureDetector(
                        onTap: () {

                          ///call for getting bookmarked city Data
                          BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(cities[index].name));
                          ///animate to HomeScreen for showing data
                          pageController.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                        },
                        child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
                                child: Container(
                                  width: width,
                                  height: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          cities[index].name,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        IconButton(
                                            onPressed: () {
                                              BlocProvider.of<BookmarkBloc>(
                                                  context).add(DeleteCityEvent(
                                                  cities[index].name));
                                              BlocProvider.of<BookmarkBloc>(
                                                  context).add(
                                                  GetAllCityEvent());
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      );

                  }, childCount: cities.length),
                )
              ],
            );
          }
        }

        ///show Error for AllCityStatus
        if (state.getCityStatus is GetAllCityError) {
          ///casting for getting error
          GetAllCityError getAllCityError =
              state.getAllCityStatus as GetAllCityError;
          return Center(
            child: Text(getAllCityError.message!),
          );
        }

        ///show default value
        return Container();
      },
    );
  }
}
