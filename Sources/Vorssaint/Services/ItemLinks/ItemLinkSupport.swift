// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

enum ItemLinkSupport {
    static func mailURL(messageID raw: String) -> URL? {
        var id = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if id.hasPrefix("<"), id.hasSuffix(">"), id.count > 2 {
            id.removeFirst()
            id.removeLast()
        }
        guard !id.isEmpty, !id.contains(where: { $0.isNewline }) else { return nil }
        let wrapped = "<\(id)>"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~@")
        guard let encoded = wrapped.addingPercentEncoding(withAllowedCharacters: allowed) else { return nil }
        return URL(string: "message://\(encoded)")
    }

    static func notePrimaryKey(from raw: String) -> Int64? {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let marker = value.range(of: "/ICNote/p", options: .backwards),
              marker.upperBound < value.endIndex else { return nil }
        let suffix = value[marker.upperBound...]
        guard suffix.allSatisfy(\.isNumber), let key = Int64(suffix), key > 0 else { return nil }
        return key
    }

    static func noteURL(identifier raw: String) -> URL? {
        let identifier = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard UUID(uuidString: identifier) != nil else { return nil }
        return URL(string: "applenotes:note/\(identifier.uppercased())")
    }

    static func clipboardText(_ urls: [URL]) -> String? {
        let values = urls.map(\.absoluteString)
        return values.isEmpty ? nil : values.joined(separator: "\n")
    }
}
