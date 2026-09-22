// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation
import SQLite3

/// The smallest possible adapter around Apple Notes' private local schema.
/// A missing file, denied access or schema change returns no identifiers and
/// leaves the caller's clipboard untouched.
enum NoteLinkStore {
    static func identifiers(for keys: [Int64], databaseURL: URL) -> [String] {
        guard !keys.isEmpty else { return [] }
        var database: OpaquePointer?
        guard sqlite3_open_v2(databaseURL.path, &database, SQLITE_OPEN_READONLY, nil) == SQLITE_OK,
              let database else {
            if database != nil { sqlite3_close(database) }
            return []
        }
        defer { sqlite3_close(database) }

        var statement: OpaquePointer?
        let sql = "SELECT ZIDENTIFIER FROM ZICCLOUDSYNCINGOBJECT WHERE Z_PK = ? LIMIT 1"
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else { return [] }
        defer { sqlite3_finalize(statement) }

        var values: [String] = []
        for key in keys where key > 0 {
            sqlite3_reset(statement)
            sqlite3_clear_bindings(statement)
            guard sqlite3_bind_int64(statement, 1, key) == SQLITE_OK,
                  sqlite3_step(statement) == SQLITE_ROW,
                  let value = sqlite3_column_text(statement, 0) else { continue }
            values.append(String(cString: value))
        }
        return values
    }
}
