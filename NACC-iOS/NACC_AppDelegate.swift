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
import QuartzCore
import WatchConnectivity

var s_NACC_cleanDateCalc:NACC_DateCalc = NACC_DateCalc () ///< This holds our global date calculation.

var s_NACC_BaseColor:UIColor? = nil                         ///< This will hold the color that will tint our backgrounds.
var s_NACC_AppDelegate:NACC_AppDelegate? = nil
var s_NACC_GradientLayer:CAGradientLayer? = nil

@UIApplicationMain
/* ###################################################################################################################################### */
/**
 */
class NACC_AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate
{
    // MARK: - Constant Instance Properties
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     These are keys for our prefs.
     */
    let _mainPrefsKey: String   = "NACCMainPrefs"
    let _datePrefsKey: String   = "NACCLastDate"
    let _keysPrefsKey: String   = "NACCShowTags"

    // MARK: - Private Instance Properties
    /* ################################################################################################################################## */
    /* This is the Watch connectivity session. */
    private var _mySession: WCSession! = nil

    // MARK: - Internal Instance Properties
    /* ################################################################################################################################## */
    /** This contains our loaded prefs Dictionary. */
    var loadedPrefs: NSMutableDictionary! = nil
    var window:UIWindow?
    
    // MARK: - Internal Instance Calculated Properties
    /* ################################################################################################################################## */
    var session: WCSession! {
        get {
            if nil == self._mySession {
                self._mySession = WCSession.default
            }
            
            return self._mySession
        }
    }

    var lastEnteredDate: Double {
        /* ################################################################## */
        /**
         This method returns the last entered date, which is persistent.
         
         The date is a POSIX epoch date (integer).
         */
        get {
            let today = Date()
            
            var ret: Double = today.timeIntervalSince1970
            
            if self._loadPrefs()
            {
                if let temp = self.loadedPrefs.object(forKey: _datePrefsKey) as? Double
                {
                    ret = temp
                }
            }
            
            return ret
        }
        
        /* ################################################################## */
        /**
         This method saves the last entered date, which is persistent.
         
         The date is a POSIX epoch date (integer).
         */
        set {
            if self._loadPrefs()
            {
                self.loadedPrefs.setObject(newValue, forKey: _datePrefsKey as NSCopying)
                self._savePrefs()
            }
        }
    }
    
    var showKeys: Bool {
        /* ################################################################## */
        /**
         This method returns whether or not to show the keytags, which is persistent.
         
         The date is a POSIX epoch date (integer).
         */
        get {
            var ret: Bool = true
            
            if self._loadPrefs()
            {
                if let temp = self.loadedPrefs.object(forKey: _keysPrefsKey) as? Bool
                {
                    ret = temp
                }
            }
            
            return ret
        }
        
        /* ################################################################## */
        /**
         This method saves the state of the show keys switch, which is persistent.
         
         The date is a POSIX epoch date (integer).
         */
        set {
            if self._loadPrefs()
            {
                self.loadedPrefs.setObject(newValue, forKey: _keysPrefsKey as NSCopying)
                self._savePrefs()
            }
        }
    }
    
    // MARK: - Internal Instance Methods
    /* ################################################################################################################################## */
    func activateSession() {
        if WCSession.isSupported() && (self.session.activationState != .activated) {
            self._mySession.delegate = self
            self.session.activate()
        }
    }

