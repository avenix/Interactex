//
//  THPureDataProperties.m
//  TangoHapps
//
//  Created by Juan Haladjian on 4/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "THPureDataProperties.h"
#import "THPureDataEditable.h"

@implementation THPureDataProperties

-(NSString*) title{
    return @"PureData";
}

-(void) updateVarLabels{
    
    THPureDataEditable * pureData = (THPureDataEditable*) self.editableObject;
    self.var1Label.text = [NSString stringWithFormat: @"%d", pureData.variable1];
    self.var2Label.text = [NSString stringWithFormat: @"%d", pureData.variable2];
}

-(void) reloadState{
    
    [self updateVarLabels];
}
 
- (IBAction)var1Changed:(id)sender {
    
    THPureDataEditable * pureData = (THPureDataEditable*) self.editableObject;
    pureData.variable1 = self.var1Slider.value;
    
    [self updateVarLabels];
}

- (IBAction)var2Changed:(id)sender {
    
    THPureDataEditable * pureData = (THPureDataEditable*) self.editableObject;
    pureData.variable2 = self.var2Slider.value;
    
    [self updateVarLabels];
}

- (void)viewDidUnload {
    
    [self setVar1Label:nil];
    [self setVar1Slider:nil];
    
    [self setVar2Label:nil];
    [self setVar2Slider:nil];
    
    [super viewDidUnload];
}

@end
