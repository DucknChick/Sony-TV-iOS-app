import Foundation

final class TVCommandService {
    private let ircc: IRCCClient
    private let rest: SonyRESTClient
    private let wol: WakeOnLANClient

    init(
        ircc: IRCCClient = IRCCClient(),
        rest: SonyRESTClient = SonyRESTClient(),
        wol: WakeOnLANClient = WakeOnLANClient()
    ) {
        self.ircc = ircc
        self.rest = rest
        self.wol = wol
    }

    func send(_ command: IRCCCommand, to tv: SonyTV) async throws {
        try await ircc.sendCommand(command, to: tv)
    }

    func powerOn(tv: SonyTV) async throws {
        if let mac = tv.macAddress {
            try await wol.wake(macAddress: mac)
        } else {
            try await ircc.sendCommand(.power, to: tv)
        }
    }

    func powerOff(tv: SonyTV) async throws {
        try await ircc.sendCommand(.power, to: tv)
    }

    func getInputList(tv: SonyTV) async throws -> [TVInput] {
        try await rest.getInputList(tv: tv)
    }

    func setInput(_ input: TVInput, tv: SonyTV) async throws {
        try await rest.request(
            service: .avContent,
            method: "setPlayContent",
            params: [["uri": input.uri]],
            tv: tv
        )
    }
}
