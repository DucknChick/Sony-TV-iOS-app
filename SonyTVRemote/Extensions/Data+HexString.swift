import Foundation

extension Data {
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }

    init?(hexString: String) {
        let stripped = hexString.replacingOccurrences(of: " ", with: "")
        guard stripped.count % 2 == 0 else { return nil }
        var bytes = [UInt8]()
        bytes.reserveCapacity(stripped.count / 2)
        var index = stripped.startIndex
        while index < stripped.endIndex {
            let nextIndex = stripped.index(index, offsetBy: 2)
            guard let byte = UInt8(stripped[index..<nextIndex], radix: 16) else { return nil }
            bytes.append(byte)
            index = nextIndex
        }
        self = Data(bytes)
    }
}
