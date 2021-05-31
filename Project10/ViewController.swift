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
    var people = [Person]()
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
        guard let jpegData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        let imageName = UUID().uuidString
        let destinationPath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        try? jpegData.write(to: destinationPath)
        
        dismiss(animated: true)
        people.append(.init(name: "Unknown", image: imageName))
        let index = IndexPath(item: people.count - 1, section: 0)
        collectionView.insertItems(at: [index])
        
        collectionView.reloadData()
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
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name

        let file = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: file.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
}

