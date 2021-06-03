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

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
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
        title = "Names to faces"
        navigationController?.navigationBar.prefersLargeTitles = true
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
        textField.becomeFirstResponder()
    }
    
    func showNameEditAlert(index: Int) {
        let person = people[index]
        
        let alert = UIAlertController(
            title: "Rename person",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField()
        alert.textFields?.first?.text = person.name
        alert.textFields?.first?.delegate = self
        
        let submitButton = UIAlertAction(title: "Ok", style: .default) {
            [weak self, weak alert] _ in
            
            guard let newName = alert?.textFields?.first?.text else {
                return
            }
            
            person.name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
            self?.collectionView.reloadItems(at: [.init(item: index, section: 0)])
        }
        
        alert.addAction(submitButton)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func deleteItem(index: Int) {
        people.remove(at: index)
        
        collectionView.deleteItems(at: [
            .init(item: index, section: 0)
        ])
    }
    
    func showChooseAlert(itemIndex: Int) {
        let alert = UIAlertController(
            title: "Choose",
            message: "Do you want to delete or rename?",
            preferredStyle: .actionSheet
        )
        
        let renameButton = UIAlertAction(title: "Rename", style: .default) {
            [weak self] _ in
            self?.showNameEditAlert(index: itemIndex)
        }
        
        let deleteButton = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] _ in
            self?.deleteItem(index: itemIndex)
        }
        
        alert.addAction(renameButton)
        alert.addAction(deleteButton)
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showChooseAlert(itemIndex: indexPath.item)
    }
}
