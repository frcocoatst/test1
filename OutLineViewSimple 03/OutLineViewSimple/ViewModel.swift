//
//  ViewModel.swift
//  OutlineViewDemo
//
//

import Foundation

class ViewModel {
    
    // MARK: - Properties
    
    var model = Model()
    
    
    // MARK: - Init
    
    init() {
        
    }
    
    
    // MARK: - Custom Methods
    
    /**
     Create a new collection with the given title. If the `construction`
     parameter values has been provided, then add it as an item to that
     construction. Otherwise append it to the constructions array of the `model`
     property as a top level collection.
     */
    func createConstruction(withTitle title: String, ctag: String, clength: Int, cvalue: String, ccomment: String , inConstruction construction: Construction?) {
        if let construction = construction {
            //construction.items.append(Construction(withTitle: title, id: model.getConstructionID()))
            
            construction.items.append(Construction(withTitle: title, ctag:ctag, clength:clength, cvalue:cvalue, ccomment:ccomment ,id: model.getConstructionID(), parent: construction))
        } else {
            model.constructions.append(Construction(withTitle: title, ctag:ctag, clength:clength, cvalue:cvalue, ccomment:ccomment , id: model.getConstructionID(), parent: construction))
        }
    }
    
    
    /**
     Create a new item and add it as an item to the given construction.
     */
    func addItem(tag:String, length:Int, value:String, comment:String, construction: Construction) -> Item {
        //let newItem = Item(withID: model.getItemID())
        let newItem = Item(withID:tag, length:length, value:value, comment:comment, id: model.getItemID())
        construction.items.append(newItem)
        return newItem
    }
    
    
    /**
     It removes the given item from the constrcution if it has been
     specified, or it removes a constrcution from the top level
     constrcutions in the model object.
     */
    func remove<T>(item: T, from construction: Construction?) {
        // If the construction parameter value is not nil then remove
        // the given item from the specified collection.
        if let construction = construction {
            construction.remove(item: item)
        } else {
            // If the construction parameter value is nil and the
            // given item is a construction, then delete it from the
            // construction array of the model property.
            if T.self == Construction.self {
                model.constructions.removeAll { $0 == item as! Construction }
            }
        }
        
    }
    
}
