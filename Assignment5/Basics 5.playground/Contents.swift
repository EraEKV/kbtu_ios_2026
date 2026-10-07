// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.





// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  -> A drone's battery is one physical
// object: every holder of the cell must see the same charge after spend/recharge,
// so it needs reference semantics, not a copy per variable.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

print("\n--- Level 1 · PowerCell ---")
let cell = PowerCell(charge: 130)
print("start (clamped from 130):", cell.level())          // 100
print("spend 30:", cell.spend(30), "->", cell.level())     // true -> 70
print("spend 0:", cell.spend(0), "->", cell.level())       // false -> 70
print("spend -5:", cell.spend(-5), "->", cell.level())     // false -> 70
print("spend 80:", cell.spend(80), "->", cell.level())     // false -> 70
cell.recharge(by: -10)
print("recharge -10 ->", cell.level())                     // 70
cell.recharge(by: 50)
print("recharge 50 ->", cell.level())                      // 100
print("PowerCell(charge: -20):", PowerCell(charge: -20).level())   // 0

// Encapsulation proof (leave this commented, with the compiler error):
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  -> No subclass can override the
// shift ritual, so every drone is guaranteed to pay its powerCost before it does
// any work — subclasses may only change the cost and the work, never skip the payment.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }

    var canRunOnce: Bool {
        cell.level() >= powerCost
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }

    func weldSeam() -> String {
        "\(id) welded a hull seam"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

print("\n--- Level 2 · Fleet ---")
var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("WARNING: unknown drone kind '\(record.kind)' for \(record.id), record skipped")
    }
}
print("Fleet assembled: \(fleet.count) drones")
for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var totalWork = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

print("\n--- Level 3 · Shift ---")
let A = runShift(fleet, rounds: 3)

var B = 0
var C = 0
for drone in fleet {
    print(drone.statusLine)
    B += drone.cell.level()
    if drone.canRunOnce {
        C += 1
    }
}
print("Work units: \(A), remaining charge: \(B), ready for one more task: \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  -> Drone is a class:
// recharging changes the object the reference points to, not the reference itself,
// so self is never replaced and there is nothing for `mutating` to mark.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { statusCode(forCharge: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { statusCode(forCharge: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  -> SensorModule is a struct, and a
// struct can't inherit from a class, so it is never a Drone; the only thing the two
// share is the Diagnosable protocol.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = "=== DIAGNOSTICS: \(components.count) components ==="
    var codeTotal = 0
    for component in components {
        report += "\n" + component.diagnose()
        codeTotal += component.statusCode
    }
    report += "\nstatus code total: \(codeTotal)"
    return report
}

print("\n--- Level 4 · Diagnostics ---")
var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))

// Rechargeable on a struct: works on a var copy, the array element stays untouched.
var spareSensor = sensors[0]
spareSensor.recharge(by: 50)
print("spare \(spareSensor.componentID): \(spareSensor.chargeLevel)%, original still \(sensors[0].chargeLevel)%")


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        "\(componentID): code \(statusCode)"
    }

    /// The Health Rule. The only place in the file where the thresholds live.
    func statusCode(forCharge charge: Int) -> Int {
        if charge < 20 { return 2 }
        if charge < 50 { return 1 }
        return 0
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { statusCode(forCharge: signalStrength) }

    func diagnose() -> String {
        "[LEGACY] \(name) · signal \(signalStrength) · code \(statusCode) · original-station hardware, check manually"
    }
}

print("\n--- Level 5 · Diagnostics with beacon ---")
components.append(beacon)
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}

// 5.3
extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        var bar = ""
        for slot in 0..<10 {
            bar += slot < filled ? "#" : "."
        }
        return bar
    }
}

print("\n--- 5.3 powerBar ---")
for value in [42, 0, 9, 100, -5, 250] {
    print(value, value.powerBar)
}


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

