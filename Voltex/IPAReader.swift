import Foundation
import Compression
import UIKit

/// Reads a .ipa (which is just a zip) and digs out the app's display name and icon.
/// Everything here is best-effort: anything unexpected returns nil and the caller
/// falls back to the file name and a generic icon.
enum IPAReader {
    struct Result {
        var name: String?
        var icon: UIImage?
        var bundleID: String?
        var version: String?
    }

    private struct Entry {
        let name: String
        let method: UInt16
        let compressedSize: Int
        let uncompressedSize: Int
        let localOffset: Int
    }

    static func inspect(_ url: URL) -> Result {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return Result() }
        defer { try? handle.close() }

        guard let end = try? handle.seekToEnd() else { return Result() }
        let fileSize = Int(end)
        guard fileSize > 22 else { return Result() }

        let entries = centralDirectory(handle: handle, fileSize: fileSize)
        guard !entries.isEmpty else { return Result() }

        var result = Result()

        if let info = entries.first(where: { $0.name.hasSuffix(".app/Info.plist") }),
           let data = extract(info, handle: handle),
           let plist = (try? PropertyListSerialization.propertyList(from: data, options: [], format: nil)) as? [String: Any] {
            result.name = (plist["CFBundleDisplayName"] as? String)
                ?? (plist["CFBundleName"] as? String)
            result.bundleID = plist["CFBundleIdentifier"] as? String
            result.version = plist["CFBundleShortVersionString"] as? String
        }

        let icons = entries.filter { $0.name.hasSuffix(".png") && $0.name.contains("AppIcon") }
        let best = icons.max { $0.uncompressedSize < $1.uncompressedSize }
        if let best, let data = extract(best, handle: handle) {
            result.icon = UIImage(data: data)
        }

        return result
    }

    // MARK: - zip central directory

    private static func centralDirectory(handle: FileHandle, fileSize: Int) -> [Entry] {
        let tailLength = min(fileSize, 66_000)
        guard let tailData = read(handle, at: fileSize - tailLength, length: tailLength) else { return [] }
        let tail = [UInt8](tailData)

        guard let eocd = findEOCD(tail), eocd + 22 <= tail.count else { return [] }

        let count = Int(le16(tail, eocd + 10))
        let directoryOffset = Int(le32(tail, eocd + 16))
        guard directoryOffset >= 0, directoryOffset < fileSize, count > 0, count < 10_000 else { return [] }

        let directoryLength = min(fileSize - directoryOffset, 8_000_000)
        guard let directoryData = read(handle, at: directoryOffset, length: directoryLength) else { return [] }
        let bytes = [UInt8](directoryData)

        var entries: [Entry] = []
        var p = 0

        for _ in 0..<count {
            guard p + 46 <= bytes.count, le32(bytes, p) == 0x02014b50 else { break }

            let method = le16(bytes, p + 10)
            let compressedSize = Int(le32(bytes, p + 20))
            let uncompressedSize = Int(le32(bytes, p + 24))
            let nameLength = Int(le16(bytes, p + 28))
            let extraLength = Int(le16(bytes, p + 30))
            let commentLength = Int(le16(bytes, p + 32))
            let localOffset = Int(le32(bytes, p + 42))

            guard p + 46 + nameLength <= bytes.count else { break }

            let nameBytes = Array(bytes[(p + 46)..<(p + 46 + nameLength)])
            let name = String(decoding: nameBytes, as: UTF8.self)

            if compressedSize != 0xFFFF_FFFF, localOffset != 0xFFFF_FFFF, !name.isEmpty {
                entries.append(Entry(name: name,
                                     method: method,
                                     compressedSize: compressedSize,
                                     uncompressedSize: uncompressedSize,
                                     localOffset: localOffset))
            }

            p += 46 + nameLength + extraLength + commentLength
        }

        return entries
    }

    private static func findEOCD(_ bytes: [UInt8]) -> Int? {
        guard bytes.count >= 22 else { return nil }
        var i = bytes.count - 22
        while i >= 0 {
            if bytes[i] == 0x50, bytes[i + 1] == 0x4B, bytes[i + 2] == 0x05, bytes[i + 3] == 0x06 {
                return i
            }
            i -= 1
        }
        return nil
    }

    // MARK: - entry extraction

    private static func extract(_ entry: Entry, handle: FileHandle) -> Data? {
        guard entry.compressedSize > 0,
              entry.uncompressedSize > 0,
              entry.uncompressedSize < 40_000_000 else { return nil }

        guard let headerData = read(handle, at: entry.localOffset, length: 30) else { return nil }
        let header = [UInt8](headerData)
        guard header.count >= 30, le32(header, 0) == 0x04034b50 else { return nil }

        let nameLength = Int(le16(header, 26))
        let extraLength = Int(le16(header, 28))
        let dataOffset = entry.localOffset + 30 + nameLength + extraLength

        guard let raw = read(handle, at: dataOffset, length: entry.compressedSize) else { return nil }

        if entry.method == 0 { return raw }
        guard entry.method == 8 else { return nil }
        return inflate(raw, expected: entry.uncompressedSize)
    }

    /// Zip stores raw deflate; zlib's decoder wants a zlib wrapper, so we fake one.
    private static func inflate(_ raw: Data, expected: Int) -> Data? {
        guard !raw.isEmpty, expected > 0 else { return nil }

        var wrapped = Data([0x78, 0x9C])
        wrapped.append(raw)
        wrapped.append(contentsOf: [0x00, 0x00, 0x00, 0x00])

        var output = Data(count: expected)
        let written = output.withUnsafeMutableBytes { destination -> Int in
            wrapped.withUnsafeBytes { source -> Int in
                guard let dst = destination.bindMemory(to: UInt8.self).baseAddress,
                      let src = source.bindMemory(to: UInt8.self).baseAddress else { return 0 }
                return compression_decode_buffer(dst, expected, src, wrapped.count,
                                                 nil, COMPRESSION_ZLIB)
            }
        }

        guard written > 0 else { return nil }
        return output.prefix(written)
    }

    // MARK: - byte helpers

    private static func read(_ handle: FileHandle, at offset: Int, length: Int) -> Data? {
        guard offset >= 0, length > 0 else { return nil }
        do {
            try handle.seek(toOffset: UInt64(offset))
            let data = handle.readData(ofLength: length)
            return data.isEmpty ? nil : data
        } catch {
            return nil
        }
    }

    private static func le16(_ bytes: [UInt8], _ i: Int) -> UInt16 {
        guard i + 2 <= bytes.count else { return 0 }
        return UInt16(bytes[i]) | (UInt16(bytes[i + 1]) << 8)
    }

    private static func le32(_ bytes: [UInt8], _ i: Int) -> UInt32 {
        guard i + 4 <= bytes.count else { return 0 }
        return UInt32(bytes[i])
            | (UInt32(bytes[i + 1]) << 8)
            | (UInt32(bytes[i + 2]) << 16)
            | (UInt32(bytes[i + 3]) << 24)
    }
}