    // MARK: - UIApplicationDelegate Protocol Methods
    /* ################################################################################################################################## */
    /*******************************************************************************************/
    /**
        \brief  Simply set the SINGLETON to us.
    */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        s_NACC_AppDelegate = self
        self.activateSession()
        return true
    }
    
    /*******************************************************************************************/
    /**
        \brief  We make sure that the first window is always the date selector.
    */
    func applicationWillEnterForeground( _ application: UIApplication )
    {
        let mainNavController: UINavigationController = s_NACC_AppDelegate!.window!.rootViewController as! UINavigationController
        
        if ( NSObject.isKind ( of: NACC_MainViewController.self ) )
        {
            mainNavController.popToRootViewController ( animated: true )
        }
    }
    
    /*******************************************************************************************/
    /**
        \brief  Create the gradient for the back of the window.
    */
    class func setGradient()
    {
        if ( (s_NACC_AppDelegate != nil) && (s_NACC_AppDelegate!.window != nil) )
        {
            let mainNavController: UINavigationController = s_NACC_AppDelegate!.window!.rootViewController as! UINavigationController
            
            var gradientEndColor:UIColor? = nil
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            let startPoint:CGPoint = CGPoint ( x: 0.5, y: 0 )
            let endPoint:CGPoint = CGPoint ( x: 0.5, y: 1 )
            
            // We have the gradient get lighter. The source is the background color we set for our navigation bar.
            if ( (mainNavController.navigationBar.backgroundColor != nil) && mainNavController.navigationBar.backgroundColor!.getRed ( &r, green: &g, blue: &b, alpha: &a ) )
            {
                r = r + 0.4
                g = g + 0.4
                b = b + 0.4
                
                gradientEndColor = UIColor ( red:r, green:g, blue:b, alpha:1.0 )
            }
            
            s_NACC_BaseColor = gradientEndColor
            mainNavController.navigationBar.barTintColor = s_NACC_BaseColor
            
            if ( s_NACC_GradientLayer != nil )
            {
                s_NACC_GradientLayer!.removeFromSuperlayer()
            }
            
            s_NACC_GradientLayer = CAGradientLayer()
            
            if ( (s_NACC_GradientLayer != nil) && (gradientEndColor != nil) )
            {
                s_NACC_GradientLayer!.endPoint = endPoint
                s_NACC_GradientLayer!.startPoint = startPoint
                let clearColor = UIColor ( red: 0, green: 0, blue: 0, alpha: 0 )
                
                let endColor:CGColor = gradientEndColor!.cgColor
                let startColor:CGColor = mainNavController.navigationBar.backgroundColor != nil ? mainNavController.navigationBar.backgroundColor!.cgColor : clearColor.cgColor
                
                s_NACC_GradientLayer!.colors = [endColor, startColor]
                s_NACC_GradientLayer!.locations = [ NSNumber (value: 0.0 as Float),
                                                    NSNumber (value: 1.0 as Float)
                                                   ]
                s_NACC_GradientLayer!.frame = s_NACC_AppDelegate!.window!.bounds
                s_NACC_AppDelegate!.window!.layer.insertSublayer ( s_NACC_GradientLayer!, at: 0 )
            }
        }
    }
    
    /*******************************************************************************************/
    /**
     \brief  Saves the persistent prefs.
     */
    func _savePrefs()
    {
        UserDefaults.standard.set(self.loadedPrefs, forKey: self._mainPrefsKey)
    }
    
    /*******************************************************************************************/
    /**
     \brief  Loads the persistent prefs.
     */
    func _loadPrefs() -> Bool
    {
        let temp = UserDefaults.standard.object(forKey: self._mainPrefsKey) as? NSDictionary
        
        if nil == temp {
            self.loadedPrefs = NSMutableDictionary()
        } else {
            self.loadedPrefs = NSMutableDictionary(dictionary: temp!)
        }
        
        return nil != self.loadedPrefs
    }
    
    // MARK: - WCSession Sender Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func sendCurrentProfileToWatch() {
        let appContext:[String:Any] = [
                                        s_appContext_StartDate:s_NACC_cleanDateCalc.startDate!,
                                        s_appContext_EndDate:s_NACC_cleanDateCalc.endDate!
        ]
        
        do {
            try self.session.updateApplicationContext(appContext)
        } catch {
            print("Communication Error With Watch!")
        }
    }
    
    // MARK: - WCSessionDelegate Protocol Methods
    /* ################################################################################################################################## */
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if .activated == activationState {
            #if DEBUG
                print("Watch session is active.")
            #endif
            self.sendCurrentProfileToWatch()
        }
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidBecomeInactive(_ session: WCSession) {
        #if DEBUG
            print("Watch session is inactive.")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func sessionDidDeactivate(_ session: WCSession) {
        #if DEBUG
            print("Watch session deactivated.")
        #endif
    }
    
    /* ################################################################## */
    /**
     */
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            #if DEBUG
                print("Phone Received Message: " + String(describing: message))
            #endif
        }
    }
}

