/*
 THLilypadEditable.m
 Interactex Designer
 
 Created by Juan Haladjian on 13/02/14.
 
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

#import "THBLELilyPadEditable.h"
#import "THPinEditable.h"
#import "THLilyPad.h"
#import "THBoardPinEditable.h"
#import "THBoardProperties.h"
#import "THBLELilyPadProperties.h"

@implementation THBLELilyPadEditable

@synthesize pins = _pins;
@dynamic numberOfDigitalPins;
@dynamic numberOfAnalogPins;

#define kBLELilypadNumberOfPins 22

CGPoint kBLELilypadPinPositions[kBLELilypadNumberOfPins] = {{1,110},{-29,104},{-58.0, 91.0},{-84.0, 72.0},{-100.0, 45.0},//0 - 4
    {-111.0, 16.0}, {-102.0, -17.0},//- +
    {-100.0, -42.0},{-83.0, -70.0},{-59.0, -92.0},{-31.0, -102.0},{0.0, -110.0},{30.0, -105.0},//5-10
    {60.0, -96.0},{84.0, -73.0},{101.0, -48.0},//11-13
    {110.0, -17.0},{108.0, 13.0},{101.0, 42.0},{84.0, 72.0},{61.0, 92.0},{31,105}//A0 - A5
};

-(void) loadLilypad{
    self.z = kLilypadZ;
    
    self.sprite = [CCSprite spriteWithFile:@"BLE-LilyPad.png"];
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
    
    THLilyPad * lilypad = (THLilyPad*) self.simulableObject;
    for (THPin * pin in lilypad.pins) {
        THBoardPinEditable * pinEditable = [[THBoardPinEditable alloc] init];
        pinEditable.simulableObject = pin;
        
        pinEditable.position = ccpAdd(ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f), kBLELilypadPinPositions[i]);
        pinEditable.position = ccpAdd(pinEditable.position, ccp(pinEditable.contentSize.width/2.0f, pinEditable.contentSize.height/2.0f));
        [_pins addObject:pinEditable];
        i++;
    }
    
    [self addPins];
}

-(id) init{
    self = [super init];
    if(self){
        _pins = [NSMutableArray array];
        
        THLilyPad * lilyPad = [[THLilyPad alloc] init];
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
    [controllers addObject:[THBLELilyPadProperties properties]];
    [controllers addObject:[THBoardProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(NSInteger) numberOfDigitalPins{
    THLilyPad * lilypad = (THLilyPad*) self.simulableObject;
    return lilypad.numberOfDigitalPins;
}

-(NSInteger) numberOfAnalogPins{
    THLilyPad * lilypad = (THLilyPad*) self.simulableObject;
    return lilypad.numberOfAnalogPins;
}

-(THBoardPinEditable*) digitalPinWithNumber:(NSInteger) number{
    
    THLilyPad * lilypad = (THLilyPad*) self.simulableObject;
    NSInteger idx = [lilypad pinIdxForPin:number ofType:kPintypeDigital];
    if(idx >= 0){
        return _pins[idx];
    }
    return nil;
}

#pragma mark - Methods

-(THBoardPinEditable*) minusPin{
    return [self.pins objectAtIndex:5];
}

-(THBoardPinEditable*) plusPin{
    return [self.pins objectAtIndex:6];
}

-(THBoardPinEditable*) sclPin{
    return [self analogPinWithNumber:5];
}

-(THBoardPinEditable*) sdaPin{
    return [self analogPinWithNumber:4];
}

-(THBoardPinEditable*) analogPinWithNumber:(NSInteger) number{
    THLilyPad * lilypad = (THLilyPad*) self.simulableObject;
    NSInteger idx = [lilypad pinIdxForPin:number ofType:kPintypeAnalog];
    if(idx >= 0){
        return _pins[idx];
    }
    return nil;
}

#pragma mark - Lifecycle

-(void) willStartSimulation{
    [super willStartSimulation];
}

-(NSString*) description{
    return @"Lilypad";
}
@end
