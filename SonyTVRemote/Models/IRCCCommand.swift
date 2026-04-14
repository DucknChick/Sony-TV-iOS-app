import Foundation

enum IRCCCommand: String, CaseIterable, Identifiable {
    // Power
    case power        = "AAAAAQAAAAEAAAAVAw=="

    // Volume
    case volumeUp     = "AAAAAQAAAAEAAAASAw=="
    case volumeDown   = "AAAAAQAAAAEAAAATAw=="
    case mute         = "AAAAAQAAAAEAAAAUAw=="

    // Channel
    case channelUp    = "AAAAAQAAAAEAAAAQAw=="
    case channelDown  = "AAAAAQAAAAEAAAARAw=="

    // D-Pad
    case up           = "AAAAAQAAAAEAAAB0Aw=="
    case down         = "AAAAAQAAAAEAAAB1Aw=="
    case left         = "AAAAAQAAAAEAAAB2Aw=="
    case right        = "AAAAAQAAAAEAAAB3Aw=="
    case confirm      = "AAAAAQAAAAEAAABlAw=="

    // Navigation
    case home         = "AAAAAQAAAAEAAABgAw=="
    case back         = "AAAAAgAAAJcAAAAjAw=="
    case options      = "AAAAAgAAAJcAAAA2Aw=="
    case menu         = "AAAAAQAAAAEAAAADAw=="

    // Media
    case play         = "AAAAAgAAAJcAAAAaAw=="
    case pause        = "AAAAAgAAAJcAAAAZAw=="
    case stop         = "AAAAAgAAAJcAAAAYAw=="
    case rewind       = "AAAAAgAAAJcAAAAbAw=="
    case forward      = "AAAAAgAAAJcAAAAcAw=="

    // Numeric
    case num0         = "AAAAAQAAAAEAAAAJAw=="
    case num1         = "AAAAAQAAAAEAAAAKAw=="
    case num2         = "AAAAAQAAAAEAAAALAw=="
    case num3         = "AAAAAQAAAAEAAAAMAw=="
    case num4         = "AAAAAQAAAAEAAAANAw=="
    case num5         = "AAAAAQAAAAEAAAAOAw=="
    case num6         = "AAAAAQAAAAEAAAAPAw=="
    case num7         = "AAAAAQAAAAEAAAAQAw=="
    case num8         = "AAAAAQAAAAEAAAARAw=="
    case num9         = "AAAAAQAAAAEAAAASAw=="

    // Input
    case input        = "AAAAAQAAAAEAAAAlAw=="

    var id: String { rawValue }

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
        case .confirm:     return nil
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
