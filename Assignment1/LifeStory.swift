// =============================================================
//  Assignment 1 · Your Life Story in Swift
// =============================================================

import Foundation

// MARK: - Step 1: Personal information

let firstName: String = "Erasyl"
let lastName: String = "Kokenov"
let birthYear: Int = 2005
let isStudent: Bool = true
let height: Double = 1.80
let city: String = "Almaty"
let country: String = "Kazakhstan"
let university: String = "KBTU"
let major: String = "Information Systems"

// Bonus: calculate the age instead of hardcoding it
let currentYear: Int = 2026
let age: Int = currentYear - birthYear


// MARK: - Step 2: Hobbies and interests

let hobby: String = "playing video games"
let secondHobby: String = "watching movies, series and anime"
let numberOfHobbies: Int = 7
let favoriteNumber: Int = 42
let isHobbyCreative: Bool = true
let otherHobbies: String = "hiking, playing guitar and piano, exploring new things and doing research"
let favoriteScience: String = "theoretical physics"
let favoriteFood: String = "potatoes and rice"
let favoriteMusic: String = "Tame Impala and Radiohead"
let favoriteProgrammingLanguage: String = "JavaScript"


// MARK: - Bonus: emoji values and emoji variable names

let 🤝: String = "🤝"
let favoriteEmoji: String = 🤝
let 🎮: String = "🎮"
let 🎸: String = "🎸"
let 🚀: String = "🚀"

let futureGoals: String = "I want to grow into a senior frontend engineer while learning backend, DevOps and system design, join big tech, live in the USA and Europe, and eventually start my own business"


// MARK: - Step 3: Life story summary

let studentText: String = isStudent ? "I am currently a student" : "I am not a student right now"
let creativeText: String = isHobbyCreative ? "which is a creative hobby" : "which is not really a creative hobby"

let lifeStory: String = """
My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear), and my height is \(height) meters. \
I live in \(city), \(country). \(studentText): I study \(major) at \(university).
I enjoy \(hobby) \(🎮) and \(secondHobby), \(creativeText). \
I also like \(otherHobbies) \(🎸), and I am really into technology and science, especially \(favoriteScience). \
I have \(numberOfHobbies) hobbies in total, and my favorite number is \(favoriteNumber) (hello from The Hitchhiker's Guide to the Galaxy).
My favorite food is \(favoriteFood), my favorite music authors are \(favoriteMusic), and my favorite programming language is \(favoriteProgrammingLanguage).
My favorite emoji is \(favoriteEmoji) (I think a handshake is legendary).
In the future, \(futureGoals) \(🚀)
"""


// MARK: - Step 4: Print the life story

print(lifeStory)
