import 'package:flutter/material.dart';

class StepperExample extends StatefulWidget {
  static const id = "stepper_example";

  const StepperExample({Key key}) : super(key: key);

  @override
  _StepperExampleState createState() => _StepperExampleState();
}

class _StepperExampleState extends State<StepperExample> {
  int _index = 0;

  Widget buildBox(int step) {
    return Container(
      width: 390,
      height: 400,
      child: Text("Step $step"),
      decoration: BoxDecoration(
        color: Colors.lightGreen,
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.yellowAccent.withGreen(10).withOpacity(0.18), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product Maintenance"),),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 1),
        child: Theme(
          data: ThemeData(
              applyElevationOverlayColor: true,
              accentColor: Colors.lightBlue,
              primarySwatch: Colors.orange,
              colorScheme: ColorScheme.light(
                  primary: Colors.lightBlue
              )
          ),
          child: Stepper(
              physics: ClampingScrollPhysics(),
              type: StepperType.vertical,
              currentStep: _index,
              onStepCancel: () {
                if (_index > 0) {
                  setState(() {
                    _index-=1;
                  });
                }
              },
              onStepContinue: () {
                if (_index < 4) {
                  setState(() {
                    _index+=1;
                  });
                }
              },
              onStepTapped: (index) {
                setState(() {
                  _index = index;
                });
              },
              steps: <Step>[
                Step(
                  isActive: _index >= 0,
                  state: _index == 0 ? StepState.editing : _index >= 0 ?
                  StepState.complete : StepState.disabled,

                  title:  Text("Product"),
                  subtitle: Text("Details"),
                  content: buildBox(1),
                ),

                Step(
                  isActive: _index >= 0,
                  state: _index == 1 ? StepState.editing : _index >= 1 ?
                  StepState.complete : StepState.disabled,

                  title: const Text("Product Detail"),
                  content: Container(alignment: Alignment.centerLeft, child: const Text('Content for Step 2')),
                ),
                Step(
                  isActive: _index >= 0,
                  state: _index == 2 ? StepState.editing : _index >= 2 ?
                  StepState.complete : StepState.disabled,
                  title: const Text("Variants"),
                  content: Container(alignment: Alignment.centerLeft, child: const Text('Content for Step 3')),
                ),
                Step(
                  isActive: _index >= 0,
                  state: _index == 3 ? StepState.editing : _index >= 3 ?
                  StepState.complete : StepState.disabled,
                  title: const Text("Inventory"),
                  content: Container(alignment: Alignment.centerLeft, child: const Text('Content for Step 3')),
                ),
                Step(
                  isActive: _index >= 0,
                  state: _index == 4 ? StepState.editing : _index >= 4 ?
                  StepState.complete : StepState.disabled,
                  title: const Text("Images"),
                  content: Container(alignment: Alignment.centerLeft, child: const Text('Content for Step 3')),
                ),

              ]),
        ),
      ),
    );
  }
}
