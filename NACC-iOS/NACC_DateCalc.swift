/*
    This is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    NACC is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this code.  If not, see <http: //www.gnu.org/licenses/>.
*/

import Foundation

/***********************************************************************************************/
/**
    \class  NACC_DateCalc
    \brief  This is the fundamental core of the cleantme calculator.

            It works by taking an input date (1-day resolution), and a "today" date (which can be
            omitted), and calculates the time interval between them. It uses the appropriate
            calendar (if Iranian, it uses the Persian Solar Calendar).
            All the action happens in the designated initializer. Once the class is instantiated,
            its work is done.
*/
/***********************************************************************************************/
class NACC_DateCalc {
    /// The following will read like: 
    /// "There have been <totalDays> between the dates. This is a period of <years> years, <months> months and <days> days."
    let totalDays: Int      ///< The total number of days.
    var years: Int = 0      ///< The number of years since the clean date.
    var months: Int = 0     ///< The number of months since the last year in the clean date.
    var days: Int = 0       ///< The number of days since the last month in the clean date.
    let dateString: String  ///< This will contain a readable string of the date.
    let startDate: Date?  ///< The starting date of the period (the cleandate).
    let endDate: Date?    ///< The ending date of the period (today, usually).
    
    /*******************************************************************************************/
    /**
        \brief  This is the designated initializer. It takes two dates, and calculates between them.
    
        \param inStartDate This is the "from" date. It is the start of the calculation.
        \param inNowDate This is the end date. The calculation goes between these two dates.
    */
    init(inStartDate: Date, inNowDate: Date) {
        // The reason for all this wackiness, is we want to completely strip out the time element of each date. We want the days to be specified at noon.
        let fromString: String = DateFormatter.localizedString(from: inStartDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
        let toString: String = DateFormatter.localizedString(from: inNowDate, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .short
        
        // We have stripped out the time information, and each day is at noon.
        self.startDate = dateFormatter.date(from: fromString)?.addingTimeInterval(43200)  // Make it Noon, Numbah One.
        self.endDate = dateFormatter.date(from: toString)?.addingTimeInterval(43200)
        
        self.dateString = DateFormatter.localizedString(from: startDate!, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.none)
        
        // We get the total days, just to check for 90 or less.
        self.totalDays = Int(trunc(inNowDate.timeIntervalSince(inStartDate) / 86400.0 )) // Change seconds into days.
        
        if (self.startDate != nil && self.endDate != nil) && (self.startDate! < self.endDate!) {
            let myCalendar: Calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
            // Create our answer from the components of the result.
            let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day]
            let myComponents = (myCalendar as NSCalendar).components(unitFlags, from: startDate!, to: endDate!, options: NSCalendar.Options.wrapComponents)
            
            if let years = myComponents.year {
                if let months = myComponents.month {
                    if let days = myComponents.day {
                        self.years = years
                        self.months = months
                        self.days = days
                    }
                }
            }
        }
    }
    
    /*******************************************************************************************/
    /**
        \brief  Convenience parameter-less init
    */
    convenience init() {
        self.init(inStartDate: Date())
    }
    
    /*******************************************************************************************/
    /**
        \brief  This is a convenience initializer that calculates between a given date, and now.
    
        \param inStartDate This is the "from" date. It is the start of the calculation.
    */
    convenience init(inStartDate: Date) {
        self.init(inStartDate: inStartDate, inNowDate: Date())
    }
    
    /*******************************************************************************************/
    /**
        \brief  This is a convenience initializer that calculates between a given date (expressed in components), and now.

        \param inCleanYear The year (fully-qualified)
        \param inCleanMonth The month (1 is January)
        \param inCleanDay The day of the month
    */
    convenience init(inCleanYear: Int, inCleanMonth: Int, inCleanDay: Int) {
        var components = DateComponents()
        components.year = inCleanYear
        components.month = inCleanMonth
        components.day = inCleanDay
        components.hour = 0
        components.minute = 0
        components.second = 0
        let cleanDate: Date? = Calendar.current.date(from: components)
        
        self.init(inStartDate: cleanDate!)
    }
}
