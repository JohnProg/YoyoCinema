//
//  FourthView.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 16/03/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import NStackSDK

class FourthView: UIViewController, FBSDKLoginButtonDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    //MARK: - Fetching strings from NStack
    @IBOutlet weak var title_firstName: UILabel!{
        didSet {
            title_firstName.text = tr.profile.profileFirstName
        }
    }
    @IBOutlet weak var title_lastName: UILabel!{
        didSet {
            title_lastName.text = tr.profile.profileLastName
        }
    }
    @IBOutlet weak var title_email: UILabel!{
        didSet {
            title_email.text = tr.profile.profileEmail
        }
    }
    
    @IBOutlet weak var user_FirstName: UILabel!
    @IBOutlet weak var user_LastName: UILabel!
    @IBOutlet weak var user_Email: UILabel!
    @IBOutlet weak var user_picture: UIImageView!
    @IBOutlet weak var picker_language: UIPickerView!
    
    var languages =  ["English","Spanish"]
    
    var currentUser: User {
        return UserManager.shared.currentUser
    }
    
    override func viewDidLoad() {
        fbButton()
        setInfo(user: currentUser)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animatePulseView()
        AnalyticsManager.sharedInstance.registerScreen(screenName: "Profile")
    }
    
    //MARK: - Pulse effect profile picture
    func animatePulseView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.user_picture.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (success) in
            self.user_picture.transform = .identity
        }
    }
    
    //MARK: - Set info
    func setInfo (user: User){
        user_FirstName.text = currentUser.firstName
        user_LastName.text = currentUser.lastName
        user_Email.text = currentUser.email
        user_picture.setRounded()
        let url = URL(string: currentUser.pictureURL)
        if let data = try? Data(contentsOf: url!)
        {
            user_picture.image  = UIImage(data: data)
        }
    }
    
    //MARK: - Language
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let languageChosen = (languages[picker_language.selectedRow(inComponent: 0)])
        
        switch (languageChosen){
        case "Spanish":
            print("Spanish")
//            let configuration = Configuration(plistName: "NStack", translationsClass: Translations.self)
//            NStack.update(<#T##NStack#>)
        default:
            print("English")
        }
    }
    
    
    //MARK: - Adding facebook button
    
    func fbButton(){
        //adding facebook button
        let loginButton = FBSDKLoginButton()
        loginButton.delegate = self
        //redisgn button-bigger-bottom
        let verticalPosition: CGFloat = 4.0
        let positionOfFrame = self.view.center.y - self.view.center.y / verticalPosition
        let positionX = self.view.center.x - (loginButton.frame.width + 60) / 2
        let positionY = self.view.center.y - (loginButton.frame.height + 15) / 2
        let finalPositionY = positionY + positionOfFrame
        //Frame of the Login Button
        let widthOfFBButton = loginButton.frame.width + 60
        let heightOfFBButton = loginButton.frame.height 
        //Placing the button on the frame
        loginButton.frame = CGRectMake(positionX, finalPositionY, widthOfFBButton, heightOfFBButton)
        self.view.addSubview(loginButton)
    }
    
    // redefine the functions Apple took away
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User Logged In")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let scene = storyboard.instantiateViewController(withIdentifier: "UILogin")
        
        present(scene, animated: true, completion: nil)
    }
}

extension UIImageView {
    
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}
    
    

