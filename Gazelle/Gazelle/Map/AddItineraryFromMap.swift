//
//  AddItineraryFromMap.swift
//  Gazelle
//
//  Created by Angela Li Montez on 5/15/23.
//

import UIKit
import MapKit
import ParseSwift

class AddItineraryFromMap: UIViewController {
    
    var trips = [Trip]()
    var tripDict = [String: String]()
    var tripId: String?
    var mapItem: MKMapItem?
    
    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var tripNamePicker: UIButton!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard()
        queryTrips()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("Save button tapped")
        if (eventTextField.text == "" || locationTextField.text == "") {
            itineraryItemFieldRequredAlert()
        } else {
            print("Working on Map to Itinerary Segue")
        }
    }
}

// MARK: - Segue Code
extension AddItineraryFromMap {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Map to Itinerary Segue being called")
    }
}


// MARK: - UI Related Operations
extension AddItineraryFromMap {
    private func fillInputFields() {
        eventTextField.text = mapItem!.name
        locationTextField.text = mapItem!.placemark.formattedAddress
        descriptionTextField.text = mapItem!.url?.absoluteString
        setPopupOptions()
    }
    
    private func setPopupOptions() {
        let optionClosure = { (action: UIAction) in
            self.tripId = self.tripDict[action.title]
        }
        
        var optionsArray = [UIAction]()
        let placeholder = UIAction(title: "Select Trip", state: .on, handler: optionClosure)
        optionsArray.append(placeholder)
        
        for trip in trips {
            let title = trip.title!
            let action = UIAction(title: title, state: .off, handler: optionClosure)
            optionsArray.append(action)
        }
        let optionsMenu = UIMenu(title: "", options: .displayInline, children: optionsArray)
        
        tripNamePicker.menu = optionsMenu
        tripNamePicker.changesSelectionAsPrimaryAction = true
        tripNamePicker.showsMenuAsPrimaryAction = true
    }
}


// MARK: - CRUD Related Operations
extension AddItineraryFromMap {
    private func queryTrips() {
        // Create query to fetch Trips for User
        let userId = User.current?.objectId
        let query = Trip.query("userId" == "\(userId!)")
        
        // Fetch Trip objects from D
        query.find { [weak self] result in
            switch result {
            case .success(let trips):
                print("✅ Trip Query Completed")
                self?.trips = trips
                self?.createTripDictionary()
                self?.fillInputFields()
            case .failure(_):
                print("❌ Unable to query trips from Add Itinerary Item from Map")
            }
        }
        
    }
    
    private func createTripDictionary() {
        for trip in trips {
            tripDict[trip.title!] = trip.objectId!
        }
    }
    
}
