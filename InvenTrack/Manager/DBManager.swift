//
//  DBManager.swift
//  InvenTrack
//
//  Created by Akhil Thata on 10/29/23.
//

import Foundation
import SQLite

final class DBManager {
    static let shared = DBManager()
    
    private var db: Connection!
    
    //Group
    private var group: Table!
    private var group_id: Expression<Int64>!
    private var group_title: Expression<String>!
    
    //Variables
    private var variable: Table!
    private var variable_id: Expression<Int64>!
    private var variable_type: Expression<Int64>!
    private var variable_name: Expression<String>!
    private var variable_group: Expression<Int64>!
    
    //Item
    private var item: Table!
    private var item_id: Expression<Int64>!
    private var item_title: Expression<String>!
    private var item_review: Expression<Double>!
    private var item_group: Expression<Int64>!
    
    //Item Variable
    private var itemvariable: Table!
    private var itemvariable_id: Expression<Int64>!
    private var itemvariable_text: Expression<String>!
    private var itemvariable_item: Expression<Int64>!
    private var itemvariable_variable: Expression<Int64>!
    
    private init() {
        do {
            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            db = try Connection("\(path)/inventory.sqlite3")
            
            
            group = Table("group")
            group_id = Expression<Int64>("group_id")
            group_title = Expression<String>("group_title")
            
            variable = Table("variable")
            variable_id = Expression<Int64>("variable_id")
            variable_type = Expression<Int64>("variable_type")
            variable_name = Expression<String>("variable_name")
            variable_group = Expression<Int64>("variable_group")
            
            item = Table("item")
            item_id = Expression<Int64>("item_id")
            item_title = Expression<String>("item_title")
            item_review = Expression<Double>("item_review")
            item_group = Expression<Int64>("item_group")
            
            //Item Variable
            itemvariable = Table("itemvariable")
            itemvariable_id = Expression<Int64>("itemvariable_id")
            itemvariable_text = Expression<String>("itemvariable_text")
            itemvariable_item = Expression<Int64>("itemvariable_item")
            itemvariable_variable = Expression<Int64>("itemvariable_variable")
            
            if (!UserDefaults.standard.bool(forKey: "is_db_created")) {
                try db.run(group.create(ifNotExists: true) { (t) in
                        t.column(group_id, primaryKey: .autoincrement)
                        t.column(group_title)
                    }
                )
                
                
                try db.run(variable.create(ifNotExists: true) { (t) in
                        t.column(variable_id, primaryKey: .autoincrement)
                        t.column(variable_type)
                        t.column(variable_name)
                        t.column(variable_group)
                        
                        t.foreignKey(variable_group, references: group, group_id, delete: .cascade)
                    }
                )
                
                try db.run(item.create(ifNotExists: true) { (t) in
                        t.column(item_id, primaryKey: .autoincrement)
                        t.column(item_title)
                        t.column(item_review)
                        t.column(item_group)
                        t.foreignKey(item_group, references: group,group_id, delete: .cascade)
                    }
                )
                
                try db.run(itemvariable.create(ifNotExists: true) { (t) in
                        t.column(itemvariable_id, primaryKey: .autoincrement)
                        t.column(itemvariable_text)
                        t.column(itemvariable_item)
                        t.column(itemvariable_variable)
                    
                        t.foreignKey(itemvariable_item, references: item, item_id, delete: .cascade)
                        t.foreignKey(itemvariable_variable, references: variable, variable_id, delete: .cascade)
                    }
                )
                UserDefaults.standard.set(true, forKey: "is_db_created")
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func getGroupByPK(row_id: Int64) -> Group? {
        do {
            let group_pk = try db.prepare(#"SELECT * FROM "group" WHERE "group_id" = ?"#)
            
            for group in group_pk.bind(row_id) {
                let groupModel = Group(group_id: group[0] as! Int64, group_title: group[1] as! String)
                group_pk.reset()
                return groupModel
            }
            group_pk.reset()
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func modifyGroupNameByPK(name: String, pk: Int64) -> Group? {
        do {
            let group = group.filter(group_id == pk)
            try db.run(group.update(group_title <- name))
            return getGroupByPK(row_id: pk)
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func addGroup(name: String) -> Group? {
        do {
            let row_id = try db.run(
                group.insert(
                    group_title <- name
                )
            )
            return getGroupByPK(row_id: row_id)
            
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getGroups() -> [Group] {
        var groupModels: [Group] = []
        
        let groups = group.order(group_id.desc)
        do {
            for group in try db.prepare(groups) {
                let groupModel: Group = Group(group_id: group[group_id], group_title: group[group_title])
                
                groupModels.append(groupModel)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return groupModels
    }
}
