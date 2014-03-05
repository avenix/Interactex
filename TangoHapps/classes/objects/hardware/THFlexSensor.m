//
//  THFlexSensor.m
//  TangoHapps
//
//  Created by Michael Conrads on 20/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THFlexSensor.h"
#import "THElementPin.h"

@interface THFlexSensor ()
@property (nonatomic, assign, readwrite) NSUInteger flexValue;
@end

@implementation THFlexSensor

- (id)init
{
    self = [super init];
    if (self) {
        [self load];
        [self loadPins];
    }
    return self;
}


- (void)load
{
    TFProperty * property1 = [TFProperty propertyWithName:@"flexValue"
                                                  andType:kDataTypeInteger];
    
    self.properties = [NSMutableArray arrayWithObject:property1];
  
    TFEvent * event1 = [TFEvent eventNamed:kEventValueChanged];
    event1.param1 = [TFPropertyInvocation invocationWithProperty:property1
                                                          target:self];
    
    self.events = [NSMutableArray arrayWithObject:event1];
    self.flexValue = 270;
}


- (void)loadPins
{
    THElementPin * flexPin = [THElementPin pinWithType:kElementPintypeAnalog];
    flexPin.hardware = self;
    
    THElementPin * minusPin = [THElementPin pinWithType:kElementPintypeMinus];
    minusPin.hardware = self;
    
    THElementPin * plusPin = [THElementPin pinWithType:kElementPintypePlus];
    plusPin.hardware = self;

    [self.pins addObject:flexPin];
    [self.pins addObject:minusPin];
    [self.pins addObject:plusPin];
}


#pragma mark - Methods

- (void)handlePin:(THPin *)pin
   changedValueTo:(NSInteger)newValue
{
    self.flexValue = newValue;
}


-(NSString*) description
{
    return @"flex sensor";
}

- (void)updatePinValue{
    
    THElementPin * pin = [self.pins firstObject];
    THBoardPin * lilypadPin = (THBoardPin*) pin.attachedToPin;
    
    lilypadPin.value = self.flexValue;
}



- (void)setFlexValue:(NSUInteger)flexValue
{
    _flexValue = flexValue;
    [self triggerEventNamed:kEventValueChanged];
    [self updatePinValue];
}





#pragma mark - Archiving

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

- (id)copyWithZone:(NSZone *)zone
{
    THFlexSensor * copy = [super copyWithZone:zone];
    
    return copy;
}



@end
