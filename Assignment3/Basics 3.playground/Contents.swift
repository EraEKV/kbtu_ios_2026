// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================




// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP"
    else { return nil }
    return (sensor: parts.0, value: value)
}

print("\n--- 1.1 parseReading ---")
print(parseReading("O2:87") as Any)      // (sensor: "O2", value: 87)
print(parseReading("TEMP:-12") as Any)   // (sensor: "TEMP", value: -12)
print(parseReading("RAD:-1") as Any)     // nil
print(parseReading(":55") as Any)        // nil
print(parseReading("O2:9x") as Any)      // nil
print(parseReading("hello") as Any)      // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid, invalidCount)
}

print("\n--- 1.2 parseLog ---")
let log = parseLog(rawLog)
print("valid: \(log.valid.count), invalid: \(log.invalidCount)")
let smallLog = parseLog(["O2:50", "bad", "TEMP:-3"])
print("valid: \(smallLog.valid), invalid: \(smallLog.invalidCount)")
print(parseLog([]))

let A = log.invalidCount
print("Fragment A = \(A)")


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings where isIncluded(reading) {
        result.append(reading)
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

print("\n--- 2.1 select / values ---")
let o2Readings = select(log.valid) { $0.sensor == "O2" }
print(o2Readings)
print(values(of: o2Readings))
let highReadings = select(log.valid) { $0.value > 90 }
print(highReadings)
print(values(of: highReadings))

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for value in values {
        if value < minValue { minValue = value }
        if value > maxValue { maxValue = value }
        sum += value
    }
    return (minValue, maxValue, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("\n--- 2.2 stats ---")
print(stats(3, 8, 1) as Any)          // (min: 1, max: 8, average: 4.0)
print(stats() as Any)                 // nil
print(stats(of: [-5, 10]) as Any)     // (min: -5, max: 10, average: 2.5)
print(stats(of: []) as Any)           // nil

let o2Stats = stats(of: values(of: o2Readings))
let B = Int(o2Stats?.average ?? 0)
print("Fragment B = \(B)")

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
print("\n--- 2.3 Closure Ladder ---")
let valid = log.valid

// 1. Full syntax
let sorted1 = valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
// 2. Types inferred from context
let sorted2 = valid.sorted(by: { a, b in return a.value > b.value })
// 3. Implicit return
let sorted3 = valid.sorted(by: { a, b in a.value > b.value })
// 4. Shorthand argument names
let sorted4 = valid.sorted(by: { $0.value > $1.value })
// 5. Trailing closure
let sorted5 = valid.sorted { $0.value > $1.value }

// Tuples are not Equatable, so arrays of them can't be compared with ==
func sameReadings(_ lhs: [Reading], _ rhs: [Reading]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for i in 0..<lhs.count {
        if lhs[i].sensor != rhs[i].sensor || lhs[i].value != rhs[i].value {
            return false
        }
    }
    return true
}

let ladder = [sorted2, sorted3, sorted4, sorted5]
var allMatch = true
for result in ladder where !sameReadings(sorted1, result) {
    allMatch = false
}
print(sorted5)
print("All five sorts match: \(allMatch)")
print("Sanity check (different order): \(sameReadings(sorted1, valid))")


// MARK: Level 3 · Temperature Stabilization

let safeRange = 18...24

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < safeRange.lowerBound { return heatUp }
    if temp > safeRange.upperBound { return coolDown }
    return hold
}

print("\n--- 3.1 protocols ---")
print(heatUp(10), coolDown(30), hold(20))       // 15 27 20
print(chooseProtocol(for: 10)(10))              // 15 (heatUp)
print(chooseProtocol(for: 30)(30))              // 27 (coolDown)
print(chooseProtocol(for: 20)(20))              // 20 (hold)

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while !safeRange.contains(temp) && steps < maxSteps {
        let applyProtocol = chooseProtocol(for: temp)
        temp = applyProtocol(temp)
        steps += 1
    }
    return (temp, steps, safeRange.contains(temp))
}

print("\n--- 3.2 runUntilStable ---")
print(runUntilStable(from: 31))                 // (finalTemp: 22, steps: 3, isStable: true)
print(runUntilStable(from: -100, maxSteps: 5))  // (finalTemp: -75, steps: 5, isStable: false)
print(runUntilStable(from: 20))                 // (finalTemp: 20, steps: 0, isStable: true)