/*
 Report 1 · PatchDrone
   Expected: a drone that produces 30 units per runOnce().
   Actual:   does not build (Swift 6.2):
             error: overriding declaration requires an 'override' keyword
   Rule:     a subclass method with the same signature as a superclass method is
             an override, and Swift requires it to be marked `override` explicitly,
             so you can't replace parent behaviour by accident (and can't think you
             override something when the signature doesn't actually match).
   Fix:      `override func performTask() -> Int { 30 }`  (see PatchDrone below).

 Report 2 · HeavyWelder
   Expected: a welder whose shift always reports 999 units, free of charge.
   Actual:   does not build, two errors:
             error: inheritance from a final class 'WelderDrone'
             error: instance method overrides a 'final' instance method
   Rule:     a `final` class can't have subclasses, a `final` method can't be
             overridden. runOnce() is the ritual that charges the battery — final
             exists precisely to stop "999 units for 0 energy".
   Fix:      don't touch the ritual. Subclass Drone (WelderDrone is final) and change
             only the cost and the work: see HeavyWelder below.

 Report 3 · weldSeam() through [Drone]
   Expected: the first element is a WelderDrone, so it can weld.
   Actual:   does not build:
             error: value of type 'Drone' has no member 'weldSeam'
   Rule:     the compiler only knows the static type. `reportFleet[0]` is a Drone, and
             Drone has no weldSeam(); what the object really is gets decided at runtime.
   Fix:      ask at runtime with a conditional downcast `as?` (below).
             `as?` returns an optional because the cast can fail — the element might be a
             ScannerDrone — and instead of crashing Swift gives you nil to handle.

   (Note: in Swift 6.2 Reports 1, 2 and 3 all fail to compile; Report 4 is the one
   that compiles and lies.)

 Report 4 · Thruster label
   Expected: "thruster T-1".
   Actual:   compiles and prints "generic component".
   Rule:     label() is NOT a requirement of Labelled, it only lives in the protocol
             extension. Such methods are statically dispatched: the call is resolved by
             the static type of the expression. parts[0] has type `any Labelled`, so the
             compiler calls Labelled's extension version; Thruster's label() is just an
             unrelated method with the same name, it never got into the witness table.
             Requirements are dynamically dispatched through the witness table, so the
             conforming type's implementation wins.
   Fix:      one line — declare it in the protocol:  `func label() -> String`
             (see LabelledFixed below, prints "thruster T-1").
*/

print("\n--- Level 6 · Incident fixes ---")

// Report 1 fix
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}
let patch = PatchDrone(id: "P-1", cell: PowerCell(charge: 50))
print("Report 1:", patch.runOnce(), "units, \(patch.statusLine)")   // 30 units, 40%

// Report 2 fix
final class HeavyWelder: Drone {
    override var powerCost: Int { 50 }
    override func performTask() -> Int { 90 }
}
let heavy = HeavyWelder(id: "H-1", cell: PowerCell(charge: 60))
print("Report 2:", heavy.runOnce(), heavy.runOnce(), "-> \(heavy.statusLine)")   // 90 0, 10%

// Report 3 fix
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print("Report 3:", welder.weldSeam())
}

// Report 4 fix
protocol LabelledFixed {
    var componentID: String { get }
    func label() -> String          // <- the one line that changes the output
}

extension LabelledFixed {
    func label() -> String { "generic component" }
}

struct Thruster: LabelledFixed {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [LabelledFixed] = [Thruster(componentID: "T-1")]
print("Report 4:", parts[0].label())   // thruster T-1


// MARK: Finale · Mission Code

print("\n--- Finale ---")
let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// Two ways to forbid using Drone directly; a protocol-based redesign;
// two or three sentences comparing them.

// B1 · Runtime: the base class checks its own dynamic type in init.
// (A separate demo class, so the graded Drone keeps the signature from the task.)
class AbstractDrone {
    let id: String

    init(id: String) {
        precondition(type(of: self) != AbstractDrone.self,
                     "AbstractDrone is abstract: create a subclass")
        self.id = id
    }

    func performTask() -> Int {
        fatalError("\(type(of: self)) must override performTask()")
    }
}

final class DemoWelder: AbstractDrone {
    override func performTask() -> Int { 40 }
}

print("\n--- Bonus ---")
print("B1 runtime:", DemoWelder(id: "DW-1").performTask())
// let bare = AbstractDrone(id: "X")
// compiles, but crashes when run: Precondition failed: AbstractDrone is abstract: create a subclass

// B1 · Compile time: make the base a protocol. A protocol has no initializer and
// its performTask() has no default, so a conformer that forgets it doesn't build.
// let bare = RepairDrone()
// error: 'any RepairDrone' cannot be constructed because it has no accessible initializers

// B2 · The fleet rebuilt on a protocol + protocol extension, WelderDrone as a struct.
protocol RepairDrone: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    var statusLine: String { get }
    func performTask() -> Int
}

