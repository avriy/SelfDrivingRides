import Foundation

struct Problem {
    let rows: Int
    let columns: Int
    let fleetSize: Int
    let bonus: Int // for starting ride on time
    let numberOfSteps: Int
    let rides: [Ride]
    
    func algo() -> Algorithm {
        return RealAlgo(problem: self)
    }
}

struct EmptyAlgo: Algorithm {
    func output() -> String { return "" }
}

protocol Algorithm {
    func output() -> String
}

struct Point {
    let x: Int
    let y: Int
}

extension Point {
    static func distance(_ p1: Point, _ p2: Point) -> Int {
        return abs(p1.y - p2.y) + abs(p1.x - p2.x)
    }
}

struct Ride {
    let start: Point
    let stop: Point
    let time: Range<Int>
    let index: Int
    
    var distance: Int {
        return abs(stop.y - start.y) + abs(stop.x - start.x)
    }
}

extension Ride {
    init(string: String, index: Int) {
        let components = string.components(separatedBy: " ").map { Int($0)! }
        let start = Point(x: components[0], y: components[1])
        let stop = Point(x: components[2], y: components[3])
        let range = Range(components[4]...components[5])
        self = Ride(start: start, stop: stop, time: range, index: index)
    }
}

func parse(input: String) -> Problem {
    let components = input.components(separatedBy: .newlines).filter { !$0.isEmpty }
    guard let first = components.first else {
        fatalError()
    }
    let fsi = first.components(separatedBy: " ").map { Int($0)! }
    let rides = components.dropFirst().enumerated().map { Ride(string: $1, index: $0) }
    return Problem(rows: fsi[0], columns: fsi[1], fleetSize: fsi[2], bonus: fsi[3], numberOfSteps: fsi[3], rides: rides)
}

if let inputFileIndex = CommandLine.arguments.index(of: "-p"), inputFileIndex + 1 < CommandLine.arguments.count,
    let outputFileIndex = CommandLine.arguments.index(of: "-o"), outputFileIndex + 1 < CommandLine.arguments.count {
    do {
        let inputFileURL = URL(fileURLWithPath: CommandLine.arguments[inputFileIndex + 1])
        let outputFileURL = URL(fileURLWithPath: CommandLine.arguments[outputFileIndex + 1])
        let string = try String(contentsOf: inputFileURL)
        let s = parse(input: string)
        let result = s.algo()
        try result.output().write(to: outputFileURL, atomically: true, encoding: .utf8)
    } catch {
        print("Failed with \(error)")
        exit(1)
    }
} else {
    
    let testInput =
    "3 4 2 3 2 10\n" + "0 0 1 3 2 9\n" + "1 2 1 0 0 9\n" + "2 0 2 2 0 9"
    
    let s = parse(input: testInput)
    let result = s.algo()
    print(result.output())
}

