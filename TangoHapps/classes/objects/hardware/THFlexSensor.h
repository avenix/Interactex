//
//  THFlexSensor.h
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THHardwareComponent.h"

@interface THFlexSensor : THHardwareComponent
@property (nonatomic, assign, readwrite) NSUInteger flexlevel;
@end
