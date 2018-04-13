import UIKit
import FacebookLogin
import FBSDKLoginKit
import NStackSDK
import RealmSwift



class Login: UIViewController, FBSDKLoginButtonDelegate {
    //MARK: - Fetching strings from NStack
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
           titleLabel.text = tr.login.loginTitle
        }
    }
    @IBOutlet weak var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.text = tr.login.loginSubtitle
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        fbButton()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() != nil {
            fetchProfile()
            goToTabBar()
        }
        AnalyticsManager.sharedInstance.registerScreen(screenName: "Login")
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func fetchProfile(){
        let parameters = ["fields": "id, email, first_name, last_name, picture.type(large)"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil){
                let fbDetails = result as! NSDictionary
                //create new object User
                let newUser = User()
                newUser.userId = fbDetails.value(forKey: "id") as! String
                newUser.firstName = fbDetails.value(forKey: "first_name") as! String
                newUser.lastName = fbDetails.value(forKey: "last_name") as! String
                newUser.email = fbDetails.value(forKey: "email") as! String
                //The url is nested 3 layers deep into the result so it's pretty messy
                if let imageURL = ((fbDetails["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                    newUser.pictureURL = imageURL
                }
                
                self.currentUser(user: newUser)
                self.saveUserRealm(user: newUser)

            }else{
                print(error?.localizedDescription ?? "Not found")
            }
        })
    }
    
    //MARK: - Saving user in realm
    func saveUserRealm(user: User) {
        UserManager.shared.addUser(user: user)
    }
    
    //MARK: - Setting the currentUser
    func currentUser(user: User){
        UserManager.shared.currentUser = user
    }
    
    //MARK: - Changing scene
    private func goToTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "UITabBarController")
        
        present(tabBar, animated: true, completion: nil)
    }
    
    //MARK: Facebook button and methods
    func fbButton(){
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        loginButton.readPermissions = ["email"]
        loginButton.center = view.center
        view.addSubview(loginButton)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print ("Error login on facebook \(error)")
            return
        }else{
            fetchProfile()
            goToTabBar()
            AnalyticsManager.sharedInstance.registerAction(category: "Login", action: "Login success action", label: "Success")
        }
    }
}

