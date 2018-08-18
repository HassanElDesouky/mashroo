//
//  RecentsTableViewController.swift
//  mashroo
//
//  Created by Hassan El Desouky on 2/28/18.
//  Copyright © 2018 Hassan El Desouky. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    //MARK: - Properties
    var favoritesMashroos : [Mashroos] = []

    //MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDef = UserDefaults.standard
        let a = userDef.object(forKey: "title") as? String
        print(a!)
        
    }

    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return favoritesMashroos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //MARK: Create a cell and define data source
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let mashroo = favoritesMashroos[indexPath.row]
        
        cell.textLabel?.text = mashroo.title! + " " + mashroo.locationName!
        cell.imageView?.image = mashroo.mashrooPhoto
        
        
        return cell
    }


}
