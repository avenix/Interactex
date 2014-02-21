//
//  THFlexSensorPaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFlexSensorPaletteItem.h"
#import "THFlexSensorEditable.h"
@implementation THFlexSensorPaletteItem

- (void)dropAt:(CGPoint)location
{
    THFlexSensorEditable *editableFlexSensor = [[THFlexSensorEditable alloc] init];
    editableFlexSensor.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addHardwareComponent:editableFlexSensor];
}

@end
