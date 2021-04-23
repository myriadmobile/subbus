# Subbus

[![Version](https://img.shields.io/cocoapods/v/Subbus.svg?style=flat)](https://cocoapods.org/pods/Subbus)
[![License](https://img.shields.io/cocoapods/l/Subbus.svg?style=flat)](https://cocoapods.org/pods/Subbus)
[![Platform](https://img.shields.io/cocoapods/p/Subbus.svg?style=flat)](https://cocoapods.org/pods/Subbus)

Subbus is a library that introduces events, similar to `NotificationCenter`.  It simplifies the subscription/unsubscribe, and extends capabilities of the `NotificationCenter` with things like typed events and event persistence.

## Example Usage

Start by creating a class for your event:
```swift
struct ExampleEvent{}
```

An object is able to register itself as an observer to receive notifications for a specific event (similar to the listener in `NotificationCenter` by calling the subscribe function:
```swift
Subbus.subscribe(observer: self, event: ExampleEvent.self) { (event) in
    print("Event Received!")
}
```

Once our subscriber is ready, we can post the event our subscriber registered to:
```swift
Subbus.post(event: ExampleEvent())
```

This will trigger the handler of the `subscribe`.  In the example above, we print out `"Event Received!"`

Finally, when we no longer wish to receive events:

```swift
Subbus.unsubscribe(id: self)
// or
Subbus.unsubscribe(id: self, event: ExampleEvent.self)
```

> If your subscriber is a class, there's no need to unsubscribe it.  Subbus will automatically discard subscriptions whose id has been deallocated (similar to NotificationCenter).

See below for advanced usage examples.

## Example Project

To run the example project: clone the repo, and run `pod install` from the `Example` directory first.

Check out the unit tests for more example usage!

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

## Advanced Usage

### ScopedEvent
Some challenges may require many different event types.  Rather than introducing a new parameter to your event, it's possible to specify a scope when subscribing and posting:

```swift
let scope = "example_scope"

Subbus.addSubscription(id: self, event: ExampleEvent.self, limitedToScope: scope) { (event) in
    print("Scoped Event Received: \"\(scope)"\")
}

Subbus.post(event: ExampleEvent(), limitedToScope: scope)
```

In this example, any listeners that subscribed to the `ExampleEvent` without specifying a scope would **not** receive the event.  Only those registered to the posted scope (and the same event) would receive the event.

### PersistentEvent

Managing timing of event subscription can lead to complexities.  `PersistentEvent` eliminates this need by allowing events to persist beyond the `Post` action.  Their lifespan is based on whether a subscriber successfully handles the event, and the persistence rule of the event itself:

```swift
class  ExamplePersistentEvent: PersistentEvent {
    var  exampleVar: String?

    init() {
        super.init(persistenceRule: .clearImmediately)
    }
}
```

At any point in time, you can post this event.  If no listeners subscribed to this event, they will receive the event immediately after subscribing.

You can then subscribe to Subbus normally, but this time return either `.handledSuccessfully` or `.failed` upon receiving the event:

```swift
Subbus.addSubscription(id: self, event: ExamplePersistentEvent.self) { (event) -> PersistentEvent.HandlerResult  in
    // Handle this event, if able
    return .handledSuccessfully
}
```

What happens after a subscriber receives the event is based on the `persistenceRule` of the event:

```swift
///  The rule defining how the event will be persisted.
///
///  For all rules, if no subscribers return .handledSuccessfully, the event will persist.
///  The next subscriber to subscribe to that event will immediately receive the event.
public  enum  PersistenceRule {
    ///  If a subscriber returns .handledSuccessfully, no other subscribers will receive it.
    case  clearImmediately
    
    ///  If a subscriber returns .handledSuccessfully, only existing subscribers
    ///  will receive the event, then it will be cleared.
    case  clearAfterAllCurrentSubscribersNotified
    
    ///  Event will *never* be cleared, regardless of what subscribers return.
    case  neverClear
}
```

## Author

Bushel Inc, ios@bushelpowered.com
