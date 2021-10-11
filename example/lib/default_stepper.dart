
import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';

class DefaultStepper extends StatelessWidget {
  const DefaultStepper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Awesome Stepper'),
      centerTitle: true,
      ),
      body: awesomeStepper(),
    );
  }

  AwesomeStepper awesomeStepper() {
    return AwesomeStepper(
      steps: [
        AwesomeStepperItem(
            label: 'Step 1',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 1'),
            )),
        AwesomeStepperItem(
            label: 'Step 2',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 2'),
            )),
        AwesomeStepperItem(
            label: 'Step 3',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 3'),
            )),
        AwesomeStepperItem(
            label: 'Step 4',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 4'),
            )),
        AwesomeStepperItem(
            label: 'Step 5',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 5'),
            )),
        AwesomeStepperItem(
            label: 'Step 6',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 6'),
            )),
        AwesomeStepperItem(
            label: 'Step 7',
            content: Container(
              alignment: Alignment.center,
              child: Text('Step 7'),
            )),
      ],
    );
  }
}
