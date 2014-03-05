//
//  THFlexSensorEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFlexSensorEditable.h"
#import "THFlexSensor.h"

@interface THFlexSensor ()
@property (nonatomic, assign, readwrite) NSUInteger flexValue;
@end

@interface THFlexSensorEditable ()
@property (nonatomic, assign, readwrite) NSInteger flexValue;
@property (nonatomic, assign, readwrite) BOOL pressed;
@end

@implementation THFlexSensorEditable

- (void)loadFlexsensor
{
    self.sprite = [CCSprite spriteWithFile:@"flexsensor.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
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

#pragma mark - Property Controller

- (NSArray *)propertyControllers
{
    NSArray *controllers = [super propertyControllers];
    //add property-controllers here
    return controllers;
}


#pragma mark -

- (void)update
{
    if(self.pressed)
    {
        self.flexValue -= 1;
    }
    else
    {
        self.flexValue += 1;
    }
    
    THFlexSensor *realSensor = (THFlexSensor *)self.simulableObject;
    self.flexValue = [THClientHelper Constrain:self.flexValue min:130 max:270];
    realSensor.flexValue = self.flexValue;
}

- (void)updateToPinValue
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}


-  (void)willStartSimulation
{
    [super willStartSimulation];

    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (void)willStartEdition
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}


- (NSString*)description
{
    return @"Flex Sensor";
}

#pragma mark - touch events

- (void)handleTouchBegan
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.pressed = YES;
}


- (void)handleTouchEnded
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    self.pressed = NO;
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


@end