extension RepairDrone {
    var componentID: String { id }
    var statusCode: Int { statusCode(forCharge: cell.level()) }
    var powerCost: Int { 10 }

    // No `super` for protocols, so the shared part gets its own name.
    var baseStatusLine: String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }
    var statusLine: String { baseStatusLine }

    // Not a requirement -> statically dispatched, conformers can't hook into it:
    // the same guarantee `final` gave us on the class.
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

enum ProtocolFleet {
    struct WelderDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        var powerCost: Int { 25 }
        func performTask() -> Int { 40 }
        func weldSeam() -> String { "\(id) welded a hull seam" }
    }

    struct ScannerDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        func performTask() -> Int { 15 }
        var statusLine: String { baseStatusLine + " [scanner]" }
    }

    struct CargoDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        var powerCost: Int { 20 }
        func performTask() -> Int { 25 }
    }

    static func make(kind: String, id: String, charge: Int) -> RepairDrone? {
        let cell = PowerCell(charge: charge)
        switch kind {
        case "welder":  return WelderDrone(id: id, cell: cell)
        case "scanner": return ScannerDrone(id: id, cell: cell)
        case "cargo":   return CargoDrone(id: id, cell: cell)
        default:        return nil
        }
    }
}

var protocolFleet: [RepairDrone] = []
for record in fleetData {
    if let drone = ProtocolFleet.make(kind: record.kind, id: record.id, charge: record.charge) {
        protocolFleet.append(drone)
    }
}
var protocolWork = 0
for _ in 0..<3 {
    for drone in protocolFleet {
        protocolWork += drone.runOnce()
    }
}
var protocolCharge = 0
for drone in protocolFleet {
    protocolCharge += drone.cell.level()
}
print("B2 protocol fleet: work \(protocolWork), charge \(protocolCharge) (same as A=\(A), B=\(B))")

// B3 · Comparison.
// The class design gives real `final` on the ritual, `super` for reusing a parent's
// statusLine, and one shared object per drone; the protocol design can't be
// instantiated directly, lets structs and even foreign types join, but has no `super`
// (ScannerDrone needed a separate baseStatusLine) and no way to truly seal runOnce().
// For this station I'd keep the class hierarchy: a drone is a physical thing with an
// identity and a battery that the shift and the diagnostics screen must both see.
// If drones had to share mutable state, struct drones would copy it on every
// assignment, so that state has to live in a reference type anyway (here it already
// does — PowerCell is a class, which is the only reason the struct fleet works).


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    `mutating` means "this method may change self", i.e. self is passed as inout.
    For a struct, self IS the value, so changing chargeLevel changes self — the
    method must be marked mutating, and it can only be called on a var.
    For a class, self is a reference; recharge(by:) changes the object on the heap
    (Drone just forwards to its PowerCell), the reference itself never changes.
    So a class method can always satisfy a mutating requirement, and Swift
    doesn't even allow the word `mutating` inside a class.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance: shares stored state and real implementation through a chain —
    subclasses inherit id/cell and the init, can call `super` (ScannerDrone's
    statusLine) and the parent can seal behaviour with `final` (runOnce).
    Protocols: work across kinds of types — a class (Drone), a struct
    (SensorModule) and a type I can't edit (LegacyBeacon via an extension) all
    became Diagnosable; a type can also conform to many protocols, but has only
    one superclass, and structs/enums can't inherit at all.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` on a class forbids subclassing it; on a method/property it forbids
    overriding it (and lets the compiler call it directly, without dynamic
    dispatch). On runOnce() it protects the shift ritual: no subclass can skip
    cell.spend(powerCost) and return work for free (Report 2's 999 units with
    no energy spent). Subclasses can only change powerCost and performTask().

 4. In Report 4, why did the protocol extension's method win?
    Because label() was not a protocol requirement. Only requirements go into
    the protocol witness table and are dispatched dynamically. A method that
    exists only in an extension is dispatched statically by the declared type
    of the expression; parts[0] is `any Labelled`, so the compiler picked
    Labelled's extension version without looking at the real Thruster. Adding
    `func label() -> String` to the protocol makes it a requirement, and
    Thruster's implementation wins.

*/
