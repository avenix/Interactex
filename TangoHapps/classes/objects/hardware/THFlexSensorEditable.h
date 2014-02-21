//
//  THFlexSensorEditable.h
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THHardwareComponentEditableObject.h"

@interface THFlexSensorEditable : THHardwareComponentEditableObject

@property (nonatomic, assign, readonly) NSInteger flexValue;

//@property (nonatomic, readonly) THElementPinEditable * pin5Pin;
//@property (nonatomic, readonly) THElementPinEditable * pin4Pin;
@end
