// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.



// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("\n--- 1.1 Deck ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}
print(Deck(rawValue: "greenhouse") as Any)   // nil

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass, 0) / 500, AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print("\n--- 1.2 AlarmLevel ---")
print(AlarmLevel.level(forTotalMass: 0))      // green
print(AlarmLevel.level(forTotalMass: 940))    // yellow
print(AlarmLevel.level(forTotalMass: 1499))   // orange
print(AlarmLevel.level(forTotalMass: 4000))   // red


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    switch parts[0] {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) {
            return .crate(id: id, massKg: massKg)
        }
    case "container":
        if parts.count == 3, parts[1].isEmpty == false, let massKg = Int(parts[2]) {
            return .container(code: parts[1], massKg: massKg)
        }
    case "livestock":
        if parts.count == 4, parts[1].isEmpty == false,
           let count = Int(parts[2]), let perUnit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: perUnit)
        }
    default:
        break
    }
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg):
        return massKg
    case let .container(_, massKg):
        return massKg
    case let .livestock(_, count, massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("\n--- 2.x Manifest ---")
var totalMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    if case .unknown = entry {
        unknownCount += 1
    }
    totalMass += mass(of: entry)
    print("\(entry) -> \(mass(of: entry)) kg")
}
print("total mass: \(totalMass) kg, unknown lines: \(unknownCount)")

let A = totalMass
print("Fragment A = \(A)")


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(oxygen - amount, 0)
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("\n--- 3.1 CrewSnapshot ---")
var rookie = CrewSnapshot.rookie(named: "Aruzhan")
print(rookie)
rookie.breathe(130)
rookie.move(to: .engine)
print(rookie)
rookie.reviveInMedbay()
print(rookie)

