//
//  ViewController.swift
//  OutLineViewSimple
//
//  Created by Friedrich HAEUPL on 31.01.23.
//  Copyright © 2023 Friedrich HAEUPL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var viewModel = ViewModel()
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBOutlet weak var constructedTagOutlet: NSTextField!
    
    @IBOutlet weak var itemTagOutlet: NSTextField!
    
    @IBOutlet weak var constructedValueOutlet: NSTextField!
    
    @IBOutlet weak var itemValueOutlet: NSTextField!
    
    @IBAction func addConstructedItemAction(_ sender: Any) {
        print("addConstructedItemAction")
        var constructionToExpand: Construction?
        
        if let construction = getConstructionForSelectedItem() {
            // Create the new construction as a child item of the current construction.
            viewModel.createConstruction(withTitle: "New Construction",
                                         ctag: constructedTagOutlet.stringValue,
                                         clength: constructedValueOutlet.stringValue.count/2,
                                         cvalue: constructedValueOutlet.stringValue, ccomment: "CComment" ,
                                         inConstruction: construction)
            constructionToExpand = construction
        } else {
            // No parent construction was returned so pass nil as the second
            // argument and create a top level construction.
            viewModel.createConstruction(withTitle: "Top Construction",
                                         ctag: constructedTagOutlet.stringValue,
                                         clength: constructedValueOutlet.stringValue.count/2,
                                         cvalue: constructedValueOutlet.stringValue, ccomment: "CComment" ,
                                         inConstruction: nil)
        }
        
        // Reload the outline view.
        outlineView.reloadData()
        
        // Expand the collection if possible.
        outlineView.expandItem(constructionToExpand)
    }
    
    @IBAction func addItemAction(_ sender: Any) {
        print("addItemAction")
        // Make sure that there is a target construction to add a new item to.
        guard let construction = getConstructionForSelectedItem() else { return }
        
        // Create and get the instance of the new item.
        let newItem = viewModel.addItem(
            tag: itemTagOutlet.stringValue,
            length: itemValueOutlet.stringValue.count/2,
            value: itemValueOutlet.stringValue,
            comment: "ItemComment",
            construction: construction)
        
        print("update construction length")
        construction.clength += itemValueOutlet.stringValue.count/2
        // update the construction above, till there is no above
        // tbd
        // guard let construction_above = getConstructionForConstruction(construction) else { // done }
        
        /* for two levels demo:
         if let parentConstruction = construction.parent {
         //
         print(">>>update parent construction length")
         parentConstruction.clength += itemValueOutlet.stringValue.count/2
         if let parentparentConstruction = parentConstruction.parent {
         //
         print(">>>update parent parent construction length")
         parentparentConstruction.clength += itemValueOutlet.stringValue.count/2
         
         //
         } else {
         print(">>>no parent parent construction")
         }
         //
         } else {
         print(">>>no parent construction")
         }
         */
        
        var parentConstruction = construction.parent
        while let pConstruction = parentConstruction
        {
            print(pConstruction)
            print(">>>update parent construction length")
            parentConstruction?.clength += itemValueOutlet.stringValue.count/2
            parentConstruction = pConstruction.parent
        }
        
        print("reload")
        // Reload the outline view and expand the construction.
        outlineView.reloadData()
        outlineView.expandItem(construction)
        
        // Get the row of the new color item and select it automatically.
        let itemRow = outlineView.row(forItem: newItem)
        outlineView.selectRowIndexes(IndexSet(arrayLiteral: itemRow), byExtendingSelection: false)
    }
    
    @IBAction func deleteItemAction(_ sender: Any) {
        print("deleteItemAction")
        let selectedRow = outlineView.selectedRow
        var result = false
        
        if let selectedItem = outlineView.item(atRow: selectedRow) as? Item {
            
            // Make sure that there is a target construction to add a new item to.
            guard let construction = getConstructionForSelectedItem() else { return }
            
            let ctr = selectedItem.length
            construction.clength -= ctr
            
            viewModel.remove(item: selectedItem, from: construction)
            //
            print("remove item update construction length")
            /* parentConstruction.clength -= selectedItem.length
           
            if let parentparentConstruction = construction.parent {
                //
                print(">>>update parent parent construction length")
                parentparentConstruction.clength -= ctr
                
            } else {
                print(">>>no parent parent construction")
            }
           
            */
            var parentConstruction = construction.parent
            while let pConstruction = parentConstruction
             {
                 print(pConstruction)
                 print(">>>update parent construction length")
                 parentConstruction?.clength -=  ctr // ??? echt selectedItem.length ???
                 parentConstruction = pConstruction.parent
             }
            
            result = true
        } else if let selectedItem = outlineView.item(atRow: selectedRow) as? Construction {
            
               if let construction = outlineView.parent(forItem: selectedItem) as? Construction {
                
                let ctr = selectedItem.clength
                
                viewModel.remove(item: selectedItem, from: construction)
                //
                print("remove construction update construction length .... missing")
                /*
                parentConstruction.clength -= selectedItem.clength
                
                if let parentparentConstruction = parentConstruction.parent {
                    //
                    print(">>>update parent parent construction length")
                    parentparentConstruction.clength -= selectedItem.clength
                    
                    //
                } else {
                    print(">>>no parent parent construction")
                }
                */
                var parentConstruction = construction.parent
                while let pConstruction = parentConstruction
                {
                    print(pConstruction)
                    print(">>>update parent construction length")
                    parentConstruction?.clength -=  ctr // ??? echt selectedItem.length ???
                    parentConstruction = pConstruction.parent
                }
                //
            } else {
                viewModel.remove(item: selectedItem, from: nil)
            }
            
            result = true
        }
        
        if result {
            outlineView.reloadData()
            
            if selectedRow < outlineView.numberOfRows {
                outlineView.selectRowIndexes(IndexSet(arrayLiteral: selectedRow), byExtendingSelection: false)
            } else {
                if selectedRow - 1 >= 0 {
                    outlineView.selectRowIndexes(IndexSet(arrayLiteral: selectedRow - 1), byExtendingSelection: false)
                }
            }
        }
    }
    
    @IBAction func parseStreamAction(_ sender: Any) {
        print("parseStreamAction")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        outlineView.dataSource = self
        outlineView.delegate = self
        
        // demodata
        
        constructedTagOutlet.stringValue = "E0"
        itemTagOutlet.stringValue = "DF76"
        constructedValueOutlet.stringValue = "" //"DF7603000001DF1405436C656172DF1505456E746572DF1604463146329F1C083132333435363738"
        itemValueOutlet.stringValue = "000001"
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: - Custom Methods
    
    func getConstructionForSelectedItem() -> Construction? {
        let selectedItem = outlineView.item(atRow: outlineView.selectedRow)
        
        guard let selectedConstruction = selectedItem as? Construction
            else { return outlineView.parent(forItem: selectedItem) as? Construction }
        return selectedConstruction
    }
}

// MARK: - NSTextFieldDelegate
extension ViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let construction = outlineView.item(atRow: outlineView.selectedRow) as? Construction else { return true }
        construction.title = (control as! NSTextField).stringValue
        return true
    }
}


// MARK: - NSOutlineViewDataSource
extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return item == nil ? viewModel.model.totalConstructions : (item as? Construction)?.totalItems ?? 1
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return item == nil ? viewModel.model.constructions[index] : (item as? Construction)?.items[index] ?? item!
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let _ = item as? Construction else { return false }
        return true
    }
}


// MARK: - NSOutlineViewDelegate
extension ViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let colIdentifier = tableColumn?.identifier else {
            return nil
        }
        if colIdentifier == NSUserInterfaceItemIdentifier(rawValue: "col1") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell1")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
            
            if let construction = item as? Construction {
                cell.textField?.stringValue = construction.ctag ?? ""
                cell.textField?.isEditable = true
                cell.textField?.delegate = self
                cell.textField?.layer?.backgroundColor = NSColor.clear.cgColor
            } else if let item = item as? Item {
                cell.textField?.stringValue = item.tag
                cell.textField?.isEditable = false
                //cell.textField?.wantsLayer = true
                //cell.textField?.layer?.backgroundColor = item.toNSColor().cgColor
                //cell.textField?.layer?.cornerRadius = 5.0
                // tbd.
            }
            
            return cell
            
        }
        if colIdentifier == NSUserInterfaceItemIdentifier(rawValue: "col2") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell2")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else {
                return nil
            }
            
            if let construction = item as? Construction {
                cell.textField?.stringValue = String(construction.clength)
                cell.textField?.font = NSFont.boldSystemFont(ofSize: cell.textField?.font?.pointSize ?? 13.0)
                
            } else
                if let item = item as? Item {
                    cell.textField?.stringValue = String(item.length)
                    cell.textField?.font = NSFont.systemFont(ofSize: cell.textField?.font?.pointSize ?? 13.0)
            }
            
            return cell
        }
        if colIdentifier == NSUserInterfaceItemIdentifier(rawValue: "col3") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell3")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
            
            if let construction = item as? Construction {
                cell.textField?.stringValue = String(construction.cvalue)
                cell.textField?.font = NSFont.boldSystemFont(ofSize: cell.textField?.font?.pointSize ?? 13.0)
            } else
                if let item = item as? Item {
                    cell.textField?.stringValue = item.value
                    cell.textField?.font = NSFont.systemFont(ofSize: cell.textField?.font?.pointSize ?? 13.0)
            }
            
            return cell
        }
        if colIdentifier == NSUserInterfaceItemIdentifier(rawValue: "col4") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell4")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else { return nil }
            
            if let construction = item as? Construction {
                cell.textField?.stringValue = String(construction.ccomment)
                cell.textField?.font = NSFont.boldSystemFont(ofSize: cell.textField?.font?.pointSize ?? 13.0)
            } else if let item = item as? Item {
                cell.textField?.stringValue = item.comment
                cell.textField?.font = NSFont.systemFont(ofSize: cell.textField?.font?.pointSize ?? 13.0)
            }
            
            return cell
        }
        return nil
    }
    
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        print ("outlineViewSelectionDidChange")
        if let item = outlineView.item(atRow: outlineView.selectedRow) as? Item {
            // If the selected item is a Item object then pass it to the item details
            // view and show it.
            //colorDetailsView.set(color: color)
            //colorDetailsView.show()
            // tbd Detailsview
        } else {
            // In any other case hide the color details view.
            // tbd Detailsview
            // colorDetailsView.hide()
        }
    }
    
}
