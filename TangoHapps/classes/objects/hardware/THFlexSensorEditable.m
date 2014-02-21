//
//  THFlexSensorEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFlexSensorEditable.h"
#import "THFlexSensor.h"
@implementation THFlexSensorEditable

- (void)loadFlexsensor
{
    self.sprite = [CCSprite spriteWithFile:@"flexsensor.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
    self.isAccelerometerEnabled = YES;
}

-(id) init{
    self = [super init];
    if(self){
        self.simulableObject = [[THFlexSensor alloc] init];
        
        self.type = kHardwareTypeFlexSensor;
        
        [self loadFlexsensor];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    [self loadFlexsensor];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone
{
    THFlexSensorEditable * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Property Controller

#pragma mark - Methods
/*
 -(void) handleAccelerated:(UIAcceleration*) acceleration{
 
 //NSLog(@"accel: %f %f",acceleration.y,-acceleration.x);
 
 self.accelerometerX = acceleration.y * 300;
 self.accelerometerY = -acceleration.x * 300;
 //NSLog(@"accel: %d %d",self.x,self.y);
 }*/


//
//-(THElementPinEditable*) pin5Pin{
//    return [self.pins objectAtIndex:0];
//}
//
//-(THElementPinEditable*) pin4Pin{
//    return [self.pins objectAtIndex:1];
//}

/*
 -(void) updatePinValue{
 THElementPinEditable * analogPin = self.pin5Pin;
 THBoardPinEditable * boardPin = analogPin.attachedToPin;
 THCompass * compass = (THCompass*) self.object;
 boardPin.currentValue = compass.light;
 }*/

- (void)update
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

}

- (void)handleDoubleTapped
{
     NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)updateToPinValue
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

/*
-(NSInteger) accelerometerX{
    THAccelerometer * accelerometer = (THAccelerometer*) self.simulableObject;
    return accelerometer.accelerometerX;
}

-(void) setAccelerometerX:(NSInteger)accelerometerX{
    
    THAccelerometer * accelerometer = (THAccelerometer*) self.simulableObject;
    accelerometer.accelerometerX = accelerometerX;
}

-(NSInteger) accelerometerY{
    THAccelerometer * accelerometer = (THAccelerometer*) self.simulableObject;
    return accelerometer.accelerometerY;
}

-(void) setAccelerometerY:(NSInteger)accelerometerY{
    
    THAccelerometer * accelerometer = (THAccelerometer*) self.simulableObject;
    accelerometer.accelerometerY = accelerometerY;
}

-(NSInteger) accelerometerZ{
    THAccelerometer * accelerometer = (THAccelerometer*) self.simulableObject;
    return accelerometer.accelerometerZ;
}

-(void) setAccelerometerZ:(NSInteger)accelerometerZ{
    
    THAccelerometer * accelerometer = (THAccelerometer*) self.simulableObject;
    accelerometer.accelerometerZ = accelerometerZ;
}
*/


- (void)willStartSimulation
{
    [super willStartSimulation];

    NSLog(@"%s",__PRETTY_FUNCTION__);
}

-(void) willStartEdition
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

-(NSString*) description
{
    return @"Flex Sensor";
}


@end
