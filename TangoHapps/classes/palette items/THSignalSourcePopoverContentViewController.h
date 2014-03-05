//
//  THSignalSourcePopoverContentViewController.h
//  TangoHapps
//
//  Created by Michael Conrads on 05/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THSignalSourceEditable.h"


@interface THSignalSourcePopoverContentViewController : UIViewController
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         signalSourceEditable:(THSignalSourceEditable *)signalSourceEditable;
@end
