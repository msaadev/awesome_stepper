# awesome_stepper

[![Developer Challenge](https://img.shields.io/badge/developer-challenge-informational?logo=data:image/svg%2bxml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4KPCEtLSBHZW5lcmF0b3I6IEFkb2JlIElsbHVzdHJhdG9yIDI1LjQuMSwgU1ZHIEV4cG9ydCBQbHVnLUluIC4gU1ZHIFZlcnNpb246IDYuMDAgQnVpbGQgMCkgIC0tPgo8c3ZnIHZlcnNpb249IjEuMSIgaWQ9IkxheWVyXzEiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiIHg9IjBweCIgeT0iMHB4IgoJIHZpZXdCb3g9IjAgMCAyNCAyNCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMjQgMjQ7IiB4bWw6c3BhY2U9InByZXNlcnZlIj4KPHN0eWxlIHR5cGU9InRleHQvY3NzIj4KCS5zdDB7ZmlsbDojRTZFNkU2O30KPC9zdHlsZT4KPGc+Cgk8ZyBpZD0iTGF5ZXJfMl8xXyI+CgkJPGcgaWQ9IkxheWVyXzEtMl8yXyI+CgkJCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik00LjIsOC40aDEuOWMwLjIsMCwwLjMsMC4xLDAuMywwLjNjMCwwLjEsMCwwLjItMC4xLDAuMmwtMi45LDIuOWMtMC4xLDAuMS0wLjEsMC4zLDAsMC41bDIuOSwyLjkKCQkJCWMwLjEsMC4xLDAuMSwwLjMsMCwwLjVjLTAuMSwwLjEtMC4xLDAuMS0wLjIsMC4xSDQuMmMtMC4xLDAtMC4zLTAuMS0wLjQtMC4ybC0zLjEtMy4xYy0wLjItMC4yLTAuMi0wLjYsMC0wLjhsMy4xLTMuMQoJCQkJQzQsOC40LDQuMSw4LjQsNC4yLDguNHoiLz4KCQkJPHBhdGggY2xhc3M9InN0MCIgZD0iTTE5LjgsMTUuNmgtMS45Yy0wLjIsMC0wLjMtMC4xLTAuMy0wLjNjMC0wLjEsMC0wLjIsMC4xLTAuMmwyLjktMi45YzAuMS0wLjEsMC4xLTAuMywwLTAuNWwtMi45LTIuOQoJCQkJYy0wLjEtMC4xLTAuMS0wLjMsMC0wLjVjMC4xLTAuMSwwLjEtMC4xLDAuMi0wLjFoMS45YzAuMSwwLDAuMywwLjEsMC40LDAuMmwzLjEsMy4xYzAuMiwwLjIsMC4yLDAuNiwwLDAuOGwtMy4xLDMuMQoJCQkJQzIwLDE1LjYsMTkuOSwxNS42LDE5LjgsMTUuNnoiLz4KCQkJPHBhdGggY2xhc3M9InN0MCIgZD0iTTkuOSwxNC45YzAtMC4xLTAuMS0wLjEtMC4xLTAuMWMwLDAsMCwwLTAuMSwwYy0xLDEuOC0yLjksMi44LTQuOSwyLjhINC4zYy0wLjIsMC0wLjMsMC4xLTAuMywwLjN2Mi4zCgkJCQljMCwwLjIsMC4xLDAuMywwLjMsMC4zaDAuNGMyLjUsMCw0LjktMS4xLDYuNS0yLjljMCwwLDAtMC4xLDAtMC4xQzEwLjYsMTYuOCwxMC4yLDE1LjksOS45LDE0Ljl6Ii8+CgkJCTxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik05LjksOWMwLjMtMSwwLjgtMS45LDEuNC0yLjdjMCwwLDAtMC4xLDAtMC4xYy0xLjYtMS45LTQtMi45LTYuNS0yLjlINC41QzQuMiwzLjIsNCwzLjUsNCwzLjhsMCwwdjIuMQoJCQkJYzAsMC4yLDAuMSwwLjMsMC4zLDAuM2wwLDBoMC40YzIsMCwzLjksMS4xLDQuOSwyLjhDOS43LDkuMSw5LjgsOS4xLDkuOSw5QzkuOCw5LjEsOS44LDkuMSw5LjksOXoiLz4KCQkJPHBhdGggY2xhc3M9InN0MCIgZD0iTTE5LjMsNi4yaDAuM2MwLjIsMCwwLjMtMC4xLDAuMy0wLjNWMy44YzAtMC4zLTAuMi0wLjUtMC41LTAuNWgtMC4xYy00LjgsMC04LjgsMy45LTguOSw4LjcKCQkJCWMwLDQuOCwzLjksOC44LDguNyw4LjhjMCwwLDAsMCwwLjEsMGgwLjJjMC4zLDAsMC41LTAuMiwwLjUtMC41djB2LTIuMWMwLTAuMi0wLjEtMC4zLTAuMy0wLjNsMCwwaC0wLjRjLTMuMiwwLTUuOC0yLjYtNS44LTUuOAoJCQkJYzAsMCwwLTAuMSwwLTAuMUMxMy41LDguNywxNi4yLDYuMiwxOS4zLDYuMnoiLz4KCQk8L2c+Cgk8L2c+CjwvZz4KPC9zdmc+Cg==)](https://pub.dev/packages?q=developerchallenge)

Awesome Stepper with beautiful UI and Animations 

## Features 

* beautiful UI
* Customizable controllers
* Infinite step

## Supported platforms

* Flutter Android
* Flutter iOS
* Flutter web
* Flutter desktop


## Installation

Add `awesome_stepper: ^0.0.21` to your `pubspec.yaml` dependencies. And import it:

```dart
import 'package:awesome_stepper/awesome_stepper.dart';
```

## How to use

Simply create a `AwesomeStepper` widget, and pass the required params and List of AwesomeStepperItem:

```dart
AwesomeStepper(
      headerColor: Colors.blue,
      progressColor: Colors.red,
      headerStyle: const TextStyle(color: Colors.white, fontSize: 20),
      progressBarAnimationDuration: const Duration(seconds: 2),
      headerAnimationDuration: const Duration(seconds: 1),
      progressStyle: const TextStyle(color: Colors.white, fontSize: 20),
      controlBuilder: (onNext, onBack) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded)),
            IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward_ios_rounded)),
          ],
        );
      },
      onStepChanged: (page) {
        print('active page = $page');
      },
      steps: [
        AwesomeStepperItem(
            label: 'Step 1',
            content: Container(
              alignment: Alignment.center,
              child: const Text('Step 1'),
            )),
        AwesomeStepperItem(
            label: 'Step 2',
            content: Container(
              alignment: Alignment.center,
              child: const Text('Step 2'),
            )),
        
      ],
    )
```

### Screen Shots

![Customized Stepper](screen_shots/customized_awesome_steper.gif)![Default Stepper](screen_shots/default_awesome_steper.gif)
