![# DyCI – Dynamic Code Injection](/Meta/logo.png?raw=true "DyCI – Dynamic Code Injection")

[![Join the chat at https://gitter.im/DyCI/dyci-main](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/DyCI/dyci-main?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 

This tool allows you to inject code into running iOS application, without restarting it.

1. DyCI is not about loading new code in application.
2. DyCI is about speeding up development.
3. Each time, you are using DyCI, it saves you time.

## WARNING

Uninstall DyCI before updating Xcode.
If you don't you may need to reinstall xcode.
We're currenlty working on [this issue](https://github.com/DyCI/dyci-main/issues/8)...
If you've already expirienced this issue - remove and reinstall Xcode.

## Installation

#### 1. Install on machine
This is done once per machine. See details on [installation page](https://github.com/DyCI/dyci-main/wiki/Installation).

#### 2. Add to your project
DyCI needs to integrate with the project as well. If you are using [CocoaPods](https://github.com/CocoaPods/CocoaPods) you can add this to your podfile

```
pod 'dyci', :git => 'https://github.com/DyCI/dyci-main.git'
```

If you prefer a manual approach you can read about it in the [wiki](https://github.com/DyCI/dyci-main/wiki/Using-dyci).

## Reasons, why do you need this tool
* apply small logic changes in no time
* when working with UI and animations you can see the results immediately
* It's good for debugging purposes. Remember, you can inject any code at runtime, add log statements etc.

## Compared to other tools
* You need minimum moves to enable dyci
* You aren't writing some kind of script, you are writing your code!
* You don't need to prepare/modify/lock your code for dyci
* Your changes are always saved (they will not be discarded on next run)

## How it works
You can read all about it in the [How it works wiki](https://github.com/DyCI/dyci-main/wiki/How-it-Works).

## Demos

[![ic-Tac-Toe game](http://img.youtube.com/vi/8nyEpAqUug4/maxresdefault.jpg)](https://www.youtube.com/watch?v=8nyEpAqUug4)

[Tic-Tac-Toe Game recreation](https://www.youtube.com/watch?v=8nyEpAqUug4)

## Example

- There's an interactive demo in the workspace found in the `Dynamic Code Injection` folder.
- Krzysztof Zabłocki created [KZPlayground](https://github.com/krzysztofzablocki/KZPlayground).

## WARNING
Please, do not use this tool in your real applications, that you will publish to the App Store. DyCI won't work on devices by default, by purpose. Dynamic code injection is good for development, but it will leave huge security hole if you put it in your application.

## FAQ
Please open any issue, but be sure to read the [FAQ](https://github.com/DyCI/dyci-main/wiki/FAQ) before you do:-)

## Other Tools
There's few other tools those works kind'a the same, so if you don't like dyci - you can try those

- [injectionforxcode](https://github.com/johnno1962/injectionforxcode)

## Author(s)

Taykalo Paul, ptaykalo@stanfy.com.ua  
[Find me on twitter.](http://twitter.com/TT_Kilew)

