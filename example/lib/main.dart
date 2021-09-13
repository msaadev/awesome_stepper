import 'package:flutter/material.dart';
import 'package:lib_msaadev/lib_msaadev.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Stepper());
  }
}

class Stepper extends StatelessWidget {
  const Stepper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            decoration:
                BoxDecoration(color: Colors.red, borderRadius: 5.customRadius),
            margin: 5.paddingAll,
            height: context.height * 0.1,
          ),
          Flexible(
            child: PageView(
              children: [
                Container(
                  margin: 5.paddingSymmetricHorizontal,
                  decoration: BoxDecoration(
                      color: Colors.green, borderRadius: 5.customRadius),
                ),
                Container(
                  margin: 5.paddingSymmetricHorizontal,
                  decoration: BoxDecoration(
                      color: Colors.green, borderRadius: 5.customRadius),
                ),
                Container(
                  margin: 5.paddingSymmetricHorizontal,
                  decoration: BoxDecoration(
                      color: Colors.green, borderRadius: 5.customRadius),
                )
              ],
            ),
          ),
          Container(
            margin: 5.paddingAll,
            height: context.height * 0.1,
            decoration:
                BoxDecoration(color: Colors.red, borderRadius: 5.customRadius),
          ),
        ],
      ),
    );
  }
}