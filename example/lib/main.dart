import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: AwesomeStepper(
          steps: [
            AwesomeStepperItem(
              label: 'Step 1', 
              content: Container(
              alignment: Alignment.center,
              child: Text('Step 1'),
            ) ),
            AwesomeStepperItem(
              label: 'Step 2', 
              content: Container(
              alignment: Alignment.center,
              child: Text('Step 2'),
            ) ),
            AwesomeStepperItem(
              label: 'Step 3', 
              content: Container(
              alignment: Alignment.center,
              child: Text('Step 3'),
            ) ),
            AwesomeStepperItem(
              label: 'Step 4', 
              content: Container(
              alignment: Alignment.center,
              child: Text('Step 4'),
            ) ),
          ],
        ),
      ),
    );
  }
}