//
//  TableViewController.swift
//  TellMeMap
//
//  Created by Julia García Martínez on 05/11/2019.
//  Copyright © 2019 Julia García Martínez. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    //MARK: Properties
    var frc: NSFetchedResultsController<Place>!
    
    //MARK: Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.myDataSource = DSTable()
        //self.myTableView.dataSource = myDataSource
        
        guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let myContext = myDelegate.persistentContainer.viewContext
        
        let request: NSFetchRequest<Place> = NSFetchRequest(entityName: "Place")
        let sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.sortDescriptors = sortDescriptors
        self.frc = NSFetchedResultsController<Place>(fetchRequest: request, managedObjectContext: myContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.frc.delegate = self
        
        do {
            try self.frc.performFetch()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }
    
    // MARK: Actions
    @IBAction func unwindToPlaceList(sender: UIStoryboardSegue) {
    }
    
    // MARK: - Fetched Results Controller
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.frc.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.frc.object(at: indexPath)
        
        guard let newCell = tableView.dequeueReusableCell(withIdentifier: "placeTableViewCell", for: indexPath) as? PlaceTableViewCell else {
            fatalError("The dequeued cell is not an instance of PlaceTableViewCell.")
        }
        
        newCell.setContent(item: item)
        
        return newCell
    }
    
    // MARK: - Fetched Results Controller Delegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                self.tableView.insertRows(at: [newIndexPath!], with:.automatic )
            case .update:
                self.tableView.reloadRows(at: [indexPath!], with: .automatic)
            case .delete:
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
            case .move:
                self.tableView.deleteRows(at: [indexPath!], with: .automatic)
                self.tableView.insertRows(at: [newIndexPath!], with:.automatic )
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch(type) {
            case .insert:
                self.tableView.insertSections(IndexSet(integer:sectionIndex), with: .automatic)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer:sectionIndex), with: .automatic)
            default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let myDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let myContext = myDelegate.persistentContainer.viewContext
        
        switch editingStyle {
            case .delete:
                let placeToDelete = self.frc.object(at: indexPath)
                myContext.delete(placeToDelete)
                
                do {
                    try myContext.save()
                } catch {
                   fatalError("Failed to delete message: \(error)")
                }
            default: break
                
        }
    }

}
