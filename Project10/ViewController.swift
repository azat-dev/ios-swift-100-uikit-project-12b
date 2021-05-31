//
//  ViewController.swift
//  Project10
//
//  Created by Azat Kaiumov on 31.05.2021.
//

import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let fileName = UUID().uuidString
        let destinationPath = getDocumentsDirectory().appendingPathComponent(fileName)
        
        try? jpegData.write(to: destinationPath)
        
        dismiss(animated: true)
    }
    
    @objc func addButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }

    private func initNavBar() {
        navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        return cell
    }
}

