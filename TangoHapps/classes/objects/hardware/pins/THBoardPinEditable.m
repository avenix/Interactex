/*
THBoardPinEditable.m
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

#import "THBoardPinEditable.h"
#import "THBoardPin.h"
#import "THElementPinEditable.h"
#import "THEditor.h"

@implementation THBoardPinEditable

@synthesize attachedPins = _attachedPins;
@dynamic number;
@dynamic type;
@dynamic mode;
@dynamic acceptsManyPins;
@dynamic isPWM;
@dynamic value;

-(id) init{
    self = [super init];
    if(self){
        _attachedPins = [NSMutableArray array];
    }
    return self;
}

-(id) initWithPin:(THBoardPin*) pin{
    self = [super init];
    if(self){
        self.simulableObject = pin;
        _attachedPins = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    
    _attachedPins = [decoder decodeObjectForKey:@"attachedPins"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.attachedPins forKey:@"attachedPins"];
}

#pragma mark - Methods

-(void) setHighlighted:(BOOL)selected{
    if(selected){
        
        NSString * text = kPinTexts[self.type];
        
        if(self.type == kPintypeAnalog || self.type == kPintypeDigital){

            text = [text stringByAppendingFormat:@" %d",self.number];
        }
        
        
        _label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(60, 30) hAlignment:kCCVerticalTextAlignmentCenter fontName:kSimulatorDefaultBoldFont fontSize:18];
        
        //_label = [CCLabelTTF labelWithString:text fontName:kSimulatorDefaultBoldFont fontSize:18 dimensions:CGSizeMake(60, 30) hAlignment:kCCVerticalTextAlignmentCenter];
        
        _label.position = ccp(0,50);
        
        [self addChild:_label];
        
    } else {
        [_label removeFromParentAndCleanup:YES];
        _label = nil;
    }
    
    [super setHighlighted:selected];
}

-(NSInteger) value{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.value;
}

-(void) setValue:(NSInteger)value{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    pin.value = value;
}

-(BOOL) isPWM{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.isPWM;
}

-(void) setIsPWM:(BOOL) b{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    pin.isPWM = b;
}

-(BOOL) acceptsManyPins{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.acceptsManyPins;
}

-(void) setMode:(THPinMode)mode{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    pin.mode = mode;
}

-(THPinMode) mode{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.mode;
}

-(THPinType) type{
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.type;
}

-(void) setType:(THPinType)pinType{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    pin.type = pinType;
}

-(NSInteger) number{
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.number;
}

-(void) setNumber:(NSInteger)pinNumber{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    pin.number = pinNumber;
}

-(BOOL) supportsSCL{
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.supportsSCL;
}

-(BOOL) supportsSDA{
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    return pin.supportsSDA;
}

-(void) draw{
    /*
    ccDrawColor4B(255, 0, 0, 255);
    ccDrawCircle(ccp(0,0), 3, 0, 15, 0);*/
    
    
    if(self.highlighted){
        
        glLineWidth(2);
        
        if(self.attachedPins.count > 0 && !self.acceptsManyPins){
            ccDrawColor4F(0.82, 0.58, 0.58, 1.0);

        } else {
            ccDrawColor4F(0.12, 0.58, 0.84, 1.0);
        }
        
        ccDrawCircle(ccp(0,0), kLilypadPinRadius, 0, 15, 0);
        ccDrawColor4F(1.0f, 1.0f, 1.0f, 1.0);
    }
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    if(self.type == kPintypeDigital && pin.value == 1){
        
        ccDrawColor4F(0.0f, 1.0f, 0.0f, 1.0);
        ccDrawCircle(ccp(0,0), 10, 0, 10, 0);
    }
}

-(void) attachPin:(THElementPinEditable*) pinEditable{
    if(!self.acceptsManyPins && self.attachedPins.count == 1){
        THElementPinEditable * pin = [self.attachedPins objectAtIndex:0];
        [pin dettachFromPin];
        
        [_attachedPins removeAllObjects];
    }
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    [pin attachPin:(THElementPin*) pinEditable.simulableObject];
    
    [_attachedPins addObject:pinEditable];
}

-(void) deattachPin:(THElementPinEditable*) pinEditable{
    
    THBoardPin * pin = (THBoardPin*) self.simulableObject;
    [pin deattachPin:(THElementPin*)pinEditable.simulableObject];
    
    [_attachedPins removeObject:pinEditable];
    
    [pinEditable dettachFromPin];
}

-(void) deattachAllPins{
    
    for (THElementPinEditable * pinEditable in self.attachedPins) {
        
        THBoardPin * pin = (THBoardPin*) self.simulableObject;
        [pin deattachPin:(THElementPin*)pinEditable.simulableObject];
        [pinEditable dettachFromPin];
    }
    
    [_attachedPins removeAllObjects];
}

-(BOOL) isClotheObjectAttached:(THHardwareComponentEditableObject*) object{
    for (THElementPinEditable * pin in self.attachedPins) {
        if(pin.hardware == object){
            return YES;
        }
    }
    return NO;
}

#pragma mark - Archiving

-(NSString*) description{
    return self.simulableObject.description;
}

-(void) prepareToDie{
    
    [super prepareToDie];
    
    _attachedPins = nil;
}


@end
