//
//  PostViewController.swift
//  HellowMyFriends
//
//  Created by 高琨淯 on 2019/6/23.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import ImagePicker
import Lightbox

class PostViewController: UIViewController {
    
   
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var clearPhotoBtn: UIBarButtonItem!
    
    @IBOutlet var cameraBtn: UIBarButtonItem!
    
    var databaseRef: DatabaseReference! = Database.database().reference()
    var storageRef: StorageReference! = Storage.storage().reference()
    var currentData : PaperData! = PaperData()
    var images: [UIImage] = []
    var index: Int = 0
    let fullScreenSize = UIScreen.main.bounds.size
    var pageControl : UIPageControl! = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPagingEnabled = true
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if images.count > 0  {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.clearPhotoBtn.isEnabled = true
            self.cameraBtn.isEnabled = false
            //设置页控制器
            pageControl.center = CGPoint(x: UIScreen.main.bounds.width/2,
                                         y: UIScreen.main.bounds.height - 20)
            pageControl.numberOfPages = images.count
            pageControl.isUserInteractionEnabled = true
            pageControl.tintColor = UIColor.gray
            pageControl.pageIndicatorTintColor = UIColor.gray
            pageControl.currentPageIndicatorTintColor = UIColor.blue
            view.addSubview(self.pageControl)
        }else{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.clearPhotoBtn.isEnabled = false
            self.cameraBtn.isEnabled = true
        }
    }
    
    @IBAction func camera(_ sender: Any) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func clearPhotoBtn(_ sender: Any) {
        
        self.images = []
        self.currentData = PaperData()
        self.collectionView.reloadData()
        self.clearPhotoBtn.isEnabled = false
        self.cameraBtn.isEnabled = true
        
        pageControl.numberOfPages = images.count

        self.navigationItem.rightBarButtonItem?.isEnabled = false

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "postMessageSegue" {
            let postMessageVC = segue.destination as! PostMessageViewController
            postMessageVC.images = images
            postMessageVC.currentData = currentData
        }
        
    }
}

extension PostViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCollectionViewCell
        
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }
    //collectionView里某个cell显示完毕
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //当前显示的单元格
        //        let visibleCell = collectionView.visibleCells[0]
        guard let visibleCell = collectionView.visibleCells.first else {return}
        //设置页控制器当前页
        self.pageControl.currentPage = collectionView.indexPath(for: visibleCell)!.item
    }
}

extension PostViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return fullScreenSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension PostViewController : ImagePickerDelegate {
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("wrapperDidPress")
        
        guard images.count > 0 else { return }
        
        let lightboxImages = images.map {
            LightboxImage(image: $0)
        }
        let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
        imagePicker.present(lightbox, animated: true, completion: nil)
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("doneButtonDidPress")
        
        self.images = images
        for _ in 0 ..< images.count {
            let uuidString = UUID().uuidString
            self.currentData.imageName.append(uuidString)
        }
        self.dismiss(animated: true)
        self.collectionView.reloadData()
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancelButtonDidPress")
        imagePicker.dismiss(animated: true)
        self.dismiss(animated: true)
        
    }
    
    
}
