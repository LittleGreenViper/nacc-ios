//
//  AppDelegate.swift
//  NACC-iOS
//
//  Created by Chris Marshall on 6/28/14.
//  Copyright (c) 2014 MAGSHARE. All rights reserved.
//

import UIKit
import QuartzCore

var s_NACC_cleanDateCalc:NACC_DateCalc = NACC_DateCalc ()   ///< This holds our global date calculation.
var s_NACC_BaseColor:UIColor? = nil                         ///< This will hold the color that will tint our backgrounds.
var s_NACC_AppDelegate:NACC_AppDelegate? = nil
var s_NACC_GradientLayer:CAGradientLayer? = nil

@UIApplicationMain class NACC_AppDelegate: UIResponder, UIApplicationDelegate
{
    var window:UIWindow?
    
    /*******************************************************************************************/
    /**
        \brief  Simply set the SINGLETON to us.
    */
    func application ( application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary! ) -> Bool
    {
        s_NACC_AppDelegate = self
        return true
    }
    
    /*******************************************************************************************/
    /**
        \brief  We make sure that the first window is always the date selector.
    */
    func applicationWillEnterForeground( application: UIApplication! )
    {
        let mainNavController: UINavigationController = s_NACC_AppDelegate!.window!.rootViewController as UINavigationController
        
        if ( mainNavController.topViewController.isKindOfClass ( NACC_MainViewController.self ) )
        {
            mainNavController.popToRootViewControllerAnimated ( true )
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
            let mainNavController: UINavigationController = s_NACC_AppDelegate!.window!.rootViewController as UINavigationController
            
            var gradientEndColor:UIColor? = nil
            var r:CGFloat = 0
            var g:CGFloat = 0
            var b:CGFloat = 0
            var a:CGFloat = 0
            var startPoint:CGPoint = CGPointMake ( 0.5, 0 )
            var endPoint:CGPoint = CGPointMake ( 0.5, 1 )
            
            // We have the gradient get lighter. The source is the background color we set for our navigation bar.
            if ( mainNavController.navigationBar.backgroundColor.getRed ( &r, green: &g, blue: &b, alpha: &a ) )
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
                s_NACC_GradientLayer!.colors = [    gradientEndColor!.CGColor,
                                                    mainNavController.navigationBar.backgroundColor.CGColor
                                                ]
                s_NACC_GradientLayer!.locations = [ NSNumber ( float: 0.0 ),
                                                    NSNumber ( float: 1.0 )
                                                   ]
                s_NACC_GradientLayer!.frame = s_NACC_AppDelegate!.window!.bounds
                s_NACC_AppDelegate!.window!.layer.insertSublayer ( s_NACC_GradientLayer, atIndex: 0 )
            }
        }
    }
}

