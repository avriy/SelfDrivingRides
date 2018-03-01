
struct Cell {
    let position: Point
    var rides: [Ride] // sorted by time, please remove start point
    
    func rides(from point: Point, at currentTime: Int) -> [Ride] {
        return rides.filter { $0.time.upperBound > currentTime + $0.distance + Point.distance(point, position) }
    }
}

extension Ride {
    func score(from point: Point, at currentTime: Int, bonus: Int) -> Int {// return 0 just to filter the points
        var result = distance
        if (currentTime + Point.distance(point, start)) <= time.lowerBound {
            result += bonus
        }
        return result
    }
}

class RealAlgo: Algorithm {
    
    var city = [Point : Cell]()
    let problem: Problem
    
    init(problem: Problem) {
        self.problem = problem
        
        city = [Point : Cell]()
        
        for ride in problem.rides {
            if var cell = city[ride.start] {
                cell.rides.append(ride)
                city[ride.start] = cell
            } else {
                city[ride.start] = Cell(position: ride.start, rides: [ride])
            }
        }
    }
    
    func findNextRide(t: Int, currentPosition: Point) -> Ride? {
        // choose the ride
        
        let allRides = city.values.flatMap{ $0.rides(from: currentPosition, at: t) }
        var bestRide: Ride? = nil
        var bestRideScore = 0
        
        for ride in allRides {
            let score = ride.score(from: currentPosition, at: t, bonus: problem.bonus)
            if score > bestRideScore {
                bestRideScore = score
                bestRide = ride
            }
        }
        
        return bestRide
    }
    
    func clear(ride: Ride) {
        guard var currentRides = city[ride.start]?.rides else { return }
        guard let index = currentRides.index(of: ride) else { return }
        currentRides.remove(at: index)
        if currentRides.isEmpty {
            city[ride.start] = nil
        } else {
            city[ride.start] = Cell(position: ride.start, rides: currentRides)
        }
    }
    
    func solveForCar() -> [Int] {
        var t = 0
        var currentPosition = Point(x: 0, y: 0)
        var result = [Int]()
        
        while t < problem.numberOfSteps {
            guard let nextRide = findNextRide(t: t, currentPosition: currentPosition) else {
                return result
            }
            clear(ride: nextRide)
            if t < nextRide.time.lowerBound {
                t += nextRide.time.lowerBound - t
            }
            t += nextRide.distance
            currentPosition = nextRide.stop
            result.append(nextRide.index)
        }
        
        return result
    }
    
    func output() -> String {
        return Array(0..<problem.fleetSize).map { index in
            let thisCarResult = solveForCar()
            return ([thisCarResult.count] + thisCarResult).map { $0.description } .joined(separator: " ")
            }.joined(separator: "\n")
    }
}

extension Point {
    func roundPoints(delta maxDelta: Int) -> [Point] {
        var result = [Point]()
        result += [self]
        for delta in 0..<maxDelta {
            for i in 0..<delta {
                result += [Point(x: x + i, y: y + delta - i),
                           Point(x: x + delta - i, y: y - i),
                           Point(x: x - i, y: y - delta + i),
                           Point(x: x - delta + i, y: y + i)]
            }
        }
        return result
    }
}

extension Ride: Equatable {
    static func == (lhs: Ride, rhs: Ride) -> Bool {
        return lhs.index == rhs.index
    }
}

extension Point: Hashable {
    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    var hashValue: Int {
        return x << 11 ^ y
    }
}
