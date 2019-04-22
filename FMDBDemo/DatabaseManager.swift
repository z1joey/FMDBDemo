//
//  DatabaseManager.swift
//  FMDBDemo
//
//  Created by Yi Zhang on 2019/4/22.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import UIKit
import FMDB

class DatabaseManager: NSObject
{
    static let shared = DatabaseManager.init()
    
    var database: FMDatabase? = nil
    
    private let tableName = "yi"
    
    override init() {
        super.init()
        createTableIfNeeded()
    }
    
    private func createTableIfNeeded() {
        let fileURL = try! FileManager.default.url(for: .applicationDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("test.sqlite")
                
        database = FMDatabase(url: fileURL)
        
        guard database!.open() else {
            assert(false, "failed to open database")
            return
        }

        do {
            try database?.executeUpdate("create table if not exists \(tableName)(x text, y text, z text)", values: nil)
            database?.close()
        } catch {
            print(error.localizedDescription)
        }
        database?.close()
    }
    
    func insertData() {
        if database!.open() {
            do {
                try database?.executeUpdate("insert into \(tableName)(x, y, z) values (?, ?, ?)", values: ["a","b","c"])
                try database?.executeUpdate("insert into \(tableName)(x, y, z) values (?, ?, ?)", values: ["d","e","f"])
            } catch {
                database?.close()
                assert(false, error.localizedDescription)
            }
        } else {
            assert(false, "failed to open database in insertData")
            database?.close()
        }
    }
    
    func getResult() {
        if database!.open() {
            do {
                guard let rs = try database?.executeQuery("select x, y, z from \(tableName)", values: nil) else {
                    database?.close()
                    return
                }
                
                while rs.next() {
                    if let x = rs.string(forColumn: "x"), let y = rs.string(forColumn: "y"), let z = rs.string(forColumn: "z") {
                        print("--\(x)--\n--\(y)--\n--\(z)--\n")
                        database?.close()
                    }
                }
            } catch {
                assert(false, error.localizedDescription)
                database?.close()
            }
        }
    }
}
