//
//  THBoardPin.m
//  TangoHapps
//
//  Created by Juan Haladjian on 11/9/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "THBoardPin.h"
#import "THElementPin.h"
#import "THClotheObject.h"
#import "IFPin.h"

@implementation THBoardPin
@dynamic acceptsManyPins;

+(id) pinWithPinNumber:(NSInteger) pinNumber andType:(THPinType) type{
    return [[THBoardPin alloc] initWithPinNumber:pinNumber andType:type];
}

-(id) initWithPinNumber:(NSInteger) pinNumber andType:(THPinType) type{
    
    self = [super init];
    if(self){
        self.pin.number = pinNumber;
        self.type = type;
        //self.pin.mode = kPinModeUndefined;
        
        _attachedElementPins = [NSMutableArray array];
    }
    return self;
    
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    _attachedElementPins = [decoder decodeObjectForKey:@"attachedPins"];
    self.pin.number = [decoder decodeIntForKey:@"number"];
    _type = [decoder decodeIntForKey:@"pinType"];
    self.pin.mode = [decoder decodeIntForKey:@"mode"];
    _isPWM = [decoder decodeBoolForKey:@"isPWM"];

    return self;
}

-(id) init{
    self = [super init];
    if(self){
        _attachedElementPins = [NSMutableArray array];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:self.attachedElementPins forKey:@"attachedPins"];
    [coder encodeInt:self.pin.number forKey:@"number"];
    [coder encodeInt:self.type forKey:@"pinType"];
    [coder encodeInt:self.pin.mode forKey:@"mode"];
    [coder encodeBool:self.isPWM forKey:@"isPWM"];
}

-(id)copyWithZone:(NSZone *)zone {
    THBoardPin * copy = [super copyWithZone:zone];
    copy.pin = self.pin;
    copy.type = self.type;
    
    return copy;
}

#pragma mark - Methods

-(NSInteger) number{
    return self.pin.number;
}

-(void) setMode:(IFPinMode)mode{
    self.pin.mode = mode;
}

-(IFPinMode) mode{
    return self.pin.mode;
}

-(NSInteger) value{
    return self.pin.value;
}

-(void) setValue:(NSInteger)value{
    self.pin.value = value;
}

-(void) setPin:(IFPin *)pin{
    if(_pin != pin){
        [self removePinObserver];
        _pin = pin;
        [self addPinObserver];
    }
}

-(BOOL) acceptsManyPins{
    return (self.type == kPintypeMinus || self.type == kPintypePlus);
}


/*
-(void) setCurrentValue:(NSInteger)value{
    if(value != self.currentValue){
        self.hasChanged = YES;
        _currentValue = value;
        //[self notifyPinsNewValue:value];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPinValueChanged object:self];
    }
}*/

-(void) attachPin:(THElementPin*) pin{
    if(!self.acceptsManyPins && self.attachedElementPins.count == 1){
        THElementPin * pin = [self.attachedElementPins objectAtIndex:0];
        [pin deattach];
        
        [self.attachedElementPins removeAllObjects];
    }
    /*
    if(self.type != kPintypeMinus && self.type != kPintypePlus && self.mode == kPinModeUndefined){
        self.mode = pin.defaultBoardPinMode;
    }*/
    
    [self.attachedElementPins addObject:pin];
}

-(void) deattachPin:(THElementPin*) pin{
    [self.attachedElementPins removeObject:pin];
    /*
    if(_attachedPins.count == 0){
        self.mode = kPinModeUndefined;
    }*/
}

-(void) prepareToDie{
    _attachedElementPins = nil;
    self.pin = nil;
}

-(NSString*) description{
    
    NSString * text;
    if(self.type == kPintypeMinus || self.type == kPintypePlus){
        text = [NSString stringWithFormat:@"(%@) pin",kPinTexts[self.type]];
    } else {
        text = [NSString stringWithFormat:@"pin %d (%@)",self.pin.number, kPinTexts[self.type]];
    }
    
    return text;
}

#pragma mark - Pin Observing & Value Notification

-(void) removePinObserver{
    [self.pin removeObserver:self forKeyPath:@"value"];
}

-(void) addPinObserver{
    [self.pin addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"value"]){
        [self notifyNewValue];
    }
}

-(void) notifyNewValue{
    
    for (THElementPin * pin in self.attachedElementPins) {
        [pin.hardware handlePin:self changedValueTo:self.pin.value];
    }
}

@end


