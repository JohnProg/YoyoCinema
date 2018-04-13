import UIKit
import Cosmos
import RealmSwift


class MovieDetail: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var releaseLbl: UILabel!
    @IBOutlet weak var overviewLbl: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var toggleButton: UIButton!
    
    var movie : MoviesDwnld?
    
    let imageURLPrefix = "https://image.tmdb.org/t/p/w500"
    
    var fav = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rating()
        
        setInformation()
        
        setFavStar()
        
        swipeGesture()
        
    }
    
    @IBAction func backMoviesList(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "UITabBarController")
        
        present(tabBar, animated: true, completion: nil)
    }
    
    @IBAction func favouriteBtn(_ sender: Any) {
        guard let movie : MoviesDwnld = movie else { return}
        UserManager.shared.addFavouriteMovie(movie: movie)
        
        DispatchQueue.main.async {
            self.setFavStar()
        }
    }
    
    private func setInformation(){
        
        guard let movie = movie else {return}
        
        //introducing data
        titleLbl.text = movie.title
        releaseLbl.text = movie.release_date
        overviewLbl.text = movie.overview
        //image
        guard let poster = movie.backdrop_path else { imgView.image = #imageLiteral(resourceName: "noimage")
            return}
        let imageURL = URL(string: "\(imageURLPrefix)\(poster)")
        do {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL!)
                if let data = data {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.imgView.image = image
                    }
                }
            }
        }
    }
    
    private func rating() {
        let value = (movie?.vote_average)!/2
        cosmosView.rating = value
        cosmosView.settings.updateOnTouch = false
        cosmosView.text = nil
        cosmosView.backgroundColor = UIColor.clear
    }
    
    func setFavStar(){
        fav = false
        var moviesFav : List<MoviesDwnld> {
            return UserManager.shared.favouriteMoviesForUser
        }
        
        
        for movieFavUser in moviesFav {
            print("Title fav -> \(String(describing: movieFavUser.title))")
            if (movieFavUser.title == movie?.title){
                fav = true
            }
        }
        
        if (fav == true){
            toggleButton.setImage(#imageLiteral(resourceName: "fav"), for: .normal)
            //rotate icon
            self.toggleButton.rotate720Degrees(duration:1)
        }else{
            toggleButton.setImage(#imageLiteral(resourceName: "unfav"), for: .normal)
            self.toggleButton.rotate720DegreesOCW(duration: 1)
        }
        
    }
    
    func swipeGesture(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(swipe:)))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
    }
}

extension UIViewController
{
    @objc func swipeAction(swipe: UISwipeGestureRecognizer)
    {
        switch  swipe.direction.rawValue{
        case 1:
            performSegue(withIdentifier: "swipeRight", sender: self)
        default:
            break
        }
    }
}

extension UIView {
    func rotate720Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(.pi * 4.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
    func rotate720DegreesOCW(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -CGFloat(.pi * 4.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as? CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
