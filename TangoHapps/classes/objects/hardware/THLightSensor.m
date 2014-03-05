/*
THLightSensor.m
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

#import "THLightSensor.h"
#import "THElementPin.h"

@implementation THLightSensor

-(void) load{
    
    TFProperty * property = [TFProperty propertyWithName:@"light" andType:kDataTypeInteger];
    self.properties = [NSMutableArray arrayWithObject:property];
    
    TFEvent * event = [TFEvent eventNamed:kEventLightChanged];
    event.param1 = [TFPropertyInvocation invocationWithProperty:property target:self];
    self.events = [NSMutableArray arrayWithObject:event];
}

-(void) loadPins{
    
    THElementPin * pin1 = [THElementPin pinWithType:kElementPintypeMinus];
    pin1.hardware = self;
    THElementPin * pin2 = [THElementPin pinWithType:kElementPintypeAnalog];
    pin2.hardware = self;
    pin2.defaultBoardPinMode = kPinModeAnalogInput;
    THElementPin * pin3 = [THElementPin pinWithType:kElementPintypePlus];
    pin3.hardware = self;
    
    [self.pins addObject:pin1];
    [self.pins addObject:pin2];
    [self.pins addObject:pin3];
}

-(id) init{
    self = [super init];
    if(self){
        [self load];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder{
    self = [super initWithCoder:decoder];
    
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone{
    THLightSensor * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Protocols

-(NSString*) description{
    return @"light sensor";
}

#pragma mark - Methods

-(THElementPin*) minusPin{
    return [self.pins objectAtIndex:0];
}

-(THElementPin*) analogPin{
    return [self.pins objectAtIndex:1];
}

-(THElementPin*) plusPin{
    return [self.pins objectAtIndex:2];
}

-(void) updatePinValue{
    
    THElementPin * pin = self.analogPin;
    THBoardPin * lilypadPin = (THBoardPin*) pin.attachedToPin;
    lilypadPin.value = self.light;
}

-(void) handlePin:(THBoardPin*) pin changedValueTo:(NSInteger) newValue{
    self.light = newValue;
}

-(void) setLight:(NSInteger)light{
    if(_light != light){
        _light = light;
        [self triggerEventNamed:kEventLightChanged];
        [self updatePinValue];
    }
}
@end
