//
//  ThirdView.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 16/03/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import UIKit
import RealmSwift

class ThirdView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let imageURLPrefix = "https://image.tmdb.org/t/p/w500"
    
    var moviesFav : List<MoviesDwnld> {
        return UserManager.shared.favouriteMoviesForUser
    }
    
    var moviesFavFiltered = List<MoviesDwnld>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moviesFavFiltered = moviesFav
        setUpSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnalyticsManager.sharedInstance.registerScreen(screenName: "Favourites movies")
    }
    
    
    //MARK: - Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moviesFavFiltered.count
    }
    
    //introducing data into the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCellFav") as? MovieCell else { return UITableViewCell()}
        
        cell.titleLbl.text = moviesFavFiltered[indexPath.row].title
        cell.descriptionLbl.text = moviesFavFiltered[indexPath.row].overview
        
        //check if backdrop_path exists, if not, return the cell with the default image in the main.storyboard
        guard let poster = moviesFavFiltered[indexPath.row].backdrop_path else {cell.imgView.image = #imageLiteral(resourceName: "noimage")
            return cell}
        //if exists, charge the image from the url
        do {
        let imageURL = URL(string: "\(imageURLPrefix)\(poster)")        
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL!)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imgView.image = image
                        
                        cell.blur.image = image
                        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.regular)
                        let blurView = UIVisualEffectView(effect: darkBlur)
                        blurView.frame = cell.blur.bounds
                        cell.blur.addSubview(blurView)
                    }
                }
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = indexPath.row
        performSegue(withIdentifier: "showDetail", sender: self)
    }
    
    
    
    //MARK: - Search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            moviesFavFiltered = moviesFav
            tableView.reloadData()
            return
        }
        moviesFavFiltered = moviesFav.filter({ moviesFav -> Bool in
            (moviesFav.title?.contains(searchText))!
        })
        tableView.reloadData()
    }
    
    //to make the delegate (it´s possible do it through storyboard)
    private func setUpSearchBar(){
        searchBar.delegate = self
    }
    
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MovieDetail {
            destination.movie = moviesFavFiltered[(tableView.indexPathForSelectedRow?.row)!]
        }
    }

}
