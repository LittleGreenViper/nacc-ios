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
    along with this code.  If not, see <http://www.gnu.org/licenses/>.
*/

import UIKit

/***********************************************************************************************/
/**
    \class  Int (extension)

    \brief  This simply adds the ability to display an integer using a printf format.
*/
/***********************************************************************************************/
extension Int
{
    func format ( f: String ) -> String
    {
        return NSString ( format: "%\(f)d", self )
    }
}

/***********************************************************************************************/
/**
    \class  NACC_TagModel

    \brief  This class wil determine which NA tags are the proper ones for the cleantime, and will
            instantiate and maintain the image assets for them (including constructing the tags).
*/
/***********************************************************************************************/
class NACC_TagModel
{
    /**
        \struct NACC_TagModel_TagData
    
        \brief This will be assigned to describe available tags.
    */
    struct NACC_TagModel_TagData
    {
        let baseImageName:String    ///< The name of the image we will use as the tag base (if the tag applies).
        let faceImageName:String    ///< The name of the face (text) image.
        /// These are the coefficients we apply, to see if the tag applies.
        let totalDays:Int           ///< If this tag is assigned for a certain number of total days, that is indicated here. If it is specified, the rest of these fields are ignored.
        /// The rest of these are for specific durations, measured in months, days, and years. If totalDays is specified, these are ignored.
        /// If totalDays is not specified, then all 3 of these are considered at once.
        let days:Int                ///< Days past a month.
        let months:Int              ///< Months past a year.
        let years:Int               ///< Years.
    }
    
    let calculation: NACC_DateCalc                  ///< This is the calculation object that will govern which tags will be displayed.
    
    /*******************************************************************************************/
    /**
        \brief  Yuck. This is a big, fat, hairy mess of cyclomatic complexity. However, there doesn't
                really seem to be a better way of getting the display of natural text.
                This function generates a text response that announces the cleantime, in a casual,
                natural set of sentences.
        
        \param inCalculation the date calculation that we will display as text.
        
        \returns a string, containing the cleandate text.
    */
    class func getDisplayCleandate ( inTotalDays:Int, inYears:Int, inMonths:Int, inDays:Int ) -> String
    {
        var resultsString:String = ""
        let bundle:NSBundle = NSBundle ( forClass: NACC_TagModel.self )
        
        // This is the first line, where we count days.
        if ( inTotalDays == 1 )  // Brand new
        {
            resultsString = NSLocalizedString ( "RESULTS-DAY", tableName: nil, bundle: bundle, value: "RESULTS-DAY", comment: "" )
        }
        else if ( inTotalDays < 0 )
        {
            resultsString = String ( format: NSLocalizedString ( "RESULTS-SUPPORT", tableName: nil, bundle: bundle, value: "RESULTS-DAYS", comment: "" ) )
        }
        else
        {
            resultsString = String ( format: NSLocalizedString ( "RESULTS-DAYS", tableName: nil, bundle: bundle, value: "RESULTS-DAYS", comment: "" ), inTotalDays )
        }
        
