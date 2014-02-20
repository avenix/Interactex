/*
THElementPinEditable.m
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

#import "THElementPinEditable.h"
#import "THPinEditable.h"
#import "THLilypadEditable.h"
#import "THElementPin.h"
#import "THBoardPinEditable.h"
#import "THHardwareComponentEditableObject.h"
#import "THWire.h"

@implementation THElementPinEditable

@dynamic type;
@dynamic connected;

-(void) load{
    self.acceptsConnections = YES;
}

-(id) init{
    self = [super init];
    if(self){
        [self load];
    }
    return self;
}


#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    _attachedToPin = [decoder decodeObjectForKey:@"attachedToPin"];
    
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_attachedToPin forKey:@"attachedToPin"];
}

#pragma mark - Connectable

-(BOOL) acceptsConnectionsTo:(id)anObject{
    if([anObject isKindOfClass:[THBoardEditable class]] || [anObject isKindOfClass:[THHardwareComponentEditableObject class]]){
        return YES;
    }
    
    if([anObject isKindOfClass:[THBoardPinEditable class]]){
        THBoardPinEditable * pin = anObject;
        
        if(((pin.type == kPintypeDigital && self.type == kElementPintypeDigital))
           || (pin.type == kPintypeAnalog && self.type == kElementPintypeAnalog)
           || (pin.type == kPintypeMinus && self.type == kElementPintypeMinus)
           || (pin.type == kPintypePlus && self.type == kElementPintypePlus)
           || (self.type == kElementPintypeScl && pin.supportsSCL)
           || (self.type == kElementPintypeSda && pin.supportsSDA)){
            return YES;
        }
    }
    
    return NO;
}

-(void) handleLilypadRemoved:(NSNotification*) notification{
    /* Juan check
    TFEditableObject * object = notification.object;
    [self removeAllConnectionsTo:object];*/
}

-(void) registerNotificationsFor:(TFEditableObject*) object{
    if([object isKindOfClass:[THLilyPadEditable class]]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLilypadRemoved:) name:kNotificationLilypadRemoved object:object];
    }
}

#pragma mark - Methods

-(THPinMode) defaultBoardPinMode{
    THElementPin * pin = (THElementPin*) self.simulableObject;
    return pin.defaultBoardPinMode;
}

-(void) setAttachedToPin:(THBoardPinEditable *)attachedToPin{
    _attachedToPin = attachedToPin;
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    [pin attachToPin:(THBoardPin*) attachedToPin.simulableObject];
}

-(BOOL) connected{
    return self.attachedToPin != nil;
}

-(THElementPinType) type{
    THElementPin * pin = (THElementPin*) self.simulableObject;
    return pin.type;
}

-(void) setType:(THElementPinType)type{
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    pin.type = type;
}

-(CGPoint) center{
    return [self convertToWorldSpace:ccp(0,0)];
}

-(void) draw{
    /*
    ccDrawColor4B(255, 0, 0, 255);
    ccDrawCircle(ccp(0,0), 3, 0, 15, 0);*/
    
    if(self.highlighted){
        glLineWidth(2);
        
        if(self.attachedToPin){
            
            ccDrawColor4F(0.82, 0.58, 0.58, 1.0);
            
        } else {
            
            ccDrawColor4F(0.12, 0.58, 0.84, 1.0);
            
        }
        
        ccDrawCircle(ccp(0,0), kLilypadPinRadius, 0, 15, 0);
        
        glLineWidth(1);
        ccDrawColor4F(1.0f, 1.0f, 1.0f, 1.0);
    }
    
    
    if(self.state == kElementPinStateProblem){
        glLineWidth(2);
        
        ccDrawColor4F(0.82, 0.58, 0.58, 1.0);
        
        ccDrawCircle(ccp(0,0), kLilypadPinRadius, 0, 15, 0);
        
        glLineWidth(1);
        ccDrawColor4F(1.0f, 1.0f, 1.0f, 1.0);
    }
}

-(void) attachToPin:(THBoardPinEditable*) pinEditable animated:(BOOL) animated{
    
    if(_attachedToPin != nil){
        [_attachedToPin deattachPin:self];
    }
    
    _attachedToPin = pinEditable;
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    [pin attachToPin:(THBoardPin*) pinEditable.simulableObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPinAttached object:self];
}

-(void) dettachFromPin{
    
    _attachedToPin = nil;
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    [pin deattach];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPinDeattached object:self];
}

-(NSString*) shortDescription{
    THElementPin * pin = (THElementPin*) self.simulableObject;
    return pin.shortDescription;
}

#pragma mark - Other

-(NSString*) description{
    return self.simulableObject.description;
}

-(void) prepareToDie{
    [self.attachedToPin deattachPin:self];
    [super prepareToDie];
}

@end
