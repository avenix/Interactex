/*
THMapper.m
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

#import "THMapper.h"

@implementation THMapper

-(void) load{
    
    TFProperty * property = [TFProperty propertyWithName:@"value" andType:kDataTypeFloat];
    self.properties = [NSMutableArray arrayWithObject:property];
    
    TFMethod * method = [TFMethod methodWithName:@"setValue"];
    method.numParams = 1;
    method.firstParamType = kDataTypeFloat;
    self.methods = [NSMutableArray arrayWithObject:method];
    
    TFEvent * event = [TFEvent eventNamed:kEventValueChanged];
    event.param1 = [TFPropertyInvocation invocationWithProperty:property target:self];
    self.events = [NSMutableArray arrayWithObject:event];
}

-(id) init{
    self = [super init];
    if(self){
        [self load];
        
        _min1 = 0;
        _max1 = 1;
        
        _min2 = 0;
        _max2 = 255;
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        _min1 = [decoder decodeFloatForKey:@"min1"];
        _max1 = [decoder decodeFloatForKey:@"max1"];
        _min2 = [decoder decodeFloatForKey:@"min2"];
        _max2 = [decoder decodeFloatForKey:@"max2"];
        
        [self load];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:_min1 forKey:@"min1"];
    [coder encodeFloat:_max1 forKey:@"max1"];
    [coder encodeFloat:_min2 forKey:@"min2"];
    [coder encodeFloat:_max2 forKey:@"max2"];
}

-(id)copyWithZone:(NSZone *)zone {
    THMapper * copy = [super copyWithZone:zone];
    
    copy.min1 = self.min1;
    copy.max1 = self.max1;
    copy.min2 = self.min2;
    copy.max2 = self.max2;
    
    return copy;
}

#pragma mark - Methods

-(float) mapAndConstrain:(float) value{
    
    value = [THClientHelper LinearMapping:value min:self.min1 max:self.max1 retMin:self.min2 retMax:self.max2];
    value = [THClientHelper Constrain:value min:self.min2 max:self.max2];
    
    return value;
}

-(void) setValue:(float)value{
    _value = [self mapAndConstrain:value];
    [self triggerEventNamed:kEventValueChanged];
}

-(void) didStartSimulating{
    [self triggerEventNamed:kEventValueChanged];
    [super didStartSimulating];
}

-(NSString*) description{
    return @"value";
}


@end
