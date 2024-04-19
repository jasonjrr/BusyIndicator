# BusyIndicator

BusyIndicator is a lightweight service implementation for SwiftUI that allows you to register any view and set it as busy.

## Installation
You can install this package using Swift Package Manager. Add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/jasonjrr/BusyIndicator.git", from: "1.0.0")
```

Then add the package as a dependency for your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        "BusyIndicator",
    ]
),
```

## Usage
First you need to add the `BusyIndicator` to your SwiftUI environment:
```swift
import SwiftUI
import BusyIndicator

// Add this to your favorite dependency injection container or pattern.
private let busyIndicatorService: BusyIndicatorServiceProtocol = BusyIndicatorService()

@main
struct SwiftUIApp: App {
  var body: some Scene {
    WindowGroup {
      AppRootView()
        .busyIndicator(busyIndicatorService.busyIndicator)
    }
  }
}

```

Then just add the `busyOverlay` modifier to any SwiftUI `View`:
```swift
import BusyIndicator

// ...

Button {
  // action code goes here
} label: {
  Text("Action")
}
.busyOverlay()
.clipShape(RoundedRectangle(cornerRadius: 16.0, style: .continuous))
```

Finally, trigger the `BusyIndicator` through the `BusyIndicatorService`:
```swift
import BusyIndicator

// ...

private let busyService: BusyIndicatorServiceProtocol

// ...

func doSomethingAsynchronous() async {
  let busySubject = busyService.enqueue()
  await someAsyncTask()
  busySubject.dequeue()
}

```

## License
This project is licensed under the [License Name] - see the LICENSE.md file for details.
