import Foundation

enum IRCCCommand: CaseIterable, Identifiable {
    // Power
    case power

    // Volume
    case volumeUp
    case volumeDown
    case mute

    // Channel
    case channelUp
    case channelDown

    // D-Pad
    case up
    case down
    case left
    case right
    case confirm

    // Navigation
    case home
    case back
    case options
    case menu

    // Media
    case play
    case pause
    case stop
    case rewind
    case forward

    // Numeric
    // NOTE: num7/8/9 intentionally share codes with channelUp/channelDown/volumeUp.
    // Sony TVs use the same byte codes for these buttons and distinguish them by
    // the current context (live TV mode vs. app mode).
    case num0
    case num1
    case num2
    case num3
    case num4
    case num5
    case num6
    case num7
    case num8
    case num9

    // Input
    case input

    // MARK: - IRCC byte code

    var code: String {
        switch self {
        case .power:        return "AAAAAQAAAAEAAAAVAw=="
        case .volumeUp:     return "AAAAAQAAAAEAAAASAw=="
        case .volumeDown:   return "AAAAAQAAAAEAAAATAw=="
        case .mute:         return "AAAAAQAAAAEAAAAUAw=="
        case .channelUp:    return "AAAAAQAAAAEAAAAQAw=="
        case .channelDown:  return "AAAAAQAAAAEAAAARAw=="
        case .up:           return "AAAAAQAAAAEAAAB0Aw=="
        case .down:         return "AAAAAQAAAAEAAAB1Aw=="
        case .left:         return "AAAAAQAAAAEAAAB2Aw=="
        case .right:        return "AAAAAQAAAAEAAAB3Aw=="
        case .confirm:      return "AAAAAQAAAAEAAABlAw=="
        case .home:         return "AAAAAQAAAAEAAABgAw=="
        case .back:         return "AAAAAgAAAJcAAAAjAw=="
        case .options:      return "AAAAAgAAAJcAAAA2Aw=="
        case .menu:         return "AAAAAQAAAAEAAAADAw=="
        case .play:         return "AAAAAgAAAJcAAAAaAw=="
        case .pause:        return "AAAAAgAAAJcAAAAZAw=="
        case .stop:         return "AAAAAgAAAJcAAAAYAw=="
        case .rewind:       return "AAAAAgAAAJcAAAAbAw=="
        case .forward:      return "AAAAAgAAAJcAAAAcAw=="
        case .num0:         return "AAAAAQAAAAEAAAAJAw=="
        case .num1:         return "AAAAAQAAAAEAAAAKAw=="
        case .num2:         return "AAAAAQAAAAEAAAALAw=="
        case .num3:         return "AAAAAQAAAAEAAAAMAw=="
        case .num4:         return "AAAAAQAAAAEAAAANAw=="
        case .num5:         return "AAAAAQAAAAEAAAAOAw=="
        case .num6:         return "AAAAAQAAAAEAAAAPAw=="
        case .num7:         return "AAAAAQAAAAEAAAAQAw=="  // same wire code as channelUp
        case .num8:         return "AAAAAQAAAAEAAAARAw=="  // same wire code as channelDown
        case .num9:         return "AAAAAQAAAAEAAAASAw=="  // same wire code as volumeUp
        case .input:        return "AAAAAQAAAAEAAAAlAw=="
        }
    }

    // MARK: - Identifiable

    var id: String { displayName }

    // MARK: - Display

    var displayName: String {
        switch self {
        case .power:       return "Power"
        case .volumeUp:    return "Vol +"
        case .volumeDown:  return "Vol -"
        case .mute:        return "Mute"
        case .channelUp:   return "CH +"
        case .channelDown: return "CH -"
        case .up:          return "Up"
        case .down:        return "Down"
        case .left:        return "Left"
        case .right:       return "Right"
        case .confirm:     return "OK"
        case .home:        return "Home"
        case .back:        return "Back"
        case .options:     return "Options"
        case .menu:        return "Menu"
        case .play:        return "Play"
        case .pause:       return "Pause"
        case .stop:        return "Stop"
        case .rewind:      return "Rewind"
        case .forward:     return "Forward"
        case .num0:        return "0"
        case .num1:        return "1"
        case .num2:        return "2"
        case .num3:        return "3"
        case .num4:        return "4"
        case .num5:        return "5"
        case .num6:        return "6"
        case .num7:        return "7"
        case .num8:        return "8"
        case .num9:        return "9"
        case .input:       return "Input"
        }
    }

    var systemImageName: String? {
        switch self {
        case .power:       return "power"
        case .volumeUp:    return "speaker.plus.fill"
        case .volumeDown:  return "speaker.minus.fill"
        case .mute:        return "speaker.slash.fill"
        case .channelUp:   return "chevron.up"
        case .channelDown: return "chevron.down"
        case .up:          return "chevron.up"
        case .down:        return "chevron.down"
        case .left:        return "chevron.left"
        case .right:       return "chevron.right"
        case .home:        return "house.fill"
        case .back:        return "arrow.uturn.left"
        case .options:     return "ellipsis"
        case .menu:        return "list.bullet"
        case .play:        return "play.fill"
        case .pause:       return "pause.fill"
        case .stop:        return "stop.fill"
        case .rewind:      return "backward.fill"
        case .forward:     return "forward.fill"
        case .input:       return "rectangle.connected.to.line.below"
        default:           return nil
        }
    }
}
