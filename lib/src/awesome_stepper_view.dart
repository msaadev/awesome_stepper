import 'package:awesome_stepper/awesome_stepper.dart';
import 'package:flutter/material.dart';
import 'package:lib_msaadev/lib_msaadev.dart';

class AwesomeStepper extends StatefulWidget {
  final List<AwesomeStepperItem> steps;
  const AwesomeStepper({Key? key, required this.steps}) : super(key: key);

  @override
  State<AwesomeStepper> createState() => _AwesomeStepperState();
}

class _AwesomeStepperState extends State<AwesomeStepper> {
  late int selectedItem;
  late AwesomeStepperItem step;

  @override
  void initState() {
    super.initState();
    selectedItem = 0;
    step = widget.steps[selectedItem];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildTop(),
        Expanded(child: buildCenter()),
        buildBottom(),
      ],
    );
  }

  Container buildTop() {
    return Container(
      height: context.customHeight(8),
      color: Colors.grey,
      child: Row(
        children: [
          Expanded(
              child: Center(
            child: Container(
              height: context.customHeight(8),
              width: context.customHeight(8),
              padding: 10.paddingAll,
              child: CircularProgressIndicator(
                  value: (selectedItem + 1) / widget.steps.length),
            ),
          )),
          Expanded(flex: 2, child: Text(step.label)),
        ],
      ),
    );
  }

  Widget buildCenter() => step.content;

  Container buildBottom() {
    return Container(
      height: context.customHeight(8),
      color: Colors.green,
    );
  }
}
