import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/data_converter.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/fore_cast_days_model.dart';

class DaysWeatherView extends StatefulWidget {
  Daily daily;

  DaysWeatherView({Key? key, required this.daily}) : super(key: key);

  @override
  State<DaysWeatherView> createState() => _DaysWeatherViewState();
}

class _DaysWeatherViewState extends State<DaysWeatherView>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween(begin: -1.0, end: 0.0,).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1, curve: Curves.linearToEaseOut)));
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform(
          transform:
              Matrix4.translationValues((animation.value! * width), 0.0, 0.0),
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: SizedBox(
                  width: 80,
                  height: 100,
                  child: Column(
                    children: [
                      const SizedBox(height: 10,),
                      Text(
                          DateConverter.changeDtToDateTime(widget.daily.dt)
                              .toString(),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey,fontWeight: FontWeight.bold),),
                      Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: AppBackground.setIconForMain(
                              widget.daily.weather![0].description,),),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text("${widget.daily.temp!.day!.round()}\u00B0",
                            style: const TextStyle(
                                fontSize: 15, color: Colors.white),),
                      )),
                    ],

                  )),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    // _fwBloc.dispose();
    // _cwBloc.dispose();
    super.dispose();
  }
}
