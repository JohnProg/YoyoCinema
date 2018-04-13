import UIKit
import Alamofire

class SecondView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movieID: String!
    let imageURLPrefix = "https://image.tmdb.org/t/p/w500"
    let completedUrl = "http://api.themoviedb.org/3/discover/movie?api_key=35edb7f4a82c544c17c31298050f4ec1"
    let searchURL = "http://api.themoviedb.org/3/search/movie?api_key=35edb7f4a82c544c17c31298050f4ec1&query="
    
    lazy var refreshControl:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(SecondView.refreshMovieData(_:)), for: .valueChanged)
        
        return refreshControl
    }()
    
    private var moviesDwnld = [MoviesDwnld]()
    private var moviesDwnldFiltered = [MoviesDwnld]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addSubview(refreshControl)
        
        alamofireRequest(url: completedUrl)
        setUpSearchBar()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnalyticsManager.sharedInstance.registerScreen(screenName: "Movies")
    }
    
    //MARK: - Refresh
    //@objc because we are using addTarget
    @objc private func refreshMovieData(_ sender: Any) {
        alamofireRequest(url: completedUrl)
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    //MARK: - Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return moviesDwnldFiltered.count
    }
    
    //introducing data into the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as? MovieCell else { return UITableViewCell()}
        
        //saving movie in realm
        UserManager.shared.addMovieCache(movie: moviesDwnld[indexPath.row])
        
        cell.titleLbl.text = moviesDwnldFiltered[indexPath.row].title
        cell.descriptionLbl.text = moviesDwnldFiltered[indexPath.row].overview
        
        //check if backdrop_path exists, if not, return the cell with the default image
        guard let poster = moviesDwnldFiltered[indexPath.row].backdrop_path else { cell.imgView.image = #imageLiteral(resourceName: "noimage")
            return cell}
        //if exists, charge the image from the url
        let imageURL = URL(string: "\(imageURLPrefix)\(poster)") 
        do {
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
    
    //MARK: - Alamofire
    func alamofireRequest(url: String) {
        Alamofire.request(url)
            .responseJSON { response in
                
                switch response.result {
                    
                case .success:
                        //retrieving the response as data to decode it
                        guard let result = response.data else { return }
                        do{
                            if let firstCall = try JSONDecoder().decode(FirstCall.self, from: result) as? FirstCall
                            {
                                self.moviesDwnld = firstCall.results!
                                self.moviesDwnldFiltered = self.moviesDwnld
                            }
                            //second threath to load tableview when data already finish download
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        } catch let error {
                            print ("Error JSONDecoder ->\(error)")
                        }                    
                    
                case .failure(_):
                    print("Error-> request = failure")
                }
        }
    }
    
    //MARK: - Search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            moviesDwnldFiltered = moviesDwnld
            tableView.reloadData()
            return
        }
        //making the request to the website
        let addOn = searchText.replacingOccurrences(of: " ", with: "%20")
        let finalSearchUrl = searchURL + addOn
        
        alamofireRequest(url: finalSearchUrl)
        
        tableView.reloadData()
    }
    
    //to make the delegate (it´s possible do it through storyboard)
    private func setUpSearchBar(){
        searchBar.delegate = self
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MovieDetail {
            destination.movie = moviesDwnldFiltered[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
}
