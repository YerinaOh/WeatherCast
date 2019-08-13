//
//  DatabaseService.swift
//  WeatherCast
//
//  Created by yerinaoh on 11/08/2019.
//  Copyright © 2019 yerinaoh. All rights reserved.
//

import UIKit
import SQLite3

class DatabaseService {
    
    static let shared = DatabaseService()
    
    static let createSQL = "CREATE TABLE IF NOT EXISTS WEATHER (id INTEGER PRIMARY KEY AUTOINCREMENT, city TEXT NOT NULL, address TEXT, latitude REAL, longitude REAL, cityid INT)"
    static let insertSQL = "INSERT INTO WEATHER (city, address, latitude, longitude, cityid) VALUES (?,?,?,?,?)"
    static let readSQL   = "SELECT * FROM WEATHER ORDER BY ID"
    static let deleteSQL   = "DELETE FROM WEATHER WHERE cityid = ?"
    
    var dbURL: URL
    var db: OpaquePointer?

    init() {
        do {
            do {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("weather.db")
                
            } catch {
                dbURL = URL(fileURLWithPath: "")
                return
            }
            
            try openDB()
            try createTables()
        } catch {
            print("db init error")
            return
        }
    }
}

// MARK: - init/deinit DB
extension DatabaseService {
    func openDB() throws {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    func deleteDB(dbURL: URL) {
        do {
            try FileManager.default.removeItem(at: dbURL)
        } catch {
            print(error.localizedDescription)
        }
    }
    func createTables() throws {
        let ret =  sqlite3_exec(db, DatabaseService.createSQL, nil, nil, nil)
        if (ret != SQLITE_OK) {
            throw SqliteError(message: "unable to create table IMAGES")
        }
    }
}

// MARK: - CRUD DB
extension DatabaseService {
    
    func insert(source: RegionModel, completion :@escaping (Bool) -> ()) {
        
        let insertStatementString = DatabaseService.insertSQL
        var insertEntryStmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertEntryStmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(insertEntryStmt, 1, (source.city! as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertEntryStmt, 2, (source.address! as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertEntryStmt, 3, (Double(source.latitude! as Double)))
            sqlite3_bind_double(insertEntryStmt, 4, (Double(source.longitude! as Double)))
            sqlite3_bind_int(insertEntryStmt, 5, (Int32(source.id! as Int)))
                
            if sqlite3_step(insertEntryStmt) != SQLITE_DONE {
                completion(false)
            }
        } else {
            completion(false)
        }
        sqlite3_finalize(insertEntryStmt)
        completion(true)
    }
    
    func read(completion :@escaping ([RegionModel], Bool) -> ()) {
        
        let queryStatementString = DatabaseService.readSQL
        var readEntryStmt: OpaquePointer?
        
        var sourceArray: [RegionModel] = [RegionModel]()
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &readEntryStmt, nil) == SQLITE_OK {
            
            while sqlite3_step(readEntryStmt) == SQLITE_ROW {
                
                let city: String = String(cString: sqlite3_column_text(readEntryStmt, 1))
                let address: String = String(cString: sqlite3_column_text(readEntryStmt, 2))
                let latitude: Double = sqlite3_column_double(readEntryStmt, 3)
                let longitude: Double = sqlite3_column_double(readEntryStmt, 4)
                let id: Int = Int(sqlite3_column_int(readEntryStmt, 5))
                let sourceModel: RegionModel = RegionModel.init(city: city, address: address, latitude: latitude, longitude: longitude, id: id)
                
                sourceArray.append(sourceModel)
            }
        } else {
            completion(sourceArray, false)
        }
        sqlite3_finalize(readEntryStmt)
        
        completion(sourceArray, true)
    }
    
    func delete(cityId: Int, completion :@escaping (Bool) -> ()) {
        
        let queryStatementString = DatabaseService.deleteSQL
        var deleteEntryStmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &deleteEntryStmt, nil) == SQLITE_OK {
            
            if sqlite3_bind_int(deleteEntryStmt, 1, (Int32(cityId))) != SQLITE_OK {
                completion(false)
                return
            }
            
            let r = sqlite3_step(deleteEntryStmt)
            if r != SQLITE_DONE {
                completion(false)
                return
            }
        }
        sqlite3_finalize(deleteEntryStmt)
        completion(true)
    }
}

class SqliteError: Error {
    var message = ""
    var error = SQLITE_ERROR
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}