        // The next line is more involved, as it breaks into years, months and days.
        if ( inTotalDays > 90 )
        {
            if ( (inYears > 1) && (inMonths > 1) && (inDays > 1) )    // Multiple of years, months and days.
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-1", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-1", comment: "" ), inYears, inMonths, inDays )
            }
            else if ( (inYears > 1) && (inMonths > 1) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-2", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-2", comment: "" ), inYears, inMonths )
            }
            else if ( (inYears > 1) && (inMonths == 1) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-3", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-3", comment: "" ), inYears )
            }
            else if ( (inYears == 1) && (inMonths == 1) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-4", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-4", comment: "" ) )
            }
            else if ( (inYears == 1) && (inMonths > 1) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-5", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-5", comment: "" ), inMonths )
            }
            else if ( (inYears == 1) && (inMonths == 1) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-6", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-6", comment: "" ) )
            }
            if ( (inYears == 1) && (inMonths == 0) && (inDays > 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-7", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-7", comment: "" ), inDays )
            }
            else if ( (inYears == 1) && (inMonths == 0) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-8", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-8", comment: "" ) )
            }
           else if ( (inYears > 1) && (inMonths > 1) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-9", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-9", comment: "" ), inYears, inMonths )
            }
            else if ( (inYears == 0) && (inMonths > 1) && (inDays > 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-10", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-10", comment: "" ), inMonths, inDays )
            }
            else if ( (inYears == 0) && (inMonths > 1) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-11", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-11", comment: "" ), inMonths )
            }
            else if ( (inYears == 0) && (inMonths > 1) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-12", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-12", comment: "" ), inMonths )
            }
            else if ( (inYears > 1) && (inMonths == 0) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-13", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-13", comment: "" ), inYears )
            }
            else if ( (inYears > 1) && (inMonths == 1) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-14", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-14", comment: "" ), inYears )
            }
            else if ( (inYears == 1) && (inMonths > 1) && (inDays > 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-15", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-15", comment: "" ), inMonths, inDays )
            }
            else if ( (inYears == 1) && (inMonths > 1) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-16", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-16", comment: "" ), inMonths )
            }
            else if ( (inYears == 0) && (inMonths == 1) && (inDays > 1) )  // Should never happen.
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-17", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-17", comment: "" ), inDays )
            }
            else if ( (inYears == 0) && (inMonths == 1) && (inDays == 1) )  // Should never happen.
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-18", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-18", comment: "" ) )
            }
            else if ( (inYears > 1) && (inMonths == 0) && (inDays > 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-19", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-19", comment: "" ), inYears, inDays )
            }
            else if ( (inYears > 1) && (inMonths == 0) && (inDays == 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-20", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-20", comment: "" ), inYears )
            }
            else if ( (inYears == 1) && (inMonths == 0) && (inDays == 0) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-21", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-21", comment: "" ) )
            }
            else if ( (inYears > 1) && (inMonths == 1) && (inDays > 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-22", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-22", comment: "" ), inYears, inDays )
            }
            else if ( (inYears == 1) && (inMonths == 1) && (inDays > 1) )
            {
                resultsString = resultsString + String ( format: NSLocalizedString ( "RESULTS-COMPLEX-23", tableName: nil, bundle: bundle, value: "RESULTS-COMPLEX-23", comment: "" ), inDays )
            }
        }
        
        return resultsString
    }
    
    /*******************************************************************************************/
    /**
        \brief  A class function that will use our current localization to determine the correct tag name.
        
        \param  inIndex The index of the tag we are looking up.
        
        \returns a tuple, containing both the base (tag) file name, and the face (text) file name.
    */
    class func determineImageNames ( inIndex:NSNumber ) -> (baseName:String,  ///< The tag base file name
                                                            faceName:String   ///< The tag face file name.
                                                            )
    {
        let currentLocale:NSLocale? = NSLocale.currentLocale()
        let localeIDTemp:NSString = currentLocale!.localeIdentifier
        let localeID = localeIDTemp.substringToIndex(2)
        
        let returnedBaseName = "tag_" + Int ( inIndex.integerValue ).format ( "02" )
        var returnedFaceName = "face_" + Int ( inIndex.integerValue ).format ( "02" ) + "_" + localeID!
        
        let testImage:UIImage? = UIImage ( named:returnedFaceName ) // Test to see if we can get the image for the face.
        
        if ( testImage == nil ) // Default to English if no image for this language.
        {
            returnedFaceName = "face_" + Int ( inIndex.integerValue ).format ( "02" ) + "_en"
        }

        return ( baseName: returnedBaseName, faceName: returnedFaceName )
    }
    
    /*******************************************************************************************/
    /**
        \brief      This loads our available strings
        
        \returns    an array of prepared NACC_TagModel_TagData objects.
    */
    class func setUpAvailableImages() -> [NACC_TagModel_TagData]
    {
        // This current implementation is real clunky. I'll revisit it when I improve my Swift-Fu.
        var ret:[NACC_TagModel_TagData] = []
        
        var index = 1
        
        var names:(baseName:String, faceName:String) = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData1 = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 1, days: 0, months: 0, years: 0 );
        
        ret.append ( tagData1 )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData30 = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 30, days: 0, months: 0, years: 0 )
        
        ret.append ( tagData30 )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData60 = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 60, days: 0, months: 0, years: 0 )
        
        ret.append ( tagData60 )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData90 = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 90, days: 0, months: 0, years: 0 )
        
        ret.append ( tagData90 )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData6Mo = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 6, years: 0 )
        
        ret.append ( tagData6Mo )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData9Mo = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 9, years: 0 )
        
        ret.append ( tagData9Mo )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData1Yr = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 0, years: 1 )
        
        ret.append ( tagData1Yr )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData18Mo = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 6, years: 1 )
        
        ret.append ( tagData18Mo )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData2Yr = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 0, years: 2 )
        
        ret.append ( tagData2Yr )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData10Yr = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 0, years: 10 )
        
        ret.append ( tagData10Yr )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData20Yr = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 0, years: 20 )
        
        ret.append ( tagData20Yr )
        
        names = NACC_TagModel.determineImageNames ( index++ )
        
        let tagData25Yr = NACC_TagModel_TagData ( baseImageName: names.baseName, faceImageName: names.faceName, totalDays: 0, days: 0, months: 0, years: 25 )
        
        ret.append ( tagData25Yr )
        
        return ret
    }
    
    /*******************************************************************************************/
    /**
        \brief  This composes a tag image, based on the three image resource names provided.
        
        \param inBaseName The name of the tag base image.
        \param inFaceName The name of the text to overlay on the tag.
        \param inRingClosed if true, the closed ring image will be used. If not, the open one will be used. Default is false.
        
        \returns an instance of UIImage. May be nil, if the operation fails.
    */
    class func constructTag ( inBaseName:String, inFaceName:String, inRingClosed:Bool = false ) -> UIImage?
    {
        let baseImage:UIImage = UIImage ( named:inBaseName )
        let faceImage:UIImage = UIImage ( named:inFaceName )
        let ringImage:UIImage = UIImage ( named:(inRingClosed ? "ring_02" : "ring_01") ) // Select the correct ring image.
        
        var ret:UIImage? = nil  // Start off pessimistic
        
        if ( (baseImage != nil) && (faceImage != nil) && (ringImage != nil) )   // Make sure we got everything.
        {
            let aspect:CGFloat = 580.0 / 320.0
            let width:CGFloat = baseImage.size.width
            let height:CGFloat = width * aspect
            
            let size:CGSize = CGSizeMake ( width, height )
            
            UIGraphicsBeginImageContextWithOptions ( size, false, 0 )    // Set up an offscreen bitmap context.
            
            // Draw the transparent images over each other.
            baseImage.drawAtPoint ( CGPointMake ( 0.0, height - baseImage.size.height ) )
            faceImage.drawAtPoint ( CGPointMake ( 0.0, height - faceImage.size.height ) )
            
            let ringleft:CGFloat = (size.width - ringImage.size.width) / 2.0
            
            ringImage.drawAtPoint ( CGPointMake ( ringleft, 0.0 ) )
            
            ret = UIGraphicsGetImageFromCurrentImageContext()   // Get the resulting composite image as a single image.
            UIGraphicsEndImageContext()
        }
        
        return ret
    }
    
    /*******************************************************************************************/
    /**
        \brief  Checks a given tag data template against the given calculation to see if the tag applies.
        
        \param  inCalculation This is the NACC_DateCalc instance that has calculated the cleantime.
        \param  inTagTemplate This is the tag template we are checking.
        
        \returns true if the tag applies to this calculation.
    */
    class func doesThisTagApply ( inCalculation:NACC_DateCalc, inTagTemplate:NACC_TagModel_TagData ) -> Bool
    {
        var ret:Bool = false
        
        // If this is a days counter, then we simply see if the calculation is higher. Simple.
        if ( (inTagTemplate.totalDays > 0) && (inCalculation.totalDays >= inTagTemplate.totalDays) )
        {
            ret = true
        }
        else // Otherwise, we need to compare years, months and days. Bit more involved.
        {
            // This is a quick and dirty way to compare.
            let tagScore:NSNumber = (inTagTemplate.years * 10000) + (inTagTemplate.months * 100) + inTagTemplate.days;
            let caclcScore:NSNumber = (inCalculation.years * 10000) + (inCalculation.months * 100) + inCalculation.days;
            
            ret = caclcScore.longLongValue >= tagScore.longLongValue
        }
        
        return ret
    }
    
    /*******************************************************************************************/
    /**
        \brief  The designated initializer.
        
        \param  inCalculation This is the NACC_DateCalc instance that has calculated the cleantime.
    */
    init ( inCalculation: NACC_DateCalc )
    {
        self.calculation = inCalculation
    }
    
    /*******************************************************************************************/
    /**
        \brief  Convenience parameter-less init
    */
    convenience init ( )
    {
        self.init ( inCalculation: NACC_DateCalc() )
    }
    
    /*******************************************************************************************/
    /**
        \brief  This builds up an array of UIImages to be used to display the tags.
        
        \returns an array of UIImage.
    */
    func getTags() -> [UIImage]?
    {
        var tagImages: [UIImage] = []                   // This is an array that will hold each of the aggregated image objects, in the order of display.
        
        if ( self.calculation.totalDays > 0 )
        {
            let tagDataArray = NACC_TagModel.setUpAvailableImages() // Get our pool.
            
            var isFirst:Bool = true
            
            var index = 0
            
            for i in 0..<9
            {
                index = i
                
                let tagTemplate = tagDataArray[index]
                if ( NACC_TagModel.doesThisTagApply ( self.calculation, inTagTemplate: tagTemplate ) )
                {
                    tagImages.append ( NACC_TagModel.constructTag ( tagTemplate.baseImageName, inFaceName: tagTemplate.faceImageName, inRingClosed: isFirst )! )
                    isFirst = false // Only the first one is closed.
                }
            }
            
            var years:Int = self.calculation.years
                        
            if ( years > 2 )
            {
                var year = 3
                
                while ( years-- > 2 )
                {
                    if ( year == 10 )
                    {
                        let tenYearTag = tagDataArray[index + 1]
                        tagImages.append ( NACC_TagModel.constructTag ( tenYearTag.baseImageName, inFaceName: tenYearTag.faceImageName, inRingClosed: false )! )
                    }
                    else if ( year == 25 )
                    {
                        let twentyFiveYearTag = tagDataArray[index + 3]
                        tagImages.append ( NACC_TagModel.constructTag ( twentyFiveYearTag.baseImageName, inFaceName: twentyFiveYearTag.faceImageName, inRingClosed: false )! )
                    }
                    else if ( (year % 10) == 0 )
                    {
                        let twentyYearTag = tagDataArray[index + 2]
                        tagImages.append ( NACC_TagModel.constructTag ( twentyYearTag.baseImageName, inFaceName: twentyYearTag.faceImageName, inRingClosed: false )! )
                    }
                    else
                    {
                        let twoYearTag = tagDataArray[index]
                        tagImages.append ( NACC_TagModel.constructTag ( twoYearTag.baseImageName, inFaceName: twoYearTag.faceImageName, inRingClosed: false )! )
                    }
                
                    year++
                }
            }
        }
        
        return tagImages
    }
}