/*
THAccelerometer.m
Interactex Designer

Created by Juan Haladjian on 12/10/2013.

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

#import "THAccelerometer.h"
#import "THElementPin.h"

@implementation THAccelerometer

#pragma mark - Initialization

-(id) init{
    self = [super init];
    if(self){
        
        [self load];
        [self loadPins];
    }
    return self;
}

-(void) load{
    
    TFProperty * property1 = [TFProperty propertyWithName:@"accelerometerX" andType:kDataTypeInteger];
    TFProperty * property2 = [TFProperty propertyWithName:@"accelerometerY" andType:kDataTypeInteger];
    TFProperty * property3 = [TFProperty propertyWithName:@"accelerometerZ" andType:kDataTypeInteger];
    
    self.properties = [NSMutableArray arrayWithObjects:property1,property2,property3,nil];
    
    TFEvent * event1 = [TFEvent eventNamed:kEventXChanged];
    event1.param1 = [TFPropertyInvocation invocationWithProperty:property1 target:self];
    TFEvent * event2 = [TFEvent eventNamed:kEventYChanged];
    event2.param1 = [TFPropertyInvocation invocationWithProperty:property2 target:self];
    TFEvent * event3 = [TFEvent eventNamed:kEventZChanged];
    event3.param1 = [TFPropertyInvocation invocationWithProperty:property3 target:self];
    
    self.events = [NSMutableArray arrayWithObjects:event1,event2,event3,nil];
}

-(void) loadPins{
    
    THElementPin * xPin = [THElementPin pinWithType:kElementPintypeAnalog];
    xPin.hardware = self;
    
    THElementPin * yPin = [THElementPin pinWithType:kElementPintypeAnalog];
    yPin.hardware = self;
    
    THElementPin * zPin = [THElementPin pinWithType:kElementPintypeAnalog];
    zPin.hardware = self;
    
    THElementPin * minusPin = [THElementPin pinWithType:kElementPintypeMinus];
    minusPin.hardware = self;
    
    THElementPin * plusPin = [THElementPin pinWithType:kElementPintypePlus];
    plusPin.hardware = self;
    
    [self.pins addObject:xPin];
    [self.pins addObject:yPin];
    [self.pins addObject:zPin];
    [self.pins addObject:minusPin];
    [self.pins addObject:plusPin];
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder{
    
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone{
    THAccelerometer * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Methods

-(void) setValuesFromBuffer:(uint8_t*) buffer length:(NSInteger) length{
    
    self.accelerometerX = ((int16_t)(buffer[1] << 8 | buffer[0])) >> 4;
    self.accelerometerY = ((int16_t)(buffer[3] << 8 | buffer[2])) >> 4;
    self.accelerometerZ = ((int16_t)(buffer[5] << 8 | buffer[4])) >> 4;
}

-(void) setAccelerometerX:(NSInteger)accelerometerX{
    if(accelerometerX != _accelerometerX){
        _accelerometerX = accelerometerX;
        
        [self triggerEventNamed:kEventXChanged];
    }
}

-(void) setAccelerometerY:(NSInteger)accelerometerY{
    if(accelerometerY != _accelerometerY){
        _accelerometerY = accelerometerY;
        
        [self triggerEventNamed:kEventYChanged];
    }
}

-(void) setAccelerometerZ:(NSInteger)accelerometerZ{
    if(accelerometerZ != _accelerometerZ){
        _accelerometerZ = accelerometerZ;
        
        [self triggerEventNamed:kEventZChanged];
    }
}

-(void) didStartSimulating{
    [self triggerEventNamed:kEventXChanged];
    [self triggerEventNamed:kEventYChanged];
    [self triggerEventNamed:kEventZChanged];
    
    [super didStartSimulating];
}

-(NSString*) description{
    return @"accelerometer";
}

@end
