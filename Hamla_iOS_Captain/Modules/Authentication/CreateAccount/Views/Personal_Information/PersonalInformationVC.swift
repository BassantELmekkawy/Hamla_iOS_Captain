//
//  PersonalInformationVC.swift
//  Hamla
//
//  Created by Bassant on 10/03/2024.
//

import UIKit
import PhotosUI
import JVFloatLabeledTextField

struct registerData{
    var fullName: String?
    var phoneNumber: String?
    var dateOfBirth: String?
    var governmentID: String?
    var idExpiryDate: String?
    var licenseExpiryDate: String?
    var fleetLicenseExpiryDate: String?
    var imageDictionary: [Int: String]?
    var plateNumber: String?
    var fleetType: String?
    var fleetColor: String?
    var fleetSize: String?
    var STC_Account: String?
}

class PersonalInformationVC: UIViewController {
    
    @IBOutlet weak var fullNameTF: JVFloatLabeledTextField!
    @IBOutlet weak var governmentID_TF: JVFloatLabeledTextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var dateOfBirthTF: JVFloatLabeledTextField!
    @IBOutlet weak var idExpiryDateTF: JVFloatLabeledTextField!
    @IBOutlet weak var licenseExpiryDateTF: JVFloatLabeledTextField!
    @IBOutlet var imageCollection: [UIImageView]!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var errorMessage: [UILabel]!
    
    var countryCode = "20"
    var phoneNumber = ""
    var tag = 0
    var selectedDate = ""
    let pickerVC = PhotoActionSheet()
    var image: UIImage?
    var datePicker: UIDatePicker?
    var imageDictionary: [Int: String] = [:]
    var activityIndicator: UIActivityIndicatorView?
    var overlayView: UIView?
    
