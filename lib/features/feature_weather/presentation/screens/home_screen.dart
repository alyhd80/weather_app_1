import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weather/core/utils/data_converter.dart';
import 'package:weather/core/widgets/app_background.dart';
import 'package:weather/core/widgets/dot_loading_widget.dart';
import 'package:weather/features/feature_bookmark/presentation/bloc/bookmark_bloc.dart';
import 'package:weather/features/feature_weather/data/data_source/local/forecast_params.dart';
import 'package:weather/features/feature_weather/data/models/fore_cast_days_model.dart';
import 'package:weather/features/feature_weather/data/models/suggest_city_model.dart';
import 'package:weather/features/feature_weather/domain/entities/current_city_entity.dart';
import 'package:weather/features/feature_weather/domain/entities/forecase_days_entity.dart';
import 'package:weather/features/feature_weather/domain/use_cases/get_suggestion_city_usecase.dart';
import 'package:weather/features/feature_weather/presentation/bloc/cw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/fw_status.dart';
import 'package:weather/features/feature_weather/presentation/bloc/home_bloc.dart';
import 'package:weather/features/feature_weather/presentation/widgets/bookmark_icon.dart';
import 'package:weather/features/feature_weather/presentation/widgets/days_weather_view.dart';
import 'package:weather/locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  String cityName = "rasht";
  final PageController _pageController = PageController();

  ///for textField
  TextEditingController textEditingController = TextEditingController();
  GetSuggestionCityUseCase getSuggestionCityUseCase =
      GetSuggestionCityUseCase(locator());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///call the api for get weather
    BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(cityName));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Row(
              children: [
                
                ///Search box
                Expanded(
                  child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                          onSubmitted: (String prefix) {
                            textEditingController.text = prefix;
                            BlocProvider.of<HomeBloc>(context).add(LoadCwEvent(prefix));
                          },
                          controller: textEditingController,
                          style: DefaultTextStyle.of(context)
                              .style
                              .copyWith(fontSize: 20, color: Colors.white),
                          decoration:  InputDecoration(
                            fillColor: Colors.grey.withOpacity(0.3),
                              filled: true,
                              contentPadding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                              hintText: "Enter a City",
                              hintStyle: const TextStyle(color: Colors.white),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(color: Colors.white),),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15)
                              ))),
                      suggestionsCallback: (String prefix) {
                        return getSuggestionCityUseCase(prefix);
                      },
                      itemBuilder: (context, Data model) {
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                          title: Text(model.name!),
                          subtitle: Text("${model.region!}, ${model.country!}"),
                        );
                      },
                      onSuggestionSelected: (Data model) {
                        textEditingController.text = model.name!;
                        BlocProvider.of<HomeBloc>(context)
                            .add(LoadCwEvent(model.name!));
                      }),
                ),
                const SizedBox(width: 10,),
                BlocBuilder<HomeBloc,HomeState>(
                    buildWhen: (previous,current){
                      if(previous.cwStatus==current.cwStatus){
                        return false;
                      }
                      return true;
                    },
                builder: (context,state) {
                  ///show loading state for cw
                  if(state.cwStatus is CwLoading){
                        return const CircularProgressIndicator();
                      }

                  ///show error state for cw
                  if(state.cwStatus is CwError){
                    return IconButton(onPressed: (){}, icon: Icon(Icons.error,color: Colors.red,));
                  }

                  if(state.cwStatus is CwCompleted){
                    final CwCompleted cwCompleted=state.cwStatus as CwCompleted;
                    BlocProvider.of<BookmarkBloc>(context).add(GetCityByNameEvent(cwCompleted.currentCityEntity.name!));
                    return BookMarkIcon(name: cwCompleted.currentCityEntity.name!);
                  }

                  return Container();
                })
              ],
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
            buildWhen: (pervius, current) {
              if (pervius.cwStatus == current.cwStatus) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state.cwStatus is CwLoading) {
                return const Expanded(child: DotLoadingWidget());
              }

              if (state.cwStatus is CwCompleted) {
                //gereftan etelaat

                final CwCompleted cwCompleted = state.cwStatus as CwCompleted;
                final CurrentCityEntity currentCityEntity =
                    cwCompleted.currentCityEntity;

                ///create params for api call for عرض جغرافیایی
                final ForeCastParams forcastParams = ForeCastParams(
                    currentCityEntity.coord!.lat!,
                    currentCityEntity.coord!.lon!);

                ///start load fw event

                BlocProvider.of<HomeBloc>(context).add(LoadFwEvent(forcastParams));


                ///change Times to Hour
                final sunrise=DateConverter.changeDtToDateTimeHour(currentCityEntity.sys!.sunrise, currentCityEntity.timezone);
                final sunset=DateConverter.changeDtToDateTimeHour(currentCityEntity.sys!.sunset, currentCityEntity.timezone);

                return Expanded(
                    child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: height * 0.02),
                      child: SizedBox(
                        width: width,
                        height: height*0.50,
                        child: PageView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            allowImplicitScrolling: true,
                            controller: _pageController,
                            itemCount: 2,
                            itemBuilder: (context, position) {
                              if (position == 0) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black38.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            currentCityEntity.name!,
                                            style: const TextStyle(
                                                fontSize: 30,
                                                color: Colors.white),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            currentCityEntity
                                                .weather![0].description!,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: AppBackground.setIconForMain(
                                                currentCityEntity
                                                    .weather![0].description)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Text(
                                            "${currentCityEntity.main!.temp!.round()}\u00B0",
                                            style: const TextStyle(
                                                fontSize: 50,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  "max",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  "${currentCityEntity.main!.tempMax!.round()}\u00B0",
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),

                                            ///divider
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                              ),
                                              child: Container(
                                                color: Colors.grey,
                                                width: 2,
                                                height: 40,
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                const Text(
                                                  "min",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  "${currentCityEntity.main!.tempMin!.round()}\u00B0",
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  color: Colors.amber.withOpacity(0.2),
                                );
                              }
                            }),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: ExpandingDotsEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            spacing: 5,
                            activeDotColor: Colors.blue.withOpacity(0.5)),
                        onDotClicked: (index) {
                          _pageController.animateToPage(index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.bounceOut);
                        },
                      ),
                    ),

                    ///forcast weather 7 days
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Center(
                            child: BlocBuilder<HomeBloc, HomeState>(
                              builder: (BuildContext context, state) {
                                if (state.fwStatus is FwLoading) {
                                  return const DotLoadingWidget();
                                }

                                if (state.fwStatus is FwCompleted) {
                                  final FwCompleted fwCompleted =
                                      state.fwStatus as FwCompleted;
                                  final ForecastDaysEntity forecastDaysEntity =
                                      fwCompleted.forecastDaysEntity;
                                  final List<Daily> mainDaily =
                                      forecastDaysEntity.daily!;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 8,
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      return DaysWeatherView(
                                          daily: mainDaily[index]);
                                    },
                                  );
                                }

                                /// show Error State for Fw
                                if (state.fwStatus is FwError) {
                                  final FwError fwError =
                                      state.fwStatus as FwError;
                                  return Center(
                                    child: Text(fwError.message!),
                                  );
                                }

                                /// show Default State for Fw
                                return Container();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    ///
                    Padding(padding: const EdgeInsets.only(top: 10,bottom: 30,right: 20,left: 20),
                    child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text("Wind Speed",style: TextStyle(fontSize: height*0.017,color: Colors.amber),),
                                Padding(padding: const EdgeInsets.only(top: 10),child: Text("${currentCityEntity.wind!.speed!} m/s",style: TextStyle(fontSize: height*0.016,color: Colors.white),),)
                              ],
                            ),
                            Padding(padding: const EdgeInsets.only(left: 10,right: 10),child: Container(color: Colors.white,height: 30,width: 2,),),

                            Column(
                              children: [
                                Text("sunset",style: TextStyle(fontSize: height*0.017,color: Colors.amber),),
                                Padding(padding: const EdgeInsets.only(top: 10),child: Text(sunset,style: TextStyle(fontSize: height*0.016,color: Colors.white),),)
                              ],
                            ),
                            Padding(padding: const EdgeInsets.only(left: 10,right: 10),child: Container(color: Colors.white,height: 30,width: 2,),),

                            Column(
                              children: [
                                Text("sunrise",style: TextStyle(fontSize: height*0.017,color: Colors.amber),),
                                Padding(padding: const EdgeInsets.only(top: 10),child: Text(sunrise,style: TextStyle(fontSize: height*0.016,color: Colors.white),),)
                              ],
                            ),
                            Padding(padding: const EdgeInsets.only(left: 10,right: 10),child: Container(color: Colors.white,height: 30,width: 2,),),

                            Column(
                              children: [
                                Text("humidity",style: TextStyle(fontSize: height*0.017,color: Colors.amber),),
                                Padding(padding: const EdgeInsets.only(top: 10),child: Text("${currentCityEntity.main!.humidity!} %",style: TextStyle(fontSize: height*0.016,color: Colors.white),),)
                              ],
                            ),

                          ],
                        ),
                        const SizedBox(height: 10,),

                      ],
                    ),),
                    )
                    
                  ],
                ));
              }

              if (state.cwStatus is CwError) {
                return const Center(
                    child: Text(
                  "error",
                  style: TextStyle(color: Colors.white),
                ));
              }

              return Container();
            },
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
