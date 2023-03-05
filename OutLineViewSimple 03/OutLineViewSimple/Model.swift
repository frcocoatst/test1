//
//  Model.swift
//  OutlineViewDemo
//
//

import AppKit

/**
 General Notes:
 
 * Color class represents a color in the app, and Collection
 represents a collection of colors.
 * They are classes and not structs because we want their instances
 to pass around by reference and changes made to an object to affect
 the original one, not a copy of it.
 * Both conform to Equatable protocol for comparing objects. To make
 comparison easy they contain the "id" property as identifiers.

 */


/**
 It represents a color object in app.
 */
class Item: Equatable, CustomStringConvertible {
    var id: Int?
    var tag: String = "TAG"
    var length: Int = 1
    var value: String = "VALUE"
    var comment: String = "COMMENT"
    
    /// It returns the  values formatted as they should be
    /// displayed to the outline view.
    var description: String {
        return "\(tag), \(String(format: "%02X", length)), \(value), \(comment)"
    }
    
    
    init(withID tag:String, length:Int, value:String, comment:String, id: Int) {
        self.id = id
        self.tag = tag
        self.length = length
        self.value = value
        self.comment = comment
    }
    
    
    /**
     It returns a NSColor object based on the RGBA values
     of the current object.

    func toNSColor() -> NSColor {
        return NSColor(red: 0xff, green: 0x55, blue: 0x66, alpha: 0xaa)
    }
     */

    
    /**
     Update Item object using the TLV values given as arguments.
    */
    func update(withTLV tag: String, length: Int, value: String, comment:String) {
          self.tag = tag
          self.length = length
          self.value = value
          self.comment = comment
          
      }
    
    /* Equatable: comparison is the item identical */
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}



/**
 It represents a construction of items and other construction.
 */
class Construction: Equatable {
    var id: Int?
    var title: String?
    var ctag: String = "CTAG"
    var clength: Int = 0
    var cvalue: String = "CVALUE"
    var ccomment: String = "CCOMMENT"
    var parent: Construction?
    var items = [Any]()
    var totalItems: Int { get { return items.count }}
    
    init(withTitle title: String, ctag:String, clength:Int, cvalue:String, ccomment:String, id: Int,  parent:Construction?) {
        self.title = title
        self.ctag = ctag
        self.clength = clength
        self.cvalue = cvalue
        self.ccomment = ccomment
        self.id = id
        self.parent = parent
    }
    
    
    /**
     It removes either a item or another construction from
     the current collection.
     
     This is a generic method as it accepts two different
     data types (Item , Construction).
    */
    func remove<T>(item: T) {
         // Check if the given item is a collection.
         // In that case remove all of its items.
         if T.self == Construction.self {
             // The given item is a Construction so remove all of its items.
             (item as! Construction).items.removeAll()
         }
         
         // Find the given item in the items array and remove it.
         for (index, currentItem) in items.enumerated() {
             guard type(of: currentItem) == T.self, currentItem as? T.Type == item as? T.Type else { continue }
             items.remove(at: index)
             break
         }
     }
    
    
     static func == (lhs: Construction, rhs: Construction) -> Bool {
        return lhs.id == rhs.id
    }
}


/**
 It handles the top level construction and the identifiers
 of the Items  and Construction classes. It's also what the
 View Model uses as its model.
*/
struct Model {
    var constructions = [Construction]()
    var totalConstructions: Int { get { return constructions.count }}
    private var nextConstructionID = 1
    private var nextItemID = 1
    
    /**
     It returns the current Construction ID and increases
         it by 1 to the next value.
    */
     mutating func getConstructionID() -> Int {
        nextConstructionID += 1
        return nextConstructionID - 1
    }
    
    /**
     It returns the current Item ID and increases
         it by 1 to the next value.
    */
    mutating func getItemID() -> Int {
        nextItemID += 1
        return nextItemID - 1
    }
}
