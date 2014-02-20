/*
 THBLELilypad.m
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

#import "THBLELilyPad.h"
#import "THBoardPin.h"
#import "THI2CComponent.h"
#import "THHardwareComponent.h"
#import "THElementPin.h"
#import "THI2CProtocol.h"

@implementation THBLELilyPad

NSInteger const kBLELilypadNumberOfPins = 22;

@dynamic minusPin;
@dynamic plusPin;
@dynamic sclPin;
@dynamic sdaPin;

-(void) load{
    self.numberOfDigitalPins = 14;
    self.numberOfAnalogPins = 6;
    
    THBoardPin * analogPin5 =  [self analogPinWithNumber:5];
    analogPin5.supportsSCL = YES;
    
    THBoardPin * analogPin4 =  [self analogPinWithNumber:4];
    analogPin4.supportsSDA = YES;
    
    [self setPwmPins];
}

-(void) setPwmPins{
    for (int i = 0; i < kLilypadNumPwmPins; i++) {
        NSInteger pinIdx = kLilypadPwmPins[i];
        THBoardPin * boardpin = [self digitalPinWithNumber:pinIdx];
        boardpin.isPWM = YES;
    }
}

-(void) loadPins{
    
    for (int i = 0; i <= 4; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i andType:kPintypeDigital];
        [self.pins addObject:pin];
    }
    
    THBoardPin * minusPin = [THBoardPin pinWithPinNumber:-1 andType:kPintypeMinus];
    [self.pins addObject:minusPin];
    
    THBoardPin * plusPin = [THBoardPin pinWithPinNumber:-1 andType:kPintypePlus];
    [self.pins addObject:plusPin];
    
    for (int i = 7; i <= 15; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i-2 andType:kPintypeDigital];
        [self.pins addObject:pin];
    }
    
    for (int i = 16; i < kBLELilypadNumberOfPins; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i-16 andType:kPintypeAnalog];
        [self.pins addObject:pin];
    }
}

-(id) init{
    self = [super init];
    if(self){
        
        self.pins = [NSMutableArray array];
        self.i2cComponents = [NSMutableArray array];
        
        [self loadPins];
        [self load];
    }
    return self;
}


#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        
        [self load];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
}

#pragma mark - Pins

-(NSMutableArray*) analogPins{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.numberOfAnalogPins];
    for (int i = 0; i < self.numberOfAnalogPins; i++) {
        THBoardPin * pin = [self analogPinWithNumber:i];
        [array addObject:pin];
    }
    return array;
}

-(NSMutableArray*) digitalPins{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.numberOfDigitalPins];
    for (int i = 0; i < self.numberOfDigitalPins; i++) {
        THBoardPin * pin = [self digitalPinWithNumber:i];
        [array addObject:pin];
    }
    return array;
}

-(THBoardPin*) minusPin{
    return [self.pins objectAtIndex:5];
}

-(THBoardPin*) plusPin{
    return [self.pins objectAtIndex:6];
}

-(THBoardPin*) sclPin{
    return [self analogPinWithNumber:5];
}

-(THBoardPin*) sdaPin{
    return [self analogPinWithNumber:4];
}

-(NSInteger) realIdxForPin:(THBoardPin*) pin{
    
    if(pin.type == kPintypeDigital){
        return pin.number;
    } else {
        return pin.number + self.numberOfDigitalPins;
    }
}

-(THBoardPin*) pinWithRealIdx:(NSInteger) pinNumber{
    NSInteger pinidx;
    
    if(pinNumber <= self.numberOfDigitalPins){
        return [self digitalPinWithNumber:pinNumber];
    } else {
        return [self analogPinWithNumber:pinNumber - self.numberOfDigitalPins];
    }
    return [self.pins objectAtIndex:pinidx];
}

-(NSInteger) pinIdxForPin:(NSInteger) pinNumber ofType:(THPinType) type{
    if(type == kPintypeDigital){
        if(pinNumber <= 4) {
            return pinNumber;
        } else if(pinNumber <= self.numberOfDigitalPins){
            return pinNumber + 2;
        }
        
        return pinNumber;
    } else if(type == kPintypeAnalog){
        if(pinNumber >= 0 && pinNumber <= 5){
            return pinNumber + 16;
        }
    } else if(type == kPintypeMinus){
        return 5;
    } else if(type == kPintypePlus){
        return 6;
    }
    
    return -1;
}

-(THBoardPin*) digitalPinWithNumber:(NSInteger) number{
    NSInteger idx = [self pinIdxForPin:number ofType:kPintypeDigital];
    if(idx >= 0){
        return [self.pins objectAtIndex:idx];
    }
    return nil;
}

-(THBoardPin*) analogPinWithNumber:(NSInteger) number{
    
    NSInteger idx = [self pinIdxForPin:number ofType:kPintypeAnalog];
    if(idx >= 0){
        return [self.pins objectAtIndex:idx];
    }
    return nil;
}

#pragma mark - Other

-(NSString*) description{
    return @"lilypad";
}

-(void) prepareToDie{
    for (THBoardPin * pin in self.pins) {
        [pin prepareToDie];
    }
    self.pins = nil;
    [super prepareToDie];
}

@end
