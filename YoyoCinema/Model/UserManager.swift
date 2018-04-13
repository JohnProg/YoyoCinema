//
//  UserManager.swift
//  YoyoCinema
//
//  Created by Maria Lopez on 22/03/2018.
//  Copyright © 2018 Maria Lopez. All rights reserved.
//

import UIKit
import RealmSwift

class UserManager: NSObject{
    
    static let shared = UserManager()
    
    var currentUser: User! {
        didSet {
        }
    }
    
    var movie: MoviesDwnld! {
        didSet {
        }
    }
    
      var favouriteMoviesForUser: List<MoviesDwnld> {
        let movies = self.currentUser.favouriteMovies
          return movies
      }
    
    func addUser(user: User){
        DispatchQueue.main.async {
            
            let realm = try! Realm()
            
            let users = realm.objects(User.self)
            
            if (users.isEmpty){
                do{
                    try realm.write {
                        realm.add(user)
                    }
                }catch{
                    print("Table empty, error adding user \(error)")
                }
            }else{
                do {
                    try self.currentUser = Realm().object(ofType: User.self, forPrimaryKey: self.currentUser.email)
                    try realm.write {
                        self.currentUser.firstName = user.firstName
                        self.currentUser.lastName = user.lastName
                        self.currentUser.pictureURL = user.pictureURL
                        self.currentUser.userId = user.userId
                    }
                } catch {
                    print("Current user, updating user \(error)")
                    do{
                        try realm.write {
                            realm.add(user)
                        }
                    }catch{
                        print("Table not empty, user doesn't exist,error adding user \(error)")
                    }
                }
            }
        }
    }
    
    func addFavouriteMovie(movie: MoviesDwnld){
        DispatchQueue.main.async {
            do {
                let realm = try! Realm()
                var exists = false
                let movies = self.currentUser.favouriteMovies
                
                for moviesOfUser in movies {
                    //if movie is favourite, unfavaourite it
                    if (moviesOfUser.id == movie.id){
                        let movieUnfav = self.currentUser.favouriteMovies.filter("id == \(movie.id)")
                        try realm.write {
                            movieUnfav.forEach { moviee in if let index = self.currentUser.favouriteMovies.index(of: moviee){
                                self.currentUser.favouriteMovies.remove(at: index)
                                }}
                        }
                        exists = true
                    }
                }
                if (exists == false){
                    //if movie is not favourite, check if it's already in the DB and add it
                    let newMovie = try Realm().object(ofType: MoviesDwnld.self, forPrimaryKey: movie.id)
                    if (newMovie?.realm == nil){
                        try realm.write {
                            self.currentUser.favouriteMovies.append(movie)
                        }
                    }else{
                        try realm.write {
                            self.currentUser.favouriteMovies.append(newMovie!)
                        }
                    }
                }
            } catch {
                print("Error saving new favourite movie, \(error)")
            }
        }
    }
    
    func addMovieCache(movie: MoviesDwnld){
        DispatchQueue.main.async {
            do {
                let realm = try! Realm()
                var exists = false
                let moviesCache = realm.objects(MoviesDwnld.self)
                
                //Check if the movie is already in the DB
                for movieCache in moviesCache {
                    if (movieCache.id == movie.id){
                        exists = true
                    }
                }
                //If the movie is not in the DB
                if (exists == false){
                    // check if it's already in the DB and add it
                    let newMovie = try Realm().object(ofType: MoviesDwnld.self, forPrimaryKey: movie.id)
                    if (newMovie?.realm == nil){
                        try realm.write {
                            realm.add(movie)
                        }
                    }else{
                        try realm.write {
                            realm.add(movie)
                        }
                    }
                }
            } catch {
                print("Error saving new cache movie, \(error)")
            }
        }
    }
}
