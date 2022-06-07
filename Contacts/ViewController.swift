//
//  ViewController.swift
//  Contacts
//
//  Created by TeRb1 on 26.05.2022.
//

import UIKit

class ViewController: UIViewController {
    
    private var storage: ContactStorageProtocol!
    private var contacts: [ContactProtocol] = [] {
        didSet {
            contacts.sort{$0.title < $1.phone}
            storage.save(contacts: contacts)
        }
    }
    
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        storage = ContactStorage()
        loadContacts()
    }
    
    @IBAction func showNewContactAlert() {
        
        let alertController = UIAlertController(
            title: "Создать новый контакт",
            message: "Введите имя и телефон",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Имя"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Номер телефона"
        }
        
        let createBtn = UIAlertAction(title: "Создать", style: .default) { _ in
            guard let contactName = alertController.textFields?[0].text,
                  let contactPhone = alertController.textFields?[1].text else {
                return
            }
            
            let contact = Contact(title: contactName, phone: contactPhone)
            self.contacts.append(contact)
            self.tableView.reloadData()
        }
        
        let cancelBtn = UIAlertAction(title: "Отменить", style: .cancel)
        
        alertController.addAction(createBtn)
        alertController.addAction(cancelBtn)
        
        self.present(alertController, animated: true)
    }


}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "MyCell") {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "MyCell")
        }
        
        configure(cell: &cell, for: indexPath)
        return cell
    }
    
    private func loadContacts() {
        
        contacts = storage.load()
    }
}

extension ViewController {
    
    private func configure(cell: inout UITableViewCell, for indexPath: IndexPath) {
        
        var configuration = cell.defaultContentConfiguration()
        configuration.text = contacts[indexPath.row].title
        configuration.secondaryText = contacts[indexPath.row].phone
        cell.contentConfiguration = configuration
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let actionDelete = UIContextualAction(style: .destructive, title: "Удалить") {_,_,_ in
            self.contacts.remove(at: indexPath.row)
            tableView.reloadData()
        }
        
        let actions = UISwipeActionsConfiguration(actions: [actionDelete])
        return actions
    }
}
