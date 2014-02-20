/*
THCompassLSM303.m
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

#import "THCompassLSM303.h"
#import "THElementPin.h"
#import "THI2CComponent.h"
#import "THI2CRegister.h"
#import "THI2CMessage.h"

@implementation THCompassLSM303

@synthesize i2cComponent;
@synthesize type;

#pragma mark - Initialization

-(id) init{
    self = [super init];
    if(self){
        
        [self loadMethods];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder{
    
    self = [super initWithCoder:decoder];
    if(self){
        [self loadMethods];
        [self loadI2CComponent];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
    
}

-(id)copyWithZone:(NSZone *)zone{
    
    THCompassLSM303 * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Loading

-(void) loadMethods{
    
    TFProperty * property1 = [TFProperty propertyWithName:@"accelerometerX" andType:kDataTypeInteger];
    TFProperty * property2 = [TFProperty propertyWithName:@"accelerometerY" andType:kDataTypeInteger];
    TFProperty * property3 = [TFProperty propertyWithName:@"accelerometerZ" andType:kDataTypeInteger];
    
    TFProperty * property4 = [TFProperty propertyWithName:@"heading" andType:kDataTypeFloat];
    self.properties = [NSMutableArray arrayWithObjects:property1,property2,property3,property4,nil];
    
    TFEvent * event1 = [TFEvent eventNamed:kEventXChanged];
    event1.param1 = [TFPropertyInvocation invocationWithProperty:property1 target:self];
    TFEvent * event2 = [TFEvent eventNamed:kEventYChanged];
    event2.param1 = [TFPropertyInvocation invocationWithProperty:property2 target:self];
    TFEvent * event3 = [TFEvent eventNamed:kEventZChanged];
    event3.param1 = [TFPropertyInvocation invocationWithProperty:property3 target:self];
    
    TFEvent * event4 = [TFEvent eventNamed:kEventHeadingChanged];
    event4.param1 = [TFPropertyInvocation invocationWithProperty:property4 target:self];
    
    self.events = [NSMutableArray arrayWithObjects:event1,event2,event3,event4,nil];
}

-(void) loadPins{
    
    THElementPin * minusPin = [THElementPin pinWithType:kElementPintypeMinus];
    THElementPin * plusPin = [THElementPin pinWithType:kElementPintypePlus];
    
    minusPin.hardware = self;
    THElementPin * sclPin = [THElementPin pinWithType:kElementPintypeScl];
    sclPin.hardware = self;
    sclPin.defaultBoardPinMode = kPinModeI2C;
    
    THElementPin * sdaPin = [THElementPin pinWithType:kElementPintypeSda];
    sdaPin.hardware = self;
    sdaPin.defaultBoardPinMode = kPinModeI2C;
    
    
    [self.pins addObject:minusPin];
    [self.pins addObject:plusPin];
    [self.pins addObject:sclPin];
    [self.pins addObject:sdaPin];
}

-(THI2CComponent*) loadI2CComponent{
    
    self.i2cComponent = [[THI2CComponent alloc] init];
    self.i2cComponent.address = 24;
    
    THI2CRegister * reg1 = [[THI2CRegister alloc] init];
    reg1.number = 32;
    
    THI2CRegister * reg2 = [[THI2CRegister alloc] init];
    reg2.number = 40;
    
    [self.i2cComponent addRegister:reg1];
    [self.i2cComponent addRegister:reg2];
    
    return self.i2cComponent;
}


#pragma mark - Methods

-(THElementPin*) sclPin{
    return [self.pins objectAtIndex:2];
}

-(THElementPin*) sdaPin{
    return [self.pins objectAtIndex:3];
}

-(void) setValuesFromBuffer:(uint8_t*) buffer length:(NSInteger) length{
    
    NSInteger size = 6;
    NSInteger bufCount = 0;
    uint8_t values[size];

    for (int i = 0; i < size; i++) {
        uint8_t byte1 = buffer[bufCount++];
        uint8_t value = byte1 + (buffer[bufCount++] << 7);
        values[i] = value;
    }
    
    self.accelerometerX = ((int16_t)(values[1] << 8 | values[0])) >> 4;
    self.accelerometerY = ((int16_t)(values[3] << 8 | values[2])) >> 4;
    self.accelerometerZ = ((int16_t)(values[5] << 8 | values[4])) >> 4;
}

-(NSMutableArray*) startI2CMessages{
    THI2CMessage * message1 = [[THI2CMessage alloc] init];
    message1.type = kI2CComponentMessageTypeWrite;
    message1.reg = 32;
    
    uint8_t buf[2];
    [THClientHelper valueAsTwo7bitBytes:39 buffer:buf];
    
    message1.bytes = [NSData dataWithBytes:buf length:2];
    
    THI2CMessage * message2 = [[THI2CMessage alloc] init];
    message2.type = kI2CComponentMessageTypeStartReading;
    message2.reg = 40;
    message2.readSize = 6;
    
    NSMutableArray * array = [NSMutableArray arrayWithObjects:message1,message2,nil];
    return array;
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

-(void) setHeading:(NSInteger)heading{
    if(heading != _heading){
        _heading = heading;
        [self triggerEventNamed:kEventHeadingChanged];
    }
}

-(void) didStartSimulating{
    [self triggerEventNamed:kEventXChanged];
    [self triggerEventNamed:kEventYChanged];
    [self triggerEventNamed:kEventZChanged];
    
    [self triggerEventNamed:kEventHeadingChanged];
    
    [super didStartSimulating];
}


-(NSString*) description{
    return @"compass LSM303";
}

-(void) prepareToDie{
    
    self.i2cComponent = nil;
    
    [super prepareToDie];
}
@end