// 3.2
func buildRoster(from records: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var result: [CrewSnapshot] = []
    for record in records {
        guard let deck = Deck(rawValue: record.deck) else {
            print("warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
            continue
        }
        result.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return result
}

print("\n--- 3.2 Roster ---")
let crewRoster: [CrewSnapshot] = buildRoster(from: crewData)
for member in crewRoster {
    print("\(member.name) @ \(member.deck), O2 \(member.oxygen)")
}
print(buildRoster(from: [(name: "Ghost", deck: "greenhouse", oxygen: 50)]).count)

// 3.3
func drainCopy(_ crew: CrewSnapshot) {
    var crew = crew
    crew.breathe(30)
    print("  inside drainCopy: \(crew.oxygen)")
}

func drainInPlace(_ crew: inout CrewSnapshot) {
    crew.breathe(30)
    print("  inside drainInPlace: \(crew.oxygen)")
}

print("\n--- 3.3 Value semantics ---")
var original = CrewSnapshot.rookie(named: "Timur")
print("1) copy — before: original \(original.oxygen)")
var copy = original
copy.breathe(40)
print("1) copy — after:  original \(original.oxygen), copy \(copy.oxygen)")

print("2) plain param — before: \(original.oxygen)")
drainCopy(original)
print("2) plain param — after:  \(original.oxygen)")

print("3) inout — before: \(original.oxygen)")
drainInPlace(&original)
print("3) inout — after:  \(original.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1
// CrewSnapshot got a memberwise init because structs get one synthesized.
// Classes never get a memberwise init, and `id`/`chargeLevel` have no default,
// so without an explicit init the class would not compile.
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    deinit {
        print("deinit: pod \(id) released")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }
}

func findCrew(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    for member in roster where member.name == name {
        return member
    }
    return nil
}

// 4.2
print("\n--- 4.2 Charge ledger ---")
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
print("start: charge \(ledgerPod.chargeLevel)")
for name in ["Timur", "Dana", "Nurlan"] {
    guard let member = findCrew(named: name, in: crewRoster) else {
        print("\(name) not in roster")
        continue
    }
    let loaded = ledgerPod.load(member)
    let arrived = ledgerPod.fire()
    print("\(name): loaded \(loaded), arrived \(arrived?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")
}
let emptyShot = ledgerPod.fire()
print("empty fire: arrived \(emptyShot?.name ?? "nobody"), charge \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel
print("Fragment C = \(C)")

// 4.3
print("\n--- 4.3 Reference semantics ---")
let podOne = TeleportPod(id: "R-1", chargeLevel: 80)
let podTwo = podOne
podTwo.chargeLevel = 15
print("class:  podOne \(podOne.chargeLevel), podTwo \(podTwo.chargeLevel)")   // 15, 15

var snapOne = CrewSnapshot.rookie(named: "Dana")
var snapTwo = snapOne
snapTwo.oxygen = 15
print("struct: snapOne \(snapOne.oxygen), snapTwo \(snapTwo.oxygen)")          // 100, 15
// Assigning a class copies the reference (both names share one object); assigning a struct copies the value.


// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]

    var hullIntegrity: Int {
        willSet {
            print("hull: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "\(callSign) | hull \(hullIntegrity)%"
        for deck in Deck.allCases {
            report += " | \(deck.rawValue): \(oxygenByDeck[deck] ?? 0)"
        }
        return report
    }()

    var totalOxygen: Int {
        var sum = 0
        for (_, level) in oxygenByDeck {
            sum += level
        }
        return sum
    }

    var averageOxygen: Int {
        get {
            oxygenByDeck.isEmpty ? 0 : totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in oxygenByDeck.keys {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = 100
        var levels: [Deck: Int] = [:]
        for reading in readings {
            if let deck = Deck(rawValue: reading.deck) {
                levels[deck] = reading.oxygen
            }
        }
        self.oxygenByDeck = levels
    }
}

print("\n--- 5.1 Station ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen
print("total O2 \(station.totalOxygen), average \(station.averageOxygen)")
print("Fragment B = \(B)")

let spareStation = Station(callSign: "ALMA-8", readings: deckReadings)
print("spare station \(spareStation.callSign) created, diagnostics never touched -> no scan above")

print("first access:")
print(station.fullDiagnostics)
print("second access:")
print(station.fullDiagnostics)   // no "Running full scan..." this time

station.averageOxygen = 70
print("after averageOxygen = 70: \(station.oxygenByDeck[.cargo] ?? 0) on cargo, total \(station.totalOxygen)")

// 5.2
// Assigning to the property inside its own didSet does not call the observers
// again — Swift sets the storage directly there, so the clamp can't recurse.
print("\n--- 5.2 Clamp trap ---")
station.hullIntegrity = 130
print("hull = \(station.hullIntegrity)")   // 100
station.hullIntegrity = -40
print("hull = \(station.hullIntegrity)")   // 0
station.hullIntegrity = 55
print("hull = \(station.hullIntegrity)")   // 55


// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

/*
 Report 1 — compiles, wrong.
   Expected: every crew member loses 10 oxygen.
   Actual:   roster[0].oxygen is still 62. `member` is a copy of each element;
             only the copy changes and is thrown away.
   Rule:     structs are value types; the loop variable is a copy, not a reference.

 Report 2 — compiles, wrong.
   Expected: podA keeps 100 because podB is "a copy".
   Actual:   prints 0. `let podB = podA` copies the reference, both names point
             at the same pod.
   Rule:     classes are reference types. For an independent pod, create a new one.

 Report 3 — does not compile.
   Expected: add() appends to the log.
   Actual:   error: cannot use mutating member on immutable value: 'self' is immutable.
   Rule:     a struct method can't change stored properties unless it's `mutating`.

 Report 4 — the snapshot line does not compile, the pod line does.
   `let` on a struct freezes the whole value, including every var property:
     error: cannot assign to property: 'snapshot' is a 'let' constant.
   `let` on a class freezes only the reference (can't point `pod` at another
   object); the object's var properties are still mutable.
*/

print("\n--- 6 Fixes ---")
do {
    // Report 1: write back through the index
    var roster = crewRoster
    for index in roster.indices {
        roster[index].oxygen -= 10
    }
    print("report 1: \(crewRoster[0].oxygen) -> \(roster[0].oxygen)")
}
do {
    // Report 2: two separate objects
    let podA = TeleportPod(id: "A", chargeLevel: 100)
    let podB = TeleportPod(id: "A-copy", chargeLevel: podA.chargeLevel)
    podB.chargeLevel = 0
    print("report 2: podA \(podA.chargeLevel), podB \(podB.chargeLevel)")
}
do {
    // Report 3: mark the method mutating
    struct Logbook {
        var entries: [String] = []
        mutating func add(_ entry: String) {
            entries.append(entry)
        }
    }
    var logbook = Logbook()
    logbook.add("day 10: teleporter fault")
    logbook.add("day 11: manifest rebuilt")
    print("report 3: \(logbook.entries.count) entries")
    print("report 3: \(logbook.entries)")
}
do {
    // Report 4: the struct must be var; the class line was already fine
    var snapshot = CrewSnapshot.rookie(named: "Dana")
    snapshot.oxygen = 40
    let pod = TeleportPod(id: "B", chargeLevel: 50)
    pod.chargeLevel = 10
    print("report 4: snapshot \(snapshot.oxygen), pod \(pod.chargeLevel)")
}


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

// blocks subclassing, so no override can reopen the recorder
final class FlightRecorder {
    // blocks any outside read or write of the list: no replace, clear or direct append
    private var entries: [String] = []

    // blocks outside writes, so isSealed can't be reset to false
    private(set) var isSealed = false

    // blocks access from other modules only; read-only by being computed
    internal var entryCount: Int {
        entries.count
    }

    // blocks access from other modules only; returns a copy, not the storage
    internal var transcript: String {
        numberedLines().joined(separator: "\n")
    }

    // blocks access from other modules only; refuses writes after seal()
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        if isSealed {
            return false
        }
        entries.append(entry)
        return true
    }

    // blocks access from other modules only; there is no unseal
    internal func seal() {
        isSealed = true
    }

    // blocks use from other files; auditTranscript below still needs it
    fileprivate func numberedLines() -> [String] {
        var lines: [String] = []
        for (index, entry) in entries.enumerated() {
            lines.append("\(index + 1). \(entry)")
        }
        return lines
    }
}

func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.numberedLines()
    let status = recorder.isSealed ? "SEALED" : "OPEN"
    return "[\(status), \(lines.count) entries] " + lines.joined(separator: " / ")
}

print("\n--- 7 FlightRecorder ---")
let recorder = FlightRecorder()
recorder.add("teleporter fired x3")
recorder.add("crew duplicated on medbay")
print("entries: \(recorder.entryCount), sealed: \(recorder.isSealed)")
recorder.seal()
let lateWrite = recorder.add("nothing happened, honest")
print("late write accepted: \(lateWrite), entries: \(recorder.entryCount)")
print(recorder.transcript)
print(auditTranscript(of: recorder))

// Attempts to break it from outside:
// recorder.entries = []
//   error: 'entries' is inaccessible due to 'private' protection level
// recorder.entries.append("fake")
//   error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
//   error: cannot assign to property: 'isSealed' setter is inaccessible


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("\nINTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity

print("\n--- Bonus: deinit ---")
var survivor: TeleportPod?
print("before do")
do {
    let tempPod = TeleportPod(id: "TMP-1", chargeLevel: 30)
    survivor = tempPod
    print("inside do: pod \(tempPod.id) has two references")
}
print("after do: pod \(survivor?.id ?? "none") still alive")
survivor = nil   // deinit fires here
print("after survivor = nil")

extension CrewSnapshot: Equatable {}

func describeIdentity(_ first: TeleportPod, _ second: TeleportPod) -> String {
    if first === second {
        return "same pod (\(first.id))"
    }
    if first.id == second.id, first.chargeLevel == second.chargeLevel, first.occupant == second.occupant {
        return "two different pods with equal contents"
    }
    return "two different pods"
}

print("\n--- Bonus: identity ---")
let recordOne = TeleportPod(id: "M-1", chargeLevel: 60)
let recordTwo = recordOne
let lookalike = TeleportPod(id: "M-1", chargeLevel: 60)
print(describeIdentity(recordOne, recordTwo))
print(describeIdentity(recordOne, lookalike))
print(describeIdentity(recordOne, ledgerPod))


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    Structs get a synthesized memberwise init (CrewSnapshot(name:deck:oxygen:)).
    Classes only get a free init() when every stored property has a default
    value. TeleportPod's id and chargeLevel have none, so I had to write
    init(id:chargeLevel:) myself. Classes skip memberwise inits because of
    inheritance: a subclass would have to know and forward every field.

 2. What does `mutating` do to self, and why do classes never need it?
    Inside a mutating method `self` is passed as inout: the method may change
    properties or replace self entirely (reviveInMedbay does `self = ...`), and
    the new value is written back to the caller's variable. That's also why you
    can't call it on a `let` struct. A class method works through a reference;
    it changes the object on the heap, not the reference itself, so there is
    nothing to mark.

 3. In Report 4 both values are `let`. What exactly does `let` freeze?
    Struct: the variable holds the whole value, so `let` freezes all of it —
    no property can change, even ones declared `var`.
        let s = CrewSnapshot.rookie(named: "Dana"); s.oxygen = 40   // error
    Class: the variable holds only a reference. `let` freezes the reference
    (pod can't point at another pod), not the object it points to.
        let pod = TeleportPod(id: "B", chargeLevel: 50); pod.chargeLevel = 10   // ok
        pod = TeleportPod(id: "C", chargeLevel: 0)                               // error

 4. Why must a lazy property be var? When does lazy change behaviour?
    A `let` must have its value by the end of init; a lazy property gets its
    value later, on first access, so its storage is written after init — only
    var allows that.
    Behaviour change: fullDiagnostics captures the state at the moment of
    first access, not at init. Read it before `hullIntegrity = 55` and it
    says "hull 100%" forever; read it after and it says "55%". Its side effect
    (printing "Running full scan...") also happens at that moment, or never
    if nobody reads the property — spareStation never printed it.

 5. private vs fileprivate: where would private be too strict?
    numberedLines() is needed by auditTranscript(of:), a free function outside
    the class body. If it were private, only code inside FlightRecorder (and its
    extensions in this file) could call it, and auditTranscript wouldn't compile.
    fileprivate lets that one function in the same file use it, while code in
    other files still can't. entries stays private because nothing outside the
    class needs to touch it at all.

 Bonus. On which line does deinit fire, and why can't === be used on CrewSnapshot?
    deinit fires on `survivor = nil`, not at the end of the do block. Leaving
    the block drops `tempPod`, but `survivor` still holds a strong reference,
    so the reference count goes 2 -> 1. Setting survivor to nil drops it to 0,
    and ARC frees the pod immediately, which runs deinit.
    === compares object identity: "are these two references the same instance
    on the heap?". A struct has no identity — each variable holds its own copy
    of the value, there's no shared instance to point to. So === is only
    defined for class instances (AnyObject); on CrewSnapshot it doesn't compile.
    For structs you compare contents with == (Equatable) instead.
*/
