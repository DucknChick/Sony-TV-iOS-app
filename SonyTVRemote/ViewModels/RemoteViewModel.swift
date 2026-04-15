import Foundation

@MainActor
final class RemoteViewModel: ObservableObject {
    @Published var tv: SonyTV
    @Published var lastError: String?
    @Published var isSending: Bool = false
    @Published var availableInputs: [TVInput] = []
    @Published var isLoadingInputs: Bool = false

    private let commandService: TVCommandService
    private let persistence: TVPersistenceService

    init(tv: SonyTV, commandService: TVCommandService, persistence: TVPersistenceService) {
        self.tv = tv
        self.commandService = commandService
        self.persistence = persistence
    }

    func tap(_ command: IRCCCommand) {
        Task {
            do {
                try await commandService.send(command, to: tv)
            } catch IRCCError.notAuthorized {
                lastError = "Not authorized. Please re-pair with your TV."
            } catch IRCCError.commandFailed {
                // HTTP 500 means the command isn't applicable in the current TV context
                // (e.g. CH+ while in a streaming app). This is normal — silently ignore.
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    func powerOn() {
        Task {
            do {
                try await commandService.powerOn(tv: tv)
            } catch IRCCError.commandFailed {
                // Silently ignore — TV may already be on or transitioning
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    func powerOff() {
        Task {
            do {
                try await commandService.powerOff(tv: tv)
            } catch IRCCError.commandFailed {
                // Silently ignore — TV may already be off or transitioning
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    func loadInputList() {
        guard !isLoadingInputs else { return }
        isLoadingInputs = true
        Task {
            do {
                availableInputs = try await commandService.getInputList(tv: tv)
            } catch {
                // Input list is optional; don't show error for this
                availableInputs = []
            }
            isLoadingInputs = false
        }
    }

    func selectInput(_ input: TVInput) {
        Task {
            do {
                try await commandService.setInput(input, tv: tv)
            } catch {
                lastError = error.localizedDescription
            }
        }
    }

    func dismissError() {
        lastError = nil
    }
}
