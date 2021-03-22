README Updated: 03/22/2021

## Objectives

Use the example application to get a feel for how the interactions between the application, mimik client library, mimik client library adapter, example microservice, and mimik edgeEngine work.

## Project setup start

On your Mac use the terminal to clone the iOS quickstart example project from GitHub to somewhere in your user home directory. This guide works with the ~/Desktop folder.

```cd ~/Desktop```

```git clone https://github.com/edgeEngine/quickstart-ios```

Navigate to the project directory

```cd quickstart-ios```

Check your cocoapod version to make sure you're good to go with a compatible version (**1.10.1**+)

```pod --version```

Install the required cocoapods

```pod install```

**You will need to finish the mimik developer account registration and developer id token steps below and come back here before being able to fully experience this example project.**

## mimik developer account registration
Create a mimik developer account and/or sign in to the mimik developer console at
```https://developer.mimik.com/console```

## mimik developer id token and client id
Create a new example project while signed in to the mimik developer console.
```➕ Create New Project ```

Get the developer id token and client id of the new example project.
```🗝 Get ID Token ```


# Continue project setup

Start **Xcode 12.4**+ and open the example-dev-id-token.xcworkspace. **Note** You must use a **real device**, not a simulator to build the example application. edgeEngine will not work on simulated devices.

Copy the developer id token and client id values and paste them into the Developer.swift file in the example-dev-id-token Xcode project that you cloned to the ~/Desktop/quickstart-ios folder.

Sign into your Apple developer account in Xcode and adjust the Bundle identifier and Signing settings for the example-dev-id-token that fit your Apple developer profile under the example-dev-id-token target.



## Using the example application

Once the application is running on your test device there are a few functions you can test.

First press the Startup button to start. The following actions will happen in succession:

1. edgeEngine will be started, via the mimik client library
2. edgeEngine will be authorized using your mimik developer id token, via the mimik client library
3. an example microservice will be deployed to edgeEngine, via the mimik client library

Once the example microservice is deployed you can try using the microservice features:

1. Press Network to search for devices on your local network **(There is currently a known issue with iOS 14+ devices where the local network discovery feature might not work properly. Use the Nearby feature instead.)**
2. Press Nearby to search across all networks for devices deemed to be within a proximity distance of your device

It works best if you have at least two other devices running the same example application. One on the same network and another on a different network.

Tap any of the discovered devices to see a Hello WORLD!!! response. Sometimes you have to wait a bit for the connection tunnels to be established between different networks.