    var viewModel: CreateAccountViewModel?
    var countryDropDown: DropdownMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        self.viewModel = CreateAccountViewModel(api: RegisterApi())
        setUpView()
        setupToolbar()
        bindData()
    }
    
    func setUpView() {
        self.title = "Create_account".localized
        setupNavigationBar()
        
        if !phoneNumber.isEmpty {
            phoneTF.text = String(phoneNumber.dropFirst(countryCode.count))
            countryCodeLabel.text = "+\(countryCode)"
            switch countryCode {
            case "20":
                flagImage.image = UIImage(named: "Egypt_flag")
                phoneTF.placeholder = "100 123 5678"
            case "966":
                flagImage.image = UIImage(named: "Saudi_arabia_flag")
                phoneTF.placeholder = "50 235 1456"
            default:
                break
            }
        }
        
        fullNameTF.addPadding()
        phoneTF.addPadding()
        governmentID_TF.addPadding()
        dateOfBirthTF.addPadding()
        idExpiryDateTF.addPadding()
        licenseExpiryDateTF.addPadding()
        
        phoneTF.delegate = self
        fullNameTF.delegate = self
        governmentID_TF.delegate = self
        dateOfBirthTF.delegate = self
        idExpiryDateTF.delegate = self
        licenseExpiryDateTF.delegate = self
        
        let placeholderColor = UIColor(named: "primary-dark")?.withAlphaComponent(0.5)
        let fullNamePlaceholder = fullNameTF.placeholder ?? ""
        let governmentPlaceholder = governmentID_TF.placeholder ?? ""
        let dateOfBirthPlaceholder = dateOfBirthTF.placeholder ?? ""
        let idExpiryDatePlaceholder = idExpiryDateTF.placeholder ?? ""
        let licenseExpiryDatePlaceholder = licenseExpiryDateTF.placeholder ?? ""
        fullNameTF.attributedPlaceholder = NSAttributedString(string: fullNamePlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        governmentID_TF.attributedPlaceholder = NSAttributedString(string: governmentPlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        dateOfBirthTF.attributedPlaceholder = NSAttributedString(string: dateOfBirthPlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        idExpiryDateTF.attributedPlaceholder = NSAttributedString(string: idExpiryDatePlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        licenseExpiryDateTF.attributedPlaceholder = NSAttributedString(string: licenseExpiryDatePlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        
//        // Add tap gesture recognizer to the date view
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dateViewTapped))
//        dateOfBirthTF.addGestureRecognizer(tapGesture)
//        idExpiryDateTF.addGestureRecognizer(tapGesture)
//        licenseExpiryDateTF.addGestureRecognizer(tapGesture)
        
        self.automaticallyAdjustsScrollViewInsets = false
//        if #available(iOS 11.0, *) {
//            scrollView.contentInsetAdjustmentBehavior = .never
//        } else {
//            automaticallyAdjustsScrollViewInsets = false
//        }
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
        
        fullNameTF.floatingLabelActiveTextColor = placeholderColor
        governmentID_TF.floatingLabelActiveTextColor = placeholderColor
        dateOfBirthTF.floatingLabelActiveTextColor = placeholderColor
        idExpiryDateTF.floatingLabelActiveTextColor = placeholderColor
        licenseExpiryDateTF.floatingLabelActiveTextColor = placeholderColor
        
    }
    
    func setupToolbar(){
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, doneButton]
        bar.sizeToFit()
        phoneTF.inputAccessoryView = bar
        governmentID_TF.inputAccessoryView = bar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showCalender(textfield: UITextField, minDate: Date? = nil, maxDate: Date? = nil) {
        let alertViewController = CalenderAlert(minDate: minDate, maxDate: maxDate)
        alertViewController.modalPresentationStyle = .overCurrentContext
        alertViewController.modalTransitionStyle = .crossDissolve
        alertViewController.didSelectDate = { selectedDate in
//            print("Date of birth: \(selectedDate)")
//            self.selectedDate = selectedDate
//            self.dateOfBirthLabel.text = selectedDate
            textfield.text = selectedDate
        }
        present(alertViewController, animated: true, completion: nil)
    }
    
//    @objc func dateViewTapped(_ sender: UITapGestureRecognizer) {
//        guard let textField = sender.view as? UITextField else { return }
//        if textField == dateOfBirthTF{
//            hideErrorMessage(label: errorMessage[2], view: textField)
//        } else if textField == idExpiryDateTF {
//            hideErrorMessage(label: errorMessage[4], view: textField)
//        } else if textField == licenseExpiryDateTF {
//            hideErrorMessage(label: errorMessage[5], view: textField)
//        }
//        showCalender(textfield: textField)
//    }
    
    func bindData(){
        viewModel?.uploadImageResult.bind { [self] result in
            guard let message = result.1?.message else { return }
            if result.1?.status == 0 {
                self.showAlert(message: message)
            }
            else {
                self.imageCollection[result.0].subviews.forEach { $0.removeFromSuperview() }
                self.imageDictionary[result.0] = result.1?.data
            }

            print(message)
        }
        
        viewModel?.errorMessage.bind{ error in
            if let error = error {
                self.showAlert(message: error)
                print(error)
            }
        }
        
    }
    
    func isValidData() -> Bool {
        if let fullName = fullNameTF.text, fullName.isEmpty {
            showErrorMessage(message: "Full_name_is_required".localized, label: errorMessage[0], view: fullNameTF)
        }
        else if let phone = phoneTF.text, phone.isEmpty {
            showErrorMessage(message: "Phone_number_is_required".localized, label: errorMessage[1], view: phoneView)
        }
        else if !viewModel!.isValidPhone(phone: phoneTF.text ?? "", countryCode: countryCode) {
            showErrorMessage(message: "Invalid_phone_number".localized, label: errorMessage[1], view: phoneView)
        }
        else if let dateOfBirth = dateOfBirthTF.text, dateOfBirth.isEmpty {
            showErrorMessage(message: "Date_of_birth_is_required".localized, label: errorMessage[2], view: dateOfBirthTF)
        }
        else if let governmentID = governmentID_TF.text, governmentID.isEmpty {
            showErrorMessage(message: "Government_ID_is_required".localized, label: errorMessage[3], view: governmentID_TF)
        }
        else if let idExpiryDate = idExpiryDateTF.text, idExpiryDate.isEmpty {
            showErrorMessage(message: "ID_expiry_date_is_required".localized, label: errorMessage[4], view: idExpiryDateTF)
        }
        else if let licenseExpiryDate = licenseExpiryDateTF.text, licenseExpiryDate.isEmpty {
            showErrorMessage(message: "License_expiry_date_is_required".localized, label: errorMessage[5], view: licenseExpiryDateTF)
        }
        else {
            let photoArray = ["Personal", "Government_ID", "Driving_license"]
            for (index, image) in imageCollection.enumerated() {
                if image.image == nil {
                    //self.showAlert(message: "\(photoArray[index]) photo is required")
                    showErrorMessage(message: "\(photoArray[index])_photo_is_required".localized, label: errorMessage[index+6], view: image)
                    return false
                }
            }
            return true
        }
        return false
    }
    
    
    @IBAction func selectCountry(_ sender: UIButton) {
        let countries = ["Egypt", "Saudi Arabia"]
        countryDropDown = DropdownMenu(dataSource: countries, button: sender, customCellType: CountryCell.self)
        countryDropDown?.setupDropdownMenu(width: 220, height: 40)
        
        countryDropDown?.customCell = { cell, indexPath in
            if let countryCell = cell as? CountryCell {
                countryCell.countryName = countries[indexPath.row]
            }
        }
        
        countryDropDown?.selectedElement = { [weak self] element in
            switch element {
            case "Egypt":
                self?.flagImage.image = UIImage(named: "Egypt_flag")
                self?.countryCodeLabel.text = "+20"
                self?.countryCode = "20"
                self?.phoneTF.placeholder = "100 123 5678"
            case "Saudi Arabia":
                self?.flagImage.image = UIImage(named: "Saudi_arabia_flag")
                self?.countryCodeLabel.text = "+966"
                self?.countryCode = "966"
                self?.phoneTF.placeholder = "50 235 1456"
            default:
                break
            }
            print(element)
        }
    }
    
    @IBAction func Continue(_ sender: Any) {
        if isValidData() && imageDictionary.count == 3 {
            let captainRegisterData = registerData(
                fullName: fullNameTF.text,
                phoneNumber: countryCode + (phoneTF.text ?? ""),
                dateOfBirth: selectedDate,
                governmentID: governmentID_TF.text,
                idExpiryDate: idExpiryDateTF.text,
                licenseExpiryDate: licenseExpiryDateTF.text,
                imageDictionary: imageDictionary
            )
            if phoneTF.text ?? "" != phoneNumber.dropFirst(countryCode.count){
                UserInfo.shared.isPhoneVerified(status: false)
            }
            let vc = FleetInformationVC(nibName: "FleetInformationVC", bundle: nil)
            vc.captainRegisterData = captainRegisterData
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func openPhoto(_ sender: UIButton) {
        tag = sender.tag
        hideErrorMessage(label: errorMessage[tag+6], view: imageCollection[tag])
        pickerVC.delegate = self
        pickerVC.showActionSheet(from: self)
    }
    
}

extension PersonalInformationVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == governmentID_TF {
            if ((textField.text!) + string).count > 14 {
                return false
            }
        }
        
        if textField == phoneTF {
            //Prevent "0" character as the first character.
            if textField.text?.count == 0 && string == "0" {
                return false
            }
            
            //Limit the character count.
            var max = 0
            switch countryCode {
            case "20":
                max = 10
            case "966":
                max = 9
            default:
                break
            }
            if ((textField.text!) + string).count > max {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case fullNameTF:
            hideErrorMessage(label: errorMessage[0], view: textField)
            textField.borderColor = UIColor(named: "primary")
        case phoneTF:
            hideErrorMessage(label: errorMessage[1], view: phoneView)
            phoneView.borderColor = UIColor(named: "primary")
        case governmentID_TF:
            hideErrorMessage(label: errorMessage[3], view: textField)
            textField.borderColor = UIColor(named: "primary")
        default:
            break
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case dateOfBirthTF:
            let maxDate = getAdjustedDate(byAddingDays: -1)
            showCalender(textfield: textField, maxDate: maxDate)
            hideErrorMessage(label: errorMessage[2], view: textField)
        case idExpiryDateTF:
            let minDate = getAdjustedDate(byAddingDays: 1)
            showCalender(textfield: textField, minDate: minDate)
            hideErrorMessage(label: errorMessage[4], view: textField)
        case licenseExpiryDateTF:
            let minDate = getAdjustedDate(byAddingDays: 1)
            showCalender(textfield: textField, minDate: minDate)
            hideErrorMessage(label: errorMessage[5], view: textField)
        default:
            return true
        }
        return false
    }
    
    func getAdjustedDate(byAddingDays days: Int) -> Date? {
        var components = DateComponents()
        components.day = days
        return Calendar.current.date(byAdding: components, to: Date())
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == phoneTF {
            phoneView.borderColor = .clear
        }
        textField.borderColor = .clear
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension PersonalInformationVC: PhotoActionSheetDelegate {
    
    func didSelectImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        imageCollection[tag].image = image
        
        viewModel?.uploadImageToserver(file: imageData, tag: tag, progressHandler: { progress in
            self.overlayView = UIView(frame: self.imageCollection[self.tag].bounds)
            self.overlayView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.imageCollection[self.tag].addSubview(self.overlayView ?? UIView())
        })
    }
}


func showErrorMessage(message: String, label: UILabel, view: UIView) {
    label.text = message
    label.isHidden = false
    view.borderColor = .red
    view.borderWidth = 1
}

func hideErrorMessage(label: UILabel, view: UIView) {
    label.isHidden = true
    view.borderColor = .clear
}
