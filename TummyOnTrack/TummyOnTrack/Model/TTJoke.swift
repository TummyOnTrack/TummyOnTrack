//
//  TTJoke.swift
//  TummyOnTrack
//
//  Created by Gauri Tikekar on 5/13/17.
//  Copyright © 2017 Gauri Tikekar. All rights reserved.
//
import UIKit

//source: http://www.jokes4us.com/miscellaneousjokes/foodjokes/baconjokes.html"

class TTJoke: NSObject {
    
    static let jokes: NSMutableDictionary! = [
        "Apple": "What lives in apples and is an avid reader? A bookworm !",
        "Asparagus" : "Why are asparagus stalks leaves never lonely? Because they come in bunches.",
        "Avocado" : "What do you call an avocado thats been blessed by Pope Francis? Holy Guacamole.",
        "Bacon" : "What do you call a bacon wrapped dinosaur? Jurrasic Pork.",
        "Banana" : "Why did the banana go to see the doctor? The banana was not peeling very well.",
        "Egg" : "What day do eggs hate most? Fry-day!",
        "Eggs" : "What day do eggs hate most? Fry-day!",
        "Beef" : "Where do you find the most cows? Moo-York",
        "Broccoli" : "What do you get when you cross broccoli and a vampire? Count Broccula!",
        "Bread" : "Why are bread jokes always funny? Because they never get mold!",
        "Bagel" : "What do you call a bagel that can fly? A plain bagel.",
        "Burger" : "What do you call a pig thief? A hamburglar.",
        "Hamburger" : "What do you call a pig thief? A hamburglar.",
        "Bean" : "Knock Knock! Who's there? Bean. Bean who? Bean a while since I last saw you!",
        "Burrito" : "What do call a cat in a blanket? A purrrrito",
        "Cake" : "Why did the students eat their homework? Because the teacher said that it was a piece of cake.",
        "Rice" : "What do cats eat for breakfast? Mice Krispies.",
        "Cereal" : "What is a cheerleader's favourite cereal? Cheerios",
        "Cupcake": "Why was the birthday cake as hard as a rock? Because it was marble cake!",
        "Carrot" : "Did you hear about the carrot detective? He got to the root of every case.",
        "Cheese" : "How do you get a mouse to smile? Say cheese!",
        "Chocolate" : "What kind of candy is never on time? ChocoLATE",
        "Cookie" : "What cookie makes you rich? A fortune cookie!",
        "Cookies" : "What cookie makes you rich? A fortune cookie!",
        "Chicken" : "Why did the chicken cross the playground? To get to the other slide.",
        "Corn" : "What do you tell a vegetable after it graduates from College? Corn gratulations.",
        "Doughnut" : "Knock knock! Who's there? Doughnut. Doughnut Who? Doughnut forget to close the door!",
        "Donut" : "Knock knock! Who's there? Doughnut. Doughnut Who? Doughnut forget to close the door!",
        "Grape" : "Why aren't grapes ever lonely? Because they come in bunches!",
        "Strawberry" : "Patient: Doctor, there is a strawberry growing out of my head. Doctor: Oh, that's easy. Just put some cream on it!",
        "Pancake" : "What do the New York Yankees and pancakes have in common? They both need a good batter!",
        "Pancakes" : "What do the New York Yankees and pancakes have in common? They both need a good batter!",
        "Peas" : "What do you call an angry pea? Grump-pea",
        "Pasta" : "What do you call a pasta that is sick? Mac and sneeze.",
        "Noodles" : "What do you call a fake noodle? Impasta",
        "Noodle" : "What do you call a fake noodle? Impasta",
        "Pizza" : "Waiter, will my pizza be long? No sir, it will be round!",
        "Salad" : "What did the vegetables say to the Salad Dressing? Lettuce all smile.",
        "Soup" : "What is a ghosts favorite soup? Scream of Broccoli.",
        "Mushroom" : "What room has no doors, no walls, no floor and no ceiling? A mushroom.",
        "Steak" : "Where do cows go for lunch? The calf-eteria.",
        "Spaghetti" : "Where did the spaghetti go to dance? The meat ball!",
        "Milk" : "What country do cows love to visit? Moo Zealand!",
        "Orange" : "Knock Knock Who's there? Orange Orange who? Orange you going to answer the door?",
        "Oranges" : "Knock Knock Who's there? Orange Orange who? Orange you going to answer the door?"
        ]
    
    class func getJokeFor(aWord: String) -> String? {
        let joke_ = TTJoke.jokes.object(forKey: aWord)
        if joke_ == nil {
            return nil
        }
        return joke_ as? String
    }
}
