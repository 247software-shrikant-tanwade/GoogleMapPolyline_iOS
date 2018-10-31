//
//  SearchPlacesListVC.swift
//  GoogleMapPolyline_iOS
//
//  Created by Shrikant Tanwade on 31/10/18.
//  Copyright © 2018 shrikant. All rights reserved.
//

import UIKit
import GoogleMaps

// MARK: - SearchPlacesListVC Delegate
protocol SearchPlacesListVCDelegate  {
    func addFromMarker(location : CLLocationCoordinate2D, address : String, shortAddress : String)
    func addToMarker(location : CLLocationCoordinate2D, address : String, shortAddress : String)
    func addMarkerAndDrawPloyline(from : CLLocationCoordinate2D, to : CLLocationCoordinate2D)
    func dismissSearchPlacesListVC()
}

class SearchPlacesListVC: UIViewController {
    
    var delegate : SearchPlacesListVCDelegate?

    // MARK: - IBOutlet and Variables
    @IBOutlet weak var bottomTablePlaces : NSLayoutConstraint!
    @IBOutlet weak var btnGo : UIButton!
    @IBOutlet weak var tablePlaces : UITableView!
    @IBOutlet weak var txtFromPlace : UITextField!
    @IBOutlet weak var txtToPlace : UITextField!
    
    var isFromTxtActive : Bool = false
    var arrPlaces : [Places]!
    
    var currentLatLong : CLLocationCoordinate2D!
    var fromLatLong : CLLocationCoordinate2D!
    var toLatLong : CLLocationCoordinate2D!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        if (currentLatLong == nil) {
            txtFromPlace.becomeFirstResponder()
        } else {
            txtFromPlace.text = "Your current location"
            fromLatLong = currentLatLong
            txtToPlace.becomeFirstResponder()
        }
    }
    
    // MARK: - Button Action
    @IBAction func btnBackAction() {
        delegate?.dismissSearchPlacesListVC()
        self.dismiss(animated: false) {}
    }
    
    @IBAction func btnDoneAction() {
        if fromLatLong != nil && toLatLong != nil {
            self.btnBackAction()
            self.delegate?.addMarkerAndDrawPloyline(from: fromLatLong, to: toLatLong)
        }
    }
    
    func resetTablePlaces() {
        self.arrPlaces = nil
        self.tablePlaces.reloadData()
    }
}

// MARK: - Keyboard Notification methods
extension SearchPlacesListVC {
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            bottomTablePlaces.constant = keyboardHeight + 10
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomTablePlaces.constant = 10
    }
}

// MARK: - UITextFieldDelegate Delegate
extension SearchPlacesListVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField.text! == "") {
            self.resetTablePlaces()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.txtFromPlace) {
            self.txtToPlace.becomeFirstResponder()
        } else {
            self.btnDoneAction()
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.resetTablePlaces()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        (textField == txtFromPlace) ? (isFromTxtActive=true) : (isFromTxtActive=false)
        
        var completeTextForSearch : String = textField.text!+string
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        let minSearchCharRange = 3
        if (isBackSpace == -92) {
            if (completeTextForSearch.count>0) {
                completeTextForSearch = completeTextForSearch.substring(to: completeTextForSearch.index(before: completeTextForSearch.endIndex))
            }
        }
        
        if completeTextForSearch.count > minSearchCharRange {
            GoogleApiManager.placesOf(searchText: textField.text!) { (status, places) in
                if status {
                    self.arrPlaces = places
                    self.tablePlaces.reloadData()
                }
            }
        }
        return true
    }
}

// MARK: - UITableViewDelegate Delegate
extension SearchPlacesListVC : UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (arrPlaces != nil) {
            return arrPlaces.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell")!
        let lblPlace : UILabel = cell.viewWithTag(111) as! UILabel
        lblPlace.text = arrPlaces[indexPath.row].description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        GoogleApiManager.latLongFrom(placeId: arrPlaces[indexPath.row].placeId) { (status, location) in
            if status {
                let latLong = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                switch self.isFromTxtActive {
                case true:
                    self.fromLatLong = latLong
                    self.txtFromPlace.text = self.arrPlaces[indexPath.row].description
                    self.delegate?.addFromMarker(location: latLong, address: self.arrPlaces[indexPath.row].description, shortAddress: "")
                    break
                default:
                    self.toLatLong = latLong
                    self.txtToPlace.text = self.arrPlaces[indexPath.row].description
                    self.delegate?.addToMarker(location: latLong, address: self.arrPlaces[indexPath.row].description, shortAddress: "")
                    break
                }
            }
        }
    }
}

// MARK: - Static Present VC
extension SearchPlacesListVC {
    static func presentWith(delegate:SearchPlacesListVCDelegate,presenterVC:UIViewController,currentLatLong:CLLocationCoordinate2D?) {
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SearchPlacesListVC") as! SearchPlacesListVC
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.delegate = delegate
        vc.currentLatLong = currentLatLong
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        presenterVC.present(vc, animated: false) {}
    }
}
