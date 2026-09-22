// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation
import SQLite3

enum ItemLinkSupportTests {
    static func run(_ suite: TestSuite) {
        suite.expect(ItemLinkSupport.mailURL(messageID: "message@example.com")?.absoluteString
                        == "message://%3Cmessage@example.com%3E",
                     "Mail message IDs become message URLs")
        suite.expect(ItemLinkSupport.mailURL(messageID: " <message@example.com> \n")?.absoluteString
                        == "message://%3Cmessage@example.com%3E",
                     "Mail message IDs accept surrounding brackets and whitespace")
        suite.expect(ItemLinkSupport.mailURL(messageID: "") == nil,
                     "empty Mail message IDs are rejected")

        suite.expect(ItemLinkSupport.notePrimaryKey(
            from: "x-coredata://ABC/ICNote/p123") == 123,
                     "Apple Notes object IDs expose their database primary key")
        suite.expect(ItemLinkSupport.notePrimaryKey(
            from: "x-coredata://ABC/ICNote/p0") == nil,
                     "invalid Apple Notes primary keys are rejected")
        suite.expect(ItemLinkSupport.notePrimaryKey(
            from: "x-coredata://ABC/ICFolder/p123") == nil,
                     "non-note Apple Notes object IDs are rejected")

        let identifier = "a3b03596-77cd-452c-a88b-6bb751a13176"
        suite.expect(ItemLinkSupport.noteURL(identifier: identifier)?.absoluteString
                        == "applenotes:note/A3B03596-77CD-452C-A88B-6BB751A13176",
                     "Apple Notes identifiers become direct note URLs")
        suite.expect(ItemLinkSupport.noteURL(identifier: "not-a-uuid") == nil,
                     "malformed Apple Notes identifiers are rejected")

        let links = [URL(string: "message://one")!, URL(string: "applenotes:note/TWO")!]
        suite.expect(ItemLinkSupport.clipboardText(links)
                        == "message://one\napplenotes:note/TWO",
                     "multiple selected items produce one link per line")
        suite.expect(ItemLinkSupport.clipboardText([]) == nil,
                     "an empty selection does not overwrite the clipboard")

        let databaseURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("vorssaint-item-links-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: databaseURL) }
        var database: OpaquePointer?
        suite.expect(sqlite3_open(databaseURL.path, &database) == SQLITE_OK,
                     "the Notes lookup fixture opens")
        if let database {
            defer { sqlite3_close(database) }
            let uuid = "A3B03596-77CD-452C-A88B-6BB751A13176"
            suite.expect(sqlite3_exec(database,
                "CREATE TABLE ZICCLOUDSYNCINGOBJECT (Z_PK INTEGER PRIMARY KEY, ZIDENTIFIER TEXT);",
                nil, nil, nil) == SQLITE_OK,
                         "the Notes lookup fixture creates the expected schema")
            suite.expect(sqlite3_exec(database,
                "INSERT INTO ZICCLOUDSYNCINGOBJECT (Z_PK, ZIDENTIFIER) VALUES (123, '\(uuid)');",
                nil, nil, nil) == SQLITE_OK,
                         "the Notes lookup fixture inserts a stable identifier")
        }
        suite.expect(NoteLinkStore.identifiers(for: [123, 999], databaseURL: databaseURL)
                        == ["A3B03596-77CD-452C-A88B-6BB751A13176"],
                     "the Notes adapter resolves matching rows and skips missing rows")

        let changedSchemaURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("vorssaint-item-links-schema-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: changedSchemaURL) }
        var changedSchema: OpaquePointer?
        if sqlite3_open(changedSchemaURL.path, &changedSchema) == SQLITE_OK,
           let changedSchema {
            _ = sqlite3_exec(changedSchema, "CREATE TABLE OTHER (VALUE TEXT);", nil, nil, nil)
            sqlite3_close(changedSchema)
        }
        suite.expect(NoteLinkStore.identifiers(for: [123], databaseURL: changedSchemaURL).isEmpty,
                     "a changed Notes schema fails closed")
        suite.expect(NoteLinkStore.identifiers(for: [123], databaseURL: databaseURL
            .appendingPathExtension("missing")).isEmpty,
                     "an inaccessible Notes database fails closed")
    }
}
