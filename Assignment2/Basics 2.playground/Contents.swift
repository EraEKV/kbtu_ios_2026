// =============================================================
//  Assignment 2 · Working with Collections in Swift
//  No loops and no if/else: only collection operations.
// =============================================================

import Foundation

// MARK: - Easy Tasks

// 1. Array Creation and Access
let fruits: [String] = ["Apple", "Banana", "Cherry", "Mango", "Orange"]
print("Third fruit:", fruits[2])

// 2. Set Creation and Manipulation
var favoriteNumbers: Set<Int> = [7, 13, 21, 42]
favoriteNumbers.insert(99)
print("Favorite numbers:", favoriteNumbers.sorted())

// 3. Dictionary Creation and Access
let languages: [String: Int] = ["Swift": 2014, "Python": 1991, "Java": 1995]
print("Swift was released in", languages["Swift"] ?? 0)

// 4. Array Element Update
var colors: [String] = ["Red", "Green", "Blue", "Yellow"]
colors[1] = "Purple"
print("Colors:", colors)


// MARK: - Medium Tasks

// 1. Set Intersection
let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
print("Intersection:", setA.intersection(setB).sorted())

// 2. Dictionary Update
var scores: [String: Int] = ["Alice": 85, "Bob": 90, "Carol": 78]
scores.updateValue(95, forKey: "Bob")
print("Scores:", scores)

// 3. Array Merge
let firstArray: [String] = ["apple", "banana"]
let secondArray: [String] = ["cherry", "date"]
let mergedArray: [String] = firstArray + secondArray
print("Merged:", mergedArray)


// MARK: - Hard Tasks

// 1. Dictionary Key Addition
var populations: [String: Int] = ["USA": 331_000_000, "India": 1_380_000_000, "Brazil": 213_000_000]
populations["Japan"] = 125_000_000
print("Populations:", populations)

// 2. Set Union and Subtract
let animalsA: Set<String> = ["cat", "dog"]
let animalsB: Set<String> = ["dog", "mouse"]
let animalsResult: Set<String> = animalsA.union(animalsB).subtracting(animalsB)
print("Union minus second set:", animalsResult)

// 3. Nested Collection
let studentGrades: [String: [Int]] = ["John": [90, 85, 88], "Emma": [75, 80, 95]]
print("John's second grade:", studentGrades["John"]?[1] ?? 0)
