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
    private var itemvariable_text: Expression<String?>!
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
            itemvariable_text = Expression<String?>("itemvariable_text")
            itemvariable_item = Expression<Int64>("itemvariable_item")
            itemvariable_variable = Expression<Int64>("itemvariable_variable")
            
            try db.prepare(#"PRAGMA foreign_keys = ON;"#)

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
            if (db.userVersion == 0) {
                let variableIndex = try db.run(variable.createIndex(variable_id))
                let itemIndex = try db.run(item.createIndex(item_id))
                
                // Composite index on (itemvariable_variable, itemvariable_item)
                let itemVariableIndex = try db.run(itemvariable.createIndex(itemvariable_variable, itemvariable_item))
                
                // Index on item_review
                let itemReviewIndex = try db.run(item.createIndex(item_review))
                db.userVersion = 1
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
    
    func getItemByPK(pk: Int64) -> Item? {
        do {
            let item_pk = try db.prepare(#"SELECT * FROM "item" WHERE "item_id" = ?"#)
            
            for i in item_pk.bind(pk) {
                let itemModel = Item(item_id: i[0] as! Int64, item_title: i[1] as! String, item_review: i[2] as! Double, item_group: i[3] as! Int64)
                item_pk.reset()
                return itemModel
            }
            item_pk.reset()
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func modifyItemByPK(title: String,rating:Double, pk: Int64) -> Item? {
        do {
            let currentItem = item.filter(item_id == pk)
            try db.run(currentItem.update(
                    item_title <- title,
                    item_review <- rating
                ))
            return getItemByPK(pk: pk)
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getItemVariableByPK(pk: Int64) -> ItemVariables?{
        do {
            let itemvar_pk = try db.prepare(#"SELECT * FROM "itemvariable" WHERE "itemvariable_id" = ?"#)
            
            for i in itemvar_pk.bind(pk) {
                let itemVarModel = ItemVariables(iv_id: i[0] as! Int64, iv_text: i[1] as! String?, iv_item: i[2] as! Int64, iv_variable: i[3] as! Int64)
                itemvar_pk.reset()
                return itemVarModel
            }
            itemvar_pk.reset()
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getItemsByRating(id: Int64, rating: Double) -> [Item]{
        var itemModels: [Item] = []
        
        do {
            for row in try db.prepare(item.filter(and(item_group == id, item_review >= rating))) {
                let variableModel: Item = Item(item_id: row[item_id], item_title: row[item_title], item_review: row[item_review], item_group: row[item_group])
                
                itemModels.append(variableModel)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return itemModels
    }
    
    func getItems(id: Int64) -> [Item] {
        var itemModels: [Item] = []
        
        do {
            for row in try db.prepare(item.filter(item_group == id)) {
                let variableModel: Item = Item(item_id: row[item_id], item_title: row[item_title], item_review: row[item_review], item_group: row[item_group])
                
                itemModels.append(variableModel)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return itemModels
    }

    
    func modifyItemVariableByPK(text: String, pk: Int64) -> ItemVariables? {
        do {
            let currentItemVariable = itemvariable.filter(itemvariable_id == pk)
            try db.run(currentItemVariable.update(
                    itemvariable_text <- text
                ))
            return getItemVariableByPK(pk:pk)
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
    
    func getVariable(pk: Int64) -> Variable? {
        do {
            var variableModel: Variable? = nil;
            do {
                for variable_row in try db.prepare(variable.filter(variable_id == pk)) {
                    variableModel = Variable(variable_id: variable_row[variable_id], variable_group: variable_row[variable_group], variable_type: variable_row[variable_type], variable_name: variable_row[variable_name])
                }
            }
            return variableModel!
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func getVariables(id: Int64) -> [Variable] {
        var variableModels: [Variable] = []
        
        do {
            for row in try db.prepare(variable.filter(variable_group == id)) {
                let variableModel: Variable = Variable(variable_id: row[variable_id], variable_group: row[variable_group], variable_type: row[variable_type], variable_name: row[variable_name])
                
                variableModels.append(variableModel)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return variableModels
    }
    
    func findStatistics(rating: Double, group: Group, variables:[Variable]) -> [(String, Double)] {
        let newVars = variables.filter { variable in
            return variable.variable_type == 0
        }
        var statistics:[(String,Double)] = []
        
        for currentVariable in newVars {
            let variableName = currentVariable.variable_name
            let variableID = currentVariable.variable_id
            do {
                let itemvar_pk = try db.prepare(#"SELECT V.variable_id, AVG(CAST(IV.itemvariable_text AS DECIMAL)) FROM "variable" as V JOIN "itemvariable" AS IV JOIN ITEM AS I ON V.variable_id = IV.itemvariable_variable AND IV.itemvariable_item = I.item_id WHERE V.variable_id = ? AND I.item_review >= ? GROUP BY V.variable_id"#)
                
                for i in itemvar_pk.bind(variableID, rating) {
                    statistics.append((variableName, i[1] as! Double))
                }
                itemvar_pk.reset()

            }
            catch {
                print(error.localizedDescription)
            }
        }
        return statistics
    }
    
    func getVariables() -> [Variable] {
        var variableModels: [Variable] = []
        
        do {
            for row in try db.prepare(variable) {
                let variableModel: Variable = Variable(variable_id: row[variable_id], variable_group: row[variable_group], variable_type: row[variable_type], variable_name: row[variable_name])
                
                variableModels.append(variableModel)
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return variableModels
    }
    
    func createItem(group: Group, variables:[Variable]) -> (Item, [ItemVariables])? {
        
        do {
            var newItem:Item!
            var itemVars:[ItemVariables] = []

            try db.transaction {
                let row_id = try db.run(
                    item.insert(
                        item_title <- "",
                        item_review <- 0.0,
                        item_group <- group.group_id
                    )
                )
                                
                for i in try db.prepare(item.filter(item_id == row_id)) {
                    newItem = Item(item_id: i[item_id], item_title: i[item_title], item_review: i[item_review], item_group: i[item_group])
                }
                                
                for itemVar in variables {
                    let newItemVariableModel:ItemVariables? = createItemVariable(variable: itemVar, newItem: newItem)
                    if let newItemVariableModel = newItemVariableModel {
                        itemVars.append(newItemVariableModel)
                    }
                }
            }
            return (newItem, itemVars)

        }
        catch {
            print(error.localizedDescription)
        }
        return nil
        
    }
    
    
    
    func createItemVariable(variable: Variable, newItem:Item) -> ItemVariables? {
        do {
            
            let row_id = try db.run(
                itemvariable.insert(
                    itemvariable_item <- newItem.item_id,
                    itemvariable_text <- nil,
                    itemvariable_variable <- variable.variable_id
                )
            )
            
            var newItemVariable:ItemVariables!
            
            for i in try db.prepare(itemvariable.filter(itemvariable_id == row_id)) {
                newItemVariable = ItemVariables(iv_id: i[itemvariable_id], iv_item: i[itemvariable_item], iv_variable: i[itemvariable_variable])
            }
            return newItemVariable
        }
        catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func createVariable(name: String, type: Int64, group_id: Int64) -> Variable?{
        do {
            let row_id = try db.run(
                variable.insert(
                    variable_group <- group_id,
                    variable_name <- name,
                    variable_type <- type
                )
            )
            return getVariable(pk: row_id)
            
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
    
    func deleteGroupByPK(pk: Int64) -> Bool {
        do {
            let group = group.filter(group_id == pk)
            try db.run(group.delete())
            return true
        }
        catch {
            print(error.localizedDescription)
            return false;
        }
        
    }
}