let tempReadings = select(log.valid) { $0.sensor == "TEMP" }
let lowestTemp = stats(of: values(of: tempReadings))?.min ?? 0
let C = runUntilStable(from: lowestTemp).steps
print("Lowest temperature: \(lowestTemp)")
print("Fragment C = \(C)")


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("\n--- 4.1 oxygenLevel ---")
for member in crew {
    print(member.name, oxygenLevel(of: member) as Any)
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(member.module?.name ?? "open space"))"
    }
    return "\(member.name): \(level)% \(level < 20 ? "CRITICAL" : "OK")"
}

print("\n--- 4.2 status ---")
for member in crew {
    print(status(of: member))
}

// 4.3
let tankCapacity = 100

@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let freeSpace = max(0, tankCapacity - target)
    let transferred = min(amount, max(0, source), freeSpace)
    source -= transferred
    target += transferred
    return transferred
}

print("\n--- 4.3 transferOxygen ---")
var tankA = 50, tankB = 90
print(transferOxygen(from: &tankA, to: &tankB, amount: 30), tankA, tankB)  // 10 40 100 (target full)
var tankC = 5, tankD = 0
print(transferOxygen(from: &tankC, to: &tankD, amount: 30), tankC, tankD)  // 5 0 5 (source limited)
print(transferOxygen(from: &tankC, to: &tankD, amount: -10), tankC, tankD) // 0 0 5 (negative)

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    let moved = transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    print("Moved \(moved) units: Lab = \(labTank.level), Hab = \(habTank.level)")
} else {
    print("Transfer impossible: a tank is missing")
}

let D = hab.oxygenTank?.level ?? 0
print("Fragment D = \(D)")

print("Crew after transfer:")
for member in crew {
    print(status(of: member))
}

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    found.sort { $0.priority < $1.priority }

    var result: [String] = []
    for member in found {
        result.append(member.name)
    }
    return result
}

print("\n--- 4.4 evacuationOrder ---")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))  // ["Aigerim", "Timur", "Dana"]
print(evacuationOrder("Nurlan", "Timur", "Aigerim", "Dana", roster: roster)) // ["Aigerim", "Nurlan", "Timur", "Dana"]
print(evacuationOrder("Nobody", roster: roster))                             // []


// MARK: Level 5 · The Saboteur's Logbook

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

