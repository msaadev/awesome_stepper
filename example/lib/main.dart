import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Material App Bar'),
      ),
      body: PageView(
        children: [awesomeStepper(), stepper()],
      ),
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

  Widget stepper() {
    return Stepper(
        onStepCancel: () {
          setState(() {
            step--;
          });
        },
        onStepContinue: () {
          setState(() {
            step++;
          });
        },
        onStepTapped: (i) {
          setState(() {
            step = i;
          });
        },
        currentStep: step,
        physics: BouncingScrollPhysics(),
        elevation: 7,
        type: StepperType.horizontal,
        steps: <String>['1', '2', '3', '4']
            .map((e) => Step(
                title: Text('Step $e'),
                isActive: step + 1 > int.parse(e),
                state: stepState(int.parse(e) - 1),
                content: Container(
                  alignment: Alignment.center,
                  child: Text('Step $e'),
                )))
            .toList());
  }

  StepState stepState(int i) {
    if (step == i) {
      return StepState.editing;
    } else if (step < i) {
      return StepState.disabled;
    } else {
      return StepState.complete;
    }
  }
}
