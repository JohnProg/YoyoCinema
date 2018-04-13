import Foundation
import RealmSwift


class User: Object {
    
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var email = ""
    @objc dynamic var pictureURL = ""
    @objc dynamic var userId = ""
    var favouriteMovies = List<MoviesDwnld>()
    
    override static func primaryKey() -> String? {
        return "email"
    }
}



