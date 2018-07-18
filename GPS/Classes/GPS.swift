import UIKit
import CoreLocation


/// GPS provides an library for many calculations involving GPS and earth.
///
/// A `GPS` instance contains a latitude and longitude and is used for performing operations in the GPS library. `GPS` instances have a few instance methods. All instance methods use public static methods for the calculations.


public class GPS {
    
    // MARK: Properties
    public var latitude:Double
    public var longitude:Double
    
    
    // MARK: Initializers
    /// Initiazlizes a new `GPS` object
    /// - Parameter latitude: Latitude of the GPS coordinate
    /// - Parameter longitude: Longitude of the GPS coordinate
    public init(latitude:Double, longitude:Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Initiazlies a new `GPS` object
    /// - Parameter locationCoordinate: A `CLLocationCoordinate2D` to create the `GPS` object from.
    public init(locationCoordinate:CLLocationCoordinate2D) {
        self.longitude = locationCoordinate.longitude
        self.latitude = locationCoordinate.latitude
    }
    
    // MARK: Instance Methods
    /// Distance to a point using the Equitectangular formula. Units will match planet radius units. Less accurate than Haversine but less time consuming.
    /// - Parameter gps: Distance to this `GPS` coordinate
    /// - Returns: Distance in units matching `GPS.planetRadius` units.
    public func distanceToEquirectangular(gps:GPS) -> Double {
        return GPS.distanceBetweenEquirectangular(f: self, s: gps)
    }
    
    /// Distance to a point using the Haversine formula. More accurate than equirectangular but more time consuming.
    /// - Parameter gps: Distance to this `GPS` coordinate
    /// - Returns: Distance in units matching `GPS.planetRadius` units.
    public func distanceToHaversine(gps:GPS) -> Double {
        return GPS.distanceBetweenHaversine(f: self, s: gps)
    }
    
    /// Returns the GPS coordinates on the other side of the world from the instance `GPS`. (If you were to dig a hole perfectly straight this is where you would end up)
    /// - Returns: A `GPS` coordinate referring to the opposite side of the planet.
    public func oppositeCoordinate() -> GPS {
        return GPS.oppositeCoordinate(gps: self)
    }
    /// Calculate the time of sunrise at the instance `GPS`
    /// - Parameter date: Requested `Date` for sunrise time. (UTC)
    /// - Parameter sunZenith: Requested `GPS.SunZenith` for sunrise time
    /// - Returns: `Date` of the sunrise time (UTC). Null if no sunrise on this day
    public func sunriseTime(date:Date, sunZenith:SunZenith) -> Date? {
        return GPS.sunriseTime(gps: self, date: date, sunZenith: sunZenith)
    }
    /// Calculate the time of sunset at the instance `GPS`
    /// - Parameter date: Requested `Date` for sunset time. (UTC)
    /// - Parameter sunZenith: Requested `GPS.SunZenith` for sunset time
    /// - Returns: `Date` of the sunset time (UTC). Null if no sunset on the day
    public func sunsetTime(date:Date, sunZenith:SunZenith) -> Date? {
        return GPS.sunsetTime(gps: self, date: date, sunZenith: sunZenith)
    }
    /// Calculate the duration of the day at the instance `GPS`
    /// - Parameter date: The requested `Date` for day duration
    /// - Parameter sunZenith: The requested `GPS.SunZenith` for calculating sunrise and sunset and the difference.
    /// - Returns: Day duration in seconds. 0 if no sunrise or no sunset on this day.
    public func dayDuration(date:Date, sunZenith:SunZenith) -> Double {
        return GPS.dayDuration(gps: self, date: date, sunZenith: sunZenith)
    }
    /// Calculate the heading to another `GPS`
    /// - Parameter gps: `GPS` to find the heading to.
    /// - Returns: The heading to the given `GPS` in degrees. (between 0 and 360)
    /// - warning: Headings are not calculated over the poles.
    public func headingTo(gps:GPS) -> Double {
        return GPS.headingBetweenCoordinates(f: self, s: gps)
    }
    
    
    
    // MARK: Static Vars
    
    public static let MAX_LATITUDE:Double = +90.0
    public static let MIN_LATITUDE:Double = -90.0
    public static let MIN_LONGITUDE:Double = -180.0
    public static let MAX_LONGITUDE:Double = 180.0
    /// Radius of Earth (Miles)
    public static let EARTH_RADIUS:Double = 3959.0
    /// Radius of Earth (Kilometers)
    public static let EARTH_RADIUS_METRIC:Double = EARTH_RADIUS * 1.60934
    /// Radius of Moon (Miles)
    public static let MOON_RADIUS:Double = 1079.0
    /// Radius of Moon (Kilometers)
    public static let MOON_RADIUS_METRIC:Double = MOON_RADIUS * 1.60934
    /// Radius of Mars (Miles)
    public static let MARS_RADIUS:Double = 2106.0
    /// Radius of Mars (Kilometers)
    public static let MARS_RADIUS_METRIC:Double = MARS_RADIUS * 1.60934
    /// Planet Radius used for calculations. Defaults to radius of Earth in Miles.
    public static var planetRadius = EARTH_RADIUS
    
    // MARK: Static Functions
    
    /// Returns the distance from point f to point s using the haversine formula (Unites will match the planet radius units)
    public static func distanceBetweenHaversine(f:GPS,s:GPS) -> Double {
        let long1 = degreesToRadians(degrees: f.longitude)
        let long2 = degreesToRadians(degrees: s.longitude)
        let lat1 = degreesToRadians(degrees: f.latitude)
        let lat2 = degreesToRadians(degrees: s.latitude)
        let longDifference = abs(long1 - long2)
        let latDifference = abs(lat1 - lat2)
        let a = pow(sin(latDifference/2), 2) + cos(lat1) * cos(lat2) * pow(sin(longDifference/2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return c * planetRadius
    }
    
    /*
     ///Returns the distance from point f to point s in kilometers using the haversine formula
     public static func distanceBetweenHaversineMetric(f:GPS,s:GPS) -> Double {
     let long1 = degreesToRadians(degrees: f.longitude)
     let long2 = degreesToRadians(degrees: s.longitude)
     let lat1 = degreesToRadians(degrees: f.latitude)
     let lat2 = degreesToRadians(degrees: s.latitude)
     let longDifference = abs(long1 - long2)
     let latDifference = abs(lat1 - lat2)
     let a = pow(sin(latDifference/2), 2) + cos(lat1) * cos(lat2) * pow(sin(longDifference/2), 2)
     let c = 2 * atan2(sqrt(a), sqrt(1-a))
     return c * EARTH_RADIUS_METRIC
     }*/
    
    /// Returns the distance from point f to point s using the equirectangular formula (signicantly less acurate than haversine but faster). Units will match planet radius units
    public static func distanceBetweenEquirectangular(f:GPS,s:GPS) -> Double {
        //calculate arc length between two line segment tips
        //arc length = radius times angle in radians
        let longDifference = abs(f.longitude - s.longitude)
        let latDifference = abs(f.latitude - s.latitude)
        let combinedArc = combineArcLengths(arcOne: longDifference, arcTwo: latDifference)
        let arcAsRadians = degreesToRadians(degrees: combinedArc)
        let distance = planetRadius * arcAsRadians
        return distance
    }
    /*
     ///Returns the distance from point f to point s in kilometers using the equirectangular formula (signicantly less acurate than haversine but faster)
     public static func distanceBetweenEquirectangularMetric(f:GPS,s:GPS) -> Double {
     let longDifference = abs(f.longitude - s.longitude)
     let latDifference = abs(f.latitude - s.latitude)
     let combinedArc = combineArcLengths(arcOne: longDifference, arcTwo: latDifference)
     let arcAsRadians = degreesToRadians(degrees: combinedArc)
     let distance = EARTH_RADIUS_METRIC * arcAsRadians
     return distance
     }*/
    
    ///Returns the heading that points towards s from f
    public static func headingBetweenCoordinates(f:GPS,s:GPS) -> Double {
        // Find shortest route
        let latitudeTravel = s.latitude - f.latitude
        
        var longitudeTravel = s.longitude - f.longitude
        if abs(longitudeTravel) > 180 {
            print("There is a faster route")
            //Go around the other way
            let sDistance = 180 - abs(s.longitude)
            let fDistance = 180 - abs(f.longitude)
            
            var totalDistance = sDistance + fDistance
            if longitudeTravel > 0 {
                totalDistance *= -1
            }
            longitudeTravel = totalDistance
        }
        
        //let totalTravelTraditional = sqrt(pow(latitudeTravel, 2) + pow(longitudeTravel, 2))
        /*
         let northPoleLatTravel = (90 - f.latitude) + (90 - s.latitude)
         let southPoleLatTravel = abs(-90 - f.latitude) + abs(-90 - s.latitude)
         let minPolarLatTravel = min(northPoleLatTravel, southPoleLatTravel)
         let tempPolarFLong = f.longitude > 0 ? f.longitude - 180 : f.longitude + 180
         
         var polarlongitudeTravel = s.longitude - tempPolarFLong
         if polarlongitudeTravel > 180 {
         polarlongitudeTravel -= 360
         }
         if polarlongitudeTravel < -180 {
         polarlongitudeTravel += 360
         }
         
         if abs(polarlongitudeTravel) > 180 {
         print("There is a faster route")
         //Go around the other way
         let sDistance = 180 - abs(s.longitude)
         let fDistance = 180 - abs(tempPolarFLong)
         
         var totalDistance = sDistance + fDistance
         if longitudeTravel > 0 {
         totalDistance *= -1
         }
         polarlongitudeTravel = totalDistance
         }
         
         let totalTravelPole = sqrt(pow(minPolarLatTravel, 2) + pow(polarlongitudeTravel, 2))
         
         if totalTravelPole < totalTravelTraditional {
         print("Polar travel is faster!")
         if northPoleLatTravel < southPoleLatTravel {
         //go over the north pole, positive latitude travel
         return radiansToDegrees(radians: atan2(minPolarLatTravel, -polarlongitudeTravel))
         }
         else {
         // hop the south pole, negative latitude travel
         return radiansToDegrees(radians: atan2(minPolarLatTravel * -1, -polarlongitudeTravel))
         }
         }*/
        
        var result = radiansToDegrees(radians: atan2(latitudeTravel, longitudeTravel))
        if result < 0 {
            result += 360
        }
        return result
    }
    
    ///Returns the GPS coordinates on the other side of the world. (If you were to dig a hole perfectly straight this is where you would end up)
    public static func oppositeCoordinate(gps:GPS) -> GPS {
        return GPS(latitude: -gps.latitude,longitude: -gps.longitude)
    }
    
    ///Convert decimal format coordinates to degrees, minutes, seconds
    public static func toDegreesMinuteSecond(coordinate:Double) -> (degrees:Double,minutes:Double,seconds:Double) {
        let degrees = floor(coordinate)
        let minutes = floor((coordinate - degrees) * 60)
        let seconds = (((coordinate - degrees) * 60) - minutes) * 60
        
        return (degrees,minutes,seconds)
    }
    ///Convert degrees minutes and seconds to decimal format
    public static func toDecimal(degrees:Double,minutes:Double,seconds:Double) -> Double {
        return degrees + minutes / 60 + seconds / 3600
    }
    ///The distance to the horizon in miles. Planet radius must be in miles. Doesn't take refraction into account (Height in feet).
    public static func distanceToHorizon(atHeight:Double) -> Double {
        return sqrt(2 * planetRadius * atHeight/5280 + pow(atHeight/5280,2))
    }
    ///Distance to the horizon in kilometers. Planet radius must be in kilometers. Doesn't take refraction into account (Height in meters).
    public static func distanceToHorizonMetric(atHeight:Double) -> Double {
        return sqrt(2 * planetRadius * atHeight/1000 + pow(atHeight/1000,2))
    }
    /// Calculate the time of sunset on a given date (UTC) and at a given GPS. (Zenith specifies the angle of the sun. Official is when it just dips below the horizon). Date is nil when it doesn't set on the specified day.
    public static func sunsetTime(gps:GPS, date:Date, sunZenith:SunZenith) -> Date? {
        return sunriseSunsetHelper(gps: gps, date: date, sunZenith: sunZenith, sunPhase: .sunset)
    }
    /// Calculate the time of Sunrise on a given date (UTC) and at a given GPS. (Zenith specifies the angle of the sun. Official is when it just breaks the horizon). Date is nil when it doesn't rise on the specified day.
    public static func sunriseTime(gps:GPS, date:Date, sunZenith:SunZenith) -> Date? {
        return sunriseSunsetHelper(gps: gps, date: date, sunZenith: sunZenith, sunPhase: .sunrise)
    }
    /// Returns the duration of the day in seconds at a given GPS coordinate on a given day with a given sun zenith
    public static func dayDuration(gps:GPS, date:Date, sunZenith:SunZenith) -> Double {
        let sunrise = GPS.sunriseTime(gps: gps, date: date, sunZenith: sunZenith)
        var sunset = GPS.sunsetTime(gps: gps, date: date, sunZenith: sunZenith)
        
        if sunrise == nil || sunset == nil {
            // Sun doesnt rise or set
            return 0
        }
        
        if sunrise! > sunset! {
            //sunrise is after sunset. Get sunset of the next day
            let nextDay = date.addingTimeInterval(24 * 60 * 60)
            sunset = GPS.sunsetTime(gps: gps, date: nextDay, sunZenith: sunZenith)
        }
        
        return sunset!.timeIntervalSince1970 - sunrise!.timeIntervalSince1970
    }
    
    
    //================
    // MARK: Helper functions
    //================
    private static func combineArcLengths(arcOne:Double, arcTwo:Double) -> Double {
        return sqrt(pow(arcOne, 2) + pow(arcTwo, 2))
    }
    private static func degreesToRadians(degrees:Double) -> Double {
        return degrees * (Double.pi/180)
    }
    private static func radiansToDegrees(radians:Double) -> Double {
        return (180/Double.pi) * radians
    }
    
    /// Helper function for sunrise and sunset #DRY
    private static func sunriseSunsetHelper(gps:GPS, date:Date, sunZenith:SunZenith, sunPhase:SunPhase) -> Date? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Etc/UTC")!
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let n1 = floor(275.0 * Double(month) / 9)
        let n2 = floor((Double(month) + 9.0) / 12.0)
        let n3 = (1 + floor((Double(year) - 4 * floor(Double(year) / 4) + 2) / 3))
        let n = n1 - (n2 * n3) + Double(day) - 30
        let longHour = gps.longitude/15.0
        var t = Double()
        switch sunPhase {
        case .sunrise:
            t = n + ((6 - longHour) / 24.0)
        case .sunset:
            t = n + ((18.0 - longHour) / 24.0)
        }
        let m = (0.9856 * t) - 3.289
        var l = m + (1.916 * mySin(degrees:m)) + (0.020 * mySin(degrees:(2 * m))) + 282.634
        if l >= 360 {
            l -= 360
        } else if l < 0 {
            l += 360
        }
        var ra = myAtan(degrees: 0.91764 * myTan(degrees: l))
        if ra >= 360 {
            ra -= 360
        } else if ra < 0 {
            ra += 360
        }
        let Lquadrant  = (floor(l/90.0)) * 90.0
        let RAquadrant = (floor(ra/90.0)) * 90.0
        ra += (Lquadrant - RAquadrant)
        ra /= 15
        let sinDec = 0.39782 * mySin(degrees: l)
        let cosDec = myCos(degrees: myAsin(degrees:sinDec))
        let cosH = (myCos(degrees: sunZenith.rawValue) - (sinDec * mySin(degrees: gps.latitude))) / (cosDec * myCos(degrees: gps.latitude))
        print("cosH is \(cosH)")
        if cosH > 1 || cosH < -1 {
            return nil
        }
        var h = Double()
        switch sunPhase {
        case SunPhase.sunset:
            h = myAcos(degrees: cosH)
        case .sunrise:
            h = 360 - myAcos(degrees: cosH)
        }
        h /= 15
        let time = h + ra - (0.06571 * t) - 6.622
        var ut = time - longHour
        if ut > 24 {
            ut -= 24
        }
        else if ut < 0 {
            ut += 24
        }
        var dateComponents = DateComponents()
        dateComponents.calendar = calendar
        dateComponents.timeZone = calendar.timeZone
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.hour = Int(floor(ut))
        dateComponents.minute = Int(((ut - floor(ut)) * 60))
        
        let resultDate = calendar.date(from: dateComponents)
        
        return resultDate!
    }
    
    
    //============
    // MARK: Math helpers
    //============
    private static func mySin(degrees: Double) -> Double {
        return __sinpi(degrees/180.0)
    }
    
    private static func myCos(degrees: Double) -> Double {
        return __cospi(degrees/180.0)
    }
    
    private static func myTan(degrees: Double) -> Double {
        return __tanpi(degrees/180.0)
    }
    
    private static func myAtan(degrees: Double) -> Double {
        return Darwin.atan(degrees) * (180.0 / Double.pi)
    }
    
    private static func myAcos(degrees: Double) -> Double {
        return Darwin.acos(degrees) * (180.0 / Double.pi)
    }
    
    private static func myAsin(degrees: Double) -> Double {
        return Darwin.asin(degrees) * (180.0 / Double.pi)
    }
    
    
    // MARK: Enums
    
    /// Enum describing phases of the sun
    private enum SunPhase {
        case sunset
        case sunrise
    }
    
    /// Sun Zenith is used to describe the angle of the sun relative to the surface of earth for calculations involving sun phases.
    public enum SunZenith:Double {
        /// Official zenith for sunrise and sunset. Occurs when the sun goes below or rises above the horizon
        case official = 90.888888
        /// Occurs when the sun dips 6 degrees below the horizon. During civil twilight, the atmosphere reflects enough light to allow outdoor activities.
        case civil = 96
        /// Occurs when the sun dips 12 degrees below the horizon. The horizon is generally still visable, but many of the brighter stars are visible during nautical twilight (between civil and nautical sunset). This enables navigation by stars at sea and is the namesake for it.
        case nautical = 102
        /// Occurs when the sun dips 18 degrees below the horizon. Often hard to differentiate between astronomical twilight and night but astronomers often have difficulty seeing fainter stars during this time. Thus astronomical twilight.
        case astronomical = 108
    }
    
    
}
