//
//  MyProfileVC.swift
//  Hamla
//
//  Created by Bassant on 17/03/2024.
//

import UIKit
import JVFloatLabeledTextField

class MyProfileVC: UIViewController {

    @IBOutlet weak var photoBackgroundView: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var trips: UILabel!
    @IBOutlet weak var inWallet: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var nameTF: JVFloatLabeledTextField!
    @IBOutlet weak var phoneTF: JVFloatLabeledTextField!
    
    var viewModel: MyProfileViewModel?
    var captainDetails: CaptainData = CaptainData()
    let pickerVC = PhotoActionSheet()
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.viewModel = MyProfileViewModel(api: MyProfileApi())
        bindData()
        self.setupNavigationBar()
        self.navigationController?.navigationBar.isHidden = false
        self.title = "My_profile".localized
        photoBackgroundView.twoColorDiagonalView(color1: UIColor(named: "primary") ?? .blue, color2: UIColor(named: "LightBlue") ?? .blue, cornerRadius: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTapGesture)
        
        let textFieldFrameInVC = phoneTF.superview?.convert(phoneTF.frame, to: self.view)
        
        let photoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        photo.addGestureRecognizer(photoTapGesture)
        setupToolbar()
    }
    
    func setupToolbar(){
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, doneButton]
        bar.sizeToFit()
        phoneTF.inputAccessoryView = bar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func didTapProfilePhoto() {
        guard let photo = photo.image, captainDetails.avatar != nil else {
            return
        }
        let vc = PhotoViewerVC(photo: photo)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        let textFieldFrameInVC = phoneTF.superview?.convert(phoneTF.frame, to: self.view)
        guard let textFieldFrame = textFieldFrameInVC else { return }
        let shift = textFieldFrame.maxY - keyboardFrame.origin.y
        if self.view.frame.origin.y == 0 && shift > 0 {
            self.view.frame.origin.y -= shift
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func setupView() {
        
        if let url = URL(string: captainDetails.avatar ?? "") {
            photo.kf.setImage(with: url, placeholder: UIImage(systemName: "person.fill")?.withTintColor(UIColor(named: "primary") ?? .blue, renderingMode: .alwaysOriginal))
        }

        trips.text = String(captainDetails.ordersCount ?? 0)
        inWallet.text = String(captainDetails.walletBalance ?? 0)
        rating.text = "\(captainDetails.rate ?? 5)/5"
        nameTF.text = captainDetails.fullName
        phoneTF.text = "+\(UserInfo.shared.get_phone())"
        
        nameTF.addPadding()
        phoneTF.addPadding()

        nameTF.delegate = self
        phoneTF.delegate = self
        
        let placeholderColor = UIColor(named: "primary-dark")?.withAlphaComponent(0.5)
        let namePlaceholder = nameTF.placeholder ?? ""
        let phonePlaceholder = phoneTF.placeholder ?? ""
        nameTF.attributedPlaceholder = NSAttributedString(string: namePlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        phoneTF.attributedPlaceholder = NSAttributedString(string: phonePlaceholder, attributes: [NSAttributedString.Key.foregroundColor : placeholderColor ?? .placeholderText])
        nameTF.floatingLabelActiveTextColor = placeholderColor
        phoneTF.floatingLabelActiveTextColor = placeholderColor
    }
    
    func bindData(){
        viewModel?.checkPhoneResult.bind { result in
            guard let message = result?.message else { return }
            if result?.status == 0 {
                self.showAlert(message: message)
            }
            else{
                let vc = VerificationVC(nibName: "VerificationVC", bundle: nil)
                vc.phoneNumber = String(self.phoneTF.text?.dropFirst() ?? "")  // drop '+' sign
                self.navigationController?.pushViewController(vc, animated: true)
            }
            print(message)
        }
        
        viewModel?.updateProfileResult.bind { result in
            guard let message = result?.message else { return }
            if result?.status == 0 {
                self.showAlert(message: message)
            }
            print(message)
        }
        
        viewModel?.errorMessage.bind{ error in
            if let error = error {
                self.showAlert(message: error)
                print(error)
            }
        }
        
        viewModel?.uploadImageResult.bind { [self] result in
            guard let message = result?.message else { return }
            if result?.status == 0 {
                self.showAlert(message: message)
            }
            else {
                self.photo.subviews.forEach { $0.removeFromSuperview() }
            }

            print(message)
        }
        
//        viewModel?.isLoading.bind { [weak self] isLoading in
//            guard let self = self else { return }
//            self.activityIndicator.isHidden = false
//            if let isLoading = isLoading, isLoading {
//                self.activityIndicator.startAnimating()
//                self.view.isUserInteractionEnabled = false
//            } else {
//                self.activityIndicator.stopAnimating()
//                self.view.isUserInteractionEnabled = true
//            }
//        }
    }
    
    @IBAction func updateProfilePhoto(_ sender: Any) {
        pickerVC.delegate = self
        pickerVC.showActionSheet(from: self)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        if viewModel!.isValidPhone(phone: String(phoneTF.text?.dropFirst() ?? "")) { // drop '+' sign
            viewModel?.checkPhone(mobile: String(phoneTF.text?.dropFirst() ?? ""))
        }
        else{
            self.showAlert(message: "Invalid_phone_number".localized)
        }
    }
    
}

extension MyProfileVC: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == phoneTF {
            
            //Limit the character count. ('+' + phone number)
            if ((textField.text!) + string).count > 13 {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case nameTF:
            //hideErrorMessage(label: errorMessage[0], view: textField)
            textField.borderColor = UIColor(named: "primary")
        case phoneTF:
            //hideErrorMessage(label: errorMessage[1], view: phoneView)
            textField.borderColor = UIColor(named: "primary")
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.borderColor = .clear
    }
    
//    func showErrorMessage(message: String, label: UILabel, view: UIView) {
//        label.text = message
//        label.isHidden = false
//        view.borderColor = .red
//        view.borderWidth = 1
//    }
//
//    func hideErrorMessage(label: UILabel, view: UIView) {
//        label.isHidden = true
//        view.borderColor = .clear
//    }
}

extension MyProfileVC: PhotoActionSheetDelegate {
    
    func didSelectImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        photo.image = image
        activityIndicator = UIActivityIndicatorView()
        activityIndicator?.center = photo.center
        activityIndicator?.color = .lightGray
        activityIndicator?.style = .large
        photo.addSubview(activityIndicator!)
        
        viewModel?.uploadImageToserver(file: imageData, progressHandler: { progress in
            self.photo.addSubview(self.activityIndicator!)
        })
    }
}
