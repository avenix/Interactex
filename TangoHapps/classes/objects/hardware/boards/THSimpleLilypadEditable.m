/*
THSimpleLilypadEditable.m
Interactex Designer

Created by Juan Haladjian on 05/10/2013.

Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".

Interactex is built using the Tango framework developed by TU Munich.

In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.). 
www.cocos2d-iphone.org
github.com/gabriel/gh-unit

Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
www.firmata.org

All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
www.frizting.org

Martijn ten Bhömer from TU Eindhoven contributed PureData support. Contact: m.t.bhomer@tue.nl.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "THSimpleLilyPadEditable.h"
#import "THPinEditable.h"
#import "THSimpleLilypad.h"
#import "THBoardPinEditable.h"
#import "THLilypadProperties.h"
#import "THSimpleLilypadProperties.h"
#import "THBoardProperties.h"

@implementation THSimpleLilypadEditable

@synthesize pins = _pins;
@dynamic numberOfDigitalPins;
@dynamic numberOfAnalogPins;

#define kSimpleLilypadNumberOfPins 11

CGPoint kSimpleLilypadPinPositions[kSimpleLilypadNumberOfPins] = {
    {55.0, -94.0}, {94.0, -55.0},{109.0, -2.0},{94.0, 52.0},{54.0, 91.0},//D2,3,9,10,11
    {-52, -94}, {2.0, -110.0},//- +
    {-52,91},{-92,51},{-105, -3},{-91, -55}//A2 - A5
};

/*
CGPoint kSimpleLilypadPinPositions[kSimpleLilypadNumberOfPins] = {
    {0, 0}, {0, 0},{0, 0},{0, 0},{0, 0},//D2,3,9,10,11
    {-52, -94}, {-2, -110.0},//- +
    {0,0},{0,0},{0, 0},{0, 0}//A2 - A5
};*/


-(void) loadLilypad{
    self.z = kLilypadZ;
    
    self.sprite = [CCSprite spriteWithFile:@"lilypadSimple.png"];
    [self addChild:self.sprite];
    
    self.canBeDuplicated = NO;
}

-(void) addPins{
    for (THPinEditable * pin in _pins) {
        [self addChild:pin];
    }
}

-(void) loadPins{
    int i = 0;
    
    THSimpleLilypad * lilypad = (THSimpleLilypad*) self.simulableObject;
    for (THPin * pin in lilypad.pins) {
        THBoardPinEditable * pinEditable = [[THBoardPinEditable alloc] init];
        pinEditable.simulableObject = pin;
        
        pinEditable.position = ccpAdd(ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f), kSimpleLilypadPinPositions[i]);
        pinEditable.position = ccpAdd(pinEditable.position, ccp(pinEditable.contentSize.width/2.0f, pinEditable.contentSize.height/2.0f));
        //NSLog(@"final positioN: %f %f",pinEditable.position.x,pinEditable.position.y);
        [_pins addObject:pinEditable];
        i++;
    }
    
    [self addPins];
}

-(id) init{
    self = [super init];
    if(self){
        _pins = [NSMutableArray array];
        
        THSimpleLilypad * lilyPad = [[THSimpleLilypad alloc] init];
        self.simulableObject = lilyPad;
        
        [self loadLilypad];
        [self loadPins];
        
        self.minusPin.highlightColor = kMinusPinHighlightColor;
        self.plusPin.highlightColor = kPlusPinHighlightColor;
        
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        
        [self loadLilypad];
        [self addPins];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    [controllers addObject:[THSimpleLilypadProperties properties]];
    [controllers addObject:[THBoardProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(NSInteger) numberOfDigitalPins{
    THSimpleLilypad * lilypad = (THSimpleLilypad*) self.simulableObject;
    return lilypad.numberOfDigitalPins;
}

-(NSInteger) numberOfAnalogPins{
    THSimpleLilypad * lilypad = (THSimpleLilypad*) self.simulableObject;
    return lilypad.numberOfAnalogPins;
}

-(THBoardPinEditable*) digitalPinWithNumber:(NSInteger) number{
    
    THSimpleLilypad * lilypad = (THSimpleLilypad*) self.simulableObject;
    NSInteger idx = [lilypad pinIdxForPin:number ofType:kPintypeDigital];
    if(idx >= 0){
        return _pins[idx];
    }
    return nil;
}

-(THBoardPinEditable*) analogPinWithNumber:(NSInteger) number{
    THSimpleLilypad * lilypad = (THSimpleLilypad*) self.simulableObject;
    NSInteger idx = [lilypad pinIdxForPin:number ofType:kPintypeAnalog];
    if(idx >= 0){
        return _pins[idx];
    }
    return nil;
}

#pragma mark - Pins

-(THPinEditable*) minusPin{
    return [_pins objectAtIndex:5];
}

-(THPinEditable*) plusPin{
    return [_pins objectAtIndex:6];
}

-(THPinEditable*) sclPin{
    return [self analogPinWithNumber:5];
}

-(THPinEditable*) sdaPin{
    return [self analogPinWithNumber:4];
}

#pragma mark - Lifecycle

-(void) willStartSimulation{
    [super willStartSimulation];
}

-(NSString*) description{
    return @"Lilypad";
}
@end
