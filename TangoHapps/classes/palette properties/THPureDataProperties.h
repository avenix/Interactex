//
//  THPureDataProperties.h
//  TangoHapps
//
//  Created by Juan Haladjian on 4/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THEditableObjectProperties.h"

@interface THPureDataProperties : THEditableObjectProperties

@property (weak, nonatomic) IBOutlet UILabel *var1Label;
@property (weak, nonatomic) IBOutlet UISlider *var1Slider;

@property (weak, nonatomic) IBOutlet UILabel *var2Label;
@property (weak, nonatomic) IBOutlet UISlider *var2Slider;

- (IBAction)var1Changed:(id)sender;
- (IBAction)var2Changed:(id)sender;

@end
