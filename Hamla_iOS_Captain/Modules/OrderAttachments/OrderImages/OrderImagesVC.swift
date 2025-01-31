//
//  OrderImagesVC.swift
//  Hamla_iOS_Captain
//
//  Created by Bassant on 24/07/2024.
//

import UIKit

class OrderImagesVC: UIViewController {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var orderId = 0
    var numOfImages = 4
    var images: [UIImage?] = Array(repeating: nil, count: 4)
    var indexPath: IndexPath?
    var loadingIndicator: UIActivityIndicatorView?
    let pickerVC = PhotoActionSheet()
    var viewModel = OrderAttatchmentsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindData()
    }
    
    func setupView() {
        self.title = "Order_images".localized
        infoLabel.twoColorLabel(word: "minimum 4 image", color: UIColor(named: "quaternary") ?? .gray)
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.register(UINib(nibName: "OrderImageCell", bundle: nil), forCellWithReuseIdentifier: "OrderImageCell")
        heightConstraint.constant = imagesCollectionView.collectionViewLayout.collectionViewContentSize.height
        pickerVC.delegate = self        
    }
    
    func bindData(){
        viewModel.uploadImageResult.bind { [self] result in
            guard let message = result.1?.message else { return }
            if result.1?.status == 0 {
                self.showAlert(message: message)
            }
            else {
                self.loadingIndicator?.stopAnimating()
            }

            print(message)
        }
        
        viewModel.errorMessage.bind{ error in
            if let error = error {
                self.showAlert(message: error)
                print(error)
            }
        }
        
    }

    @IBAction func addImage(_ sender: Any) {
        numOfImages += 1
        images.append(nil)
        imagesCollectionView.reloadData()
    }
    
    @IBAction func uploadImages(_ sender: Any) {
        let vc = SignatureVC.shared
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension OrderImagesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "OrderImageCell", for: indexPath) as! OrderImageCell
        cell.imageLabel.text = "Photo \(indexPath.item + 1)"
        cell.orderImage.image = images[indexPath.item]
        heightConstraint.constant = imagesCollectionView.collectionViewLayout.collectionViewContentSize.height
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickerVC.showActionSheet(from: self)
        self.indexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space = 20.0
        let width = (imagesCollectionView.bounds.width - space) / 2.0
        let height = width * 5 / 6
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20.0
    }
}

extension OrderImagesVC: PhotoActionSheetDelegate {
    func didSelectImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.5),
              let indexPath = indexPath else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, let cell = self.imagesCollectionView.cellForItem(at: indexPath) else { return }
            
            images[indexPath.item] = image
            imagesCollectionView.reloadItems(at: [indexPath])
            viewModel.uploadImageToserver(file: imageData, tag: indexPath.row)
            loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            loadingIndicator?.hidesWhenStopped = true
            loadingIndicator?.style = .large
            loadingIndicator?.color = .lightGray
            loadingIndicator?.center = imagesCollectionView.cellForItem(at: indexPath)!.center
            imagesCollectionView.cellForItem(at: indexPath)?.addSubview(loadingIndicator!)
            loadingIndicator?.startAnimating()
        }
    }
}