/*
 Problems found:

 reportOxygen
  1. `member.module!` — Nurlan has module == nil (open space).
     Runtime crash: "Unexpectedly found nil while unwrapping an Optional value".
  2. `.oxygenTank!` — Dana is in Dock, which has no tank (oxygenTank == nil).
     Same crash, even though the member does have a module.

 firstCritical
  3. `oxygenLevel(of: member)!` — any member without data (Dana, Nurlan) crashes it.
     With the starter crew it dies on Dana (2nd element) before ever reaching Aigerim.
  4. LOGIC BUG: there is no `break`/`return` after a match, so the loop keeps
     going and overwrites `result`. The function returns the LAST critical
     member, not the FIRST. With the starter data only Aigerim is critical,
     so first == last and the bug is invisible.
  5. `return result!` — if nobody is critical (e.g. everyone is at 20%+,
     or an empty crew array) result is nil and it crashes. "Nobody is critical"
     is good news, not a reason to crash — it should be expressed as String?.
  6. Members without data are silently treated as a crash instead of being
     skipped (or reported), so one broken sensor takes down the whole check.
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }
    guard let tank = module.oxygenTank else {
        return "\(member.name): no data (\(module.name))"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        guard let level = oxygenLevel(of: member) else { continue }
        if level < 20 {
            return member.name
        }
    }
    return nil
}

print("\n--- Level 5 · fixed functions ---")
for member in crew {
    print(reportOxygen(for: member))
}
print(firstCritical(in: crew) ?? "nobody critical")   // Timur (Lab dropped to 10% after the transfer)
print(firstCritical(in: []) ?? "nobody critical")

// Test that proves the logic bug is fixed: two critical members,
// with crew members without data in between. The FIRST one must win.
let testModuleOK = Module(name: "TestOK", oxygenTank: Tank(level: 80))
let testModuleA = Module(name: "TestA", oxygenTank: Tank(level: 5))
let testModuleB = Module(name: "TestB", oxygenTank: Tank(level: 15))
let testCrew = [
    CrewMember(name: "Healthy", role: "Test", priority: 1, module: testModuleOK),
    CrewMember(name: "NoTank",  role: "Test", priority: 2, module: dock),
    CrewMember(name: "First",   role: "Test", priority: 3, module: testModuleA),
    CrewMember(name: "Floater", role: "Test", priority: 4, module: nil),
    CrewMember(name: "Second",  role: "Test", priority: 5, module: testModuleB)
]
let critical = firstCritical(in: testCrew)
print("firstCritical test: got \(critical ?? "nil") -> \(critical == "First" ? "PASS" : "FAIL")")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("\nLAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var firedCount = 0
    return { level in
        guard level < threshold else { return false }
        firedCount += 1
        print("Alarm #\(firedCount)")
        return true
    }
}

print("\n--- Bonus · makeAlarm ---")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))   // Alarm #1 → true
print(alarm(40))   // false
print(alarm(5))    // Alarm #2 → true
let otherAlarm = makeAlarm(threshold: 50)
print(otherAlarm(30))  // Alarm #1 → true (own counter, independent of `alarm`)


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    - The value unwrapped by `guard let` stays available AFTER the guard, for
      the rest of the scope. With `if let` it only exists inside the braces.
    - The `else` of a guard MUST leave the scope (return / continue / break /
      throw), the compiler checks it. So guard = "early exit, then the happy
      path continues with no nesting".
    With if let, several checks turn into a "pyramid of doom":

        func report(_ m: CrewMember) -> String {
            if let module = m.module {
                if let tank = module.oxygenTank {
                    if tank.level >= 0 {
                        return "\(m.name): \(tank.level)%"   // the real logic is buried
                    } else { return "bad sensor" }
                } else { return "no tank" }
            } else { return "open space" }
        }

    With guard every failure is handled at the top, and the main code is flat:

        guard let module = m.module else { return "open space" }
        guard let tank = module.oxygenTank else { return "no tank" }
        return "\(m.name): \(tank.level)%"

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    `Int...` means "zero or more separate Int arguments". Swift packs them into
    an [Int] only INSIDE the function; to the caller the parameter type is still
    Int, one per argument. `stats(someArray)` passes a single [Int] where an Int
    is expected -> type mismatch. Swift has no "spread/splat" operator to
    explode an array into variadic arguments. That's why the array version
    stats(of:) exists and the variadic one just forwards to it.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    Law of Exclusivity: an inout parameter gets exclusive write access to its
    variable for the whole call. Passing the same variable twice creates two
    overlapping write accesses -> error "overlapping accesses to 'x'".
    It prevents aliasing bugs: inside the function `source` and `target` would
    be the same memory, so `source -= 5; target += 5` depends on the order of
    copy-back, the capacity check reads `target` that is actually the source,
    and a "transfer" into itself could create or destroy oxygen out of nothing.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    `a ?? b` requires `b` to be the same type as the value inside the optional.
    oxygenLevel returns Int?, so the default must be Int, but "no data" is a
    String. The result of ?? needs ONE type, and Int vs String can't be both.
    Fix: provide an Int (`?? 0`) or turn the level into a String first:
        if let level = oxygenLevel(of: dana) { print("\(level)%") } else { print("no data") }

 5. Full type of chooseProtocol and how to read it:
        (Int) -> (Int) -> Int
    The arrow is right-associative, so it means (Int) -> ((Int) -> Int):
    "a function that takes an Int (the current temperature) and returns
    a function that itself takes an Int and returns an Int".
    The argument label `for` is not part of the type (only of the name
    chooseProtocol(for:)). E.g.
        let f: (Int) -> (Int) -> Int = chooseProtocol
        f(10)(10)   // 15: first call picks heatUp, second call applies it

 Bonus. Where does the alarm counter live after makeAlarm returns?
    `firedCount` is a local variable, but since the returned closure captures it,
    Swift doesn't keep it on makeAlarm's stack frame. It is moved into a
    heap-allocated box, and the closure holds a (reference-counted) reference
    to that box. So the counter lives on the heap as long as the closure
    (`alarm`) is alive. Each call to makeAlarm creates a new box, which is why
    `alarm` and `otherAlarm` count independently.
*/
