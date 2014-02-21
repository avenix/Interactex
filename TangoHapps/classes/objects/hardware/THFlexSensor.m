//
//  THFlexSensor.m
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFlexSensor.h"

@implementation THFlexSensor

#pragma mark - Archiving




#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder{
    
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
}

- (id)copyWithZone:(NSZone *)zone{
    THAccelerometer * copy = [super copyWithZone:zone];
    
    return copy;
}




- (void)load
{
    
    TFProperty * property1 = [TFProperty propertyWithName:@"flexvalue" andType:kDataTypeInteger];
    
    self.properties = [NSMutableArray arrayWithObject:property1];
  
    TFEvent * event1 = [TFEvent eventNamed:kEventValueChanged];
    event1.param1 = [TFPropertyInvocation invocationWithProperty:property1 target:self];

    self.events = [NSMutableArray arrayWithObject:event1];
}

-(void) loadPins{
    
    THElementPin * xPin = [THElementPin pinWithType:kElementPintypeAnalog];
    xPin.hardware = self;
    
    THElementPin * yPin = [THElementPin pinWithType:kElementPintypeAnalog];
    yPin.hardware = self;
    
    THElementPin * zPin = [THElementPin pinWithType:kElementPintypeAnalog];
    zPin.hardware = self;
    
    THElementPin * minusPin = [THElementPin pinWithType:kElementPintypeMinus];
    minusPin.hardware = self;
    
    THElementPin * plusPin = [THElementPin pinWithType:kElementPintypePlus];
    plusPin.hardware = self;
    
    [self.pins addObject:xPin];
    [self.pins addObject:yPin];
    [self.pins addObject:zPin];
    [self.pins addObject:minusPin];
    [self.pins addObject:plusPin];
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder{
    
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone{
    THAccelerometer * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Methods

-(void) setValuesFromBuffer:(uint8_t*) buffer length:(NSInteger) length{
    
    self.accelerometerX = ((int16_t)(buffer[1] << 8 | buffer[0])) >> 4;
    self.accelerometerY = ((int16_t)(buffer[3] << 8 | buffer[2])) >> 4;
    self.accelerometerZ = ((int16_t)(buffer[5] << 8 | buffer[4])) >> 4;
}

-(void) setAccelerometerX:(NSInteger)accelerometerX{
    if(accelerometerX != _accelerometerX){
        _accelerometerX = accelerometerX;
        
        [self triggerEventNamed:kEventXChanged];
    }
}

-(void) setAccelerometerY:(NSInteger)accelerometerY{
    if(accelerometerY != _accelerometerY){
        _accelerometerY = accelerometerY;
        
        [self triggerEventNamed:kEventYChanged];
    }
}

-(void) setAccelerometerZ:(NSInteger)accelerometerZ{
    if(accelerometerZ != _accelerometerZ){
        _accelerometerZ = accelerometerZ;
        
        [self triggerEventNamed:kEventZChanged];
    }
}

-(void) didStartSimulating{
    [self triggerEventNamed:kEventXChanged];
    [self triggerEventNamed:kEventYChanged];
    [self triggerEventNamed:kEventZChanged];
    
    [super didStartSimulating];
}

-(NSString*) description{
    return @"accelerometer";
}




@end
