# Subbus

[![CI Status](https://img.shields.io/travis/Alex Larson/Subbus.svg?style=flat)](https://travis-ci.org/Alex Larson/Subbus)
[![Version](https://img.shields.io/cocoapods/v/Subbus.svg?style=flat)](https://cocoapods.org/pods/Subbus)
[![License](https://img.shields.io/cocoapods/l/Subbus.svg?style=flat)](https://cocoapods.org/pods/Subbus)
[![Platform](https://img.shields.io/cocoapods/p/Subbus.svg?style=flat)](https://cocoapods.org/pods/Subbus)


Subbus is a library that improves upon the mechanism of NSNotificationCenter. You specify objects that are passed as events and the library automatically defines a message name. This means that you, as a developer, don't have to worry about remember what the s of your various subscriptions are.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 10.0+
- Swift 4.0+


## Installation

Subbus is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```
pod 'Subbus'
```

Enter command instruction into your terminal.

```
pod install
```

# Usage
Start by creating your notification object
```swift
struct TestAction{}
```

An object is able to register itself as an observer to receive notifications for a specific event by calling the subscribe function. In the context of NotifcationCenter, this is the listener.
```swift
Subbus.subscribe(observer: self, event: TestAction.self)
```

We can also post a notification about a specific event like this. In the context of NotifcationCenter, this is the sender. 
```swift
Subbus.post(event: TestAction())
```

## Author

Alex Larson, alarson@myriadmobile.com


## License

Subbus is available under the MIT license. See the LICENSE file for more info.
Subbus is available under the MIT license. See the LICENSE file for more info.
