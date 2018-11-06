//  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
//
//  PVAtari7800ControllerViewController.swift
//  Provenance
//
//  Created by James Addyman on 05/09/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//
//
//  PVAtari7800ControllerViewController.swift
//  Provenance
//
//  Created by Joe Mattiello on 08/22/2016.
//  Copyright (c) 2016 Joe Mattiello. All rights reserved.
//

import PVSupport

fileprivate extension JSButton {
    var buttonTag: PV7800Button {
        get {
            return PV7800Button(rawValue: tag)!
        }
        set {
            tag = newValue.rawValue
        }
    }
}

final class PVAtari7800ControllerViewController: PVControllerViewController<PV7800SystemResponderClient> {

    override func layoutViews() {
        buttonGroup?.subviews.forEach {
            guard let button = $0 as? JSButton, let title = button.titleLabel?.text else {
                return
            }
            if title == "Fire 1" || title == "1" {
                button.buttonTag = .fire1
            } else if title == "Fire 2" || title == "2" {
                button.buttonTag = .fire2
            } else if title == "Select" {
                button.buttonTag = .select
            } else if title == "Reset" {
                button.buttonTag = .reset
            } else if title == "Pause" {
                button.buttonTag = .pause
            }
        }

        startButton?.buttonTag = .reset
        selectButton?.buttonTag = .select
    }

    override func dPad(_ dPad: JSDPad, didPress direction: JSDPadDirection) {
        emulatorCore.didRelease(.up, forPlayer: 0)
        emulatorCore.didRelease(.down, forPlayer: 0)
        emulatorCore.didRelease(.left, forPlayer: 0)
        emulatorCore.didRelease(.right, forPlayer: 0)
        switch direction {
            case .upLeft:
                emulatorCore.didPush(.up, forPlayer: 0)
                emulatorCore.didPush(.left, forPlayer: 0)
            case .up:
                emulatorCore.didPush(.up, forPlayer: 0)
            case .upRight:
                emulatorCore.didPush(.up, forPlayer: 0)
                emulatorCore.didPush(.right, forPlayer: 0)
            case .left:
                emulatorCore.didPush(.left, forPlayer: 0)
            case .right:
                emulatorCore.didPush(.right, forPlayer: 0)
            case .downLeft:
                emulatorCore.didPush(.down, forPlayer: 0)
                emulatorCore.didPush(.left, forPlayer: 0)
            case .down:
                emulatorCore.didPush(.down, forPlayer: 0)
            case .downRight:
                emulatorCore.didPush(.down, forPlayer: 0)
                emulatorCore.didPush(.right, forPlayer: 0)
            default:
                break
        }
        vibrate()
    }

    override func dPadDidReleaseDirection(_ dPad: JSDPad) {
        emulatorCore.didRelease(.up, forPlayer: 0)
        emulatorCore.didRelease(.down, forPlayer: 0)
        emulatorCore.didRelease(.left, forPlayer: 0)
        emulatorCore.didRelease(.right, forPlayer: 0)
    }

    override func buttonPressed(_ button: JSButton) {
        emulatorCore.didPush(button.buttonTag, forPlayer: 0)
        vibrate()
    }

    override func buttonReleased(_ button: JSButton) {
        emulatorCore.didRelease(button.buttonTag, forPlayer: 0)
    }

    override func pressStart(forPlayer player: Int) {
        emulatorCore.didPush(.reset, forPlayer: player)
    }

    override func releaseStart(forPlayer player: Int) {
        emulatorCore.didRelease(.reset, forPlayer: player)
    }

    override func pressSelect(forPlayer player: Int) {
        emulatorCore.didPush(.select, forPlayer: player)
    }

    override func releaseSelect(forPlayer player: Int) {
        emulatorCore.didRelease(.select, forPlayer: player)
    }
}