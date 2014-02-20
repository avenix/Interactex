/*
THComparisonCondition.m
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

#import "THComparisonCondition.h"

@implementation THComparisonCondition

#pragma mark - Archiving

-(void) loadMethods{
    TFMethod * method1 = [TFMethod methodWithName:kMethodSetValue1];
    method1.numParams = 1;
    method1.firstParamType = kDataTypeFloat;
    
    TFMethod * method2 = [TFMethod methodWithName:kMethodSetValue2];
    method2.numParams = 1;
    method2.firstParamType = kDataTypeFloat;
    
    
    self.methods = [NSMutableArray arrayWithObjects:method1,method2,nil];
}

-(id) init{
    self = [super init];
    if(self){
        [self loadMethods];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    [self loadMethods];
    
    self.type = [decoder decodeIntegerForKey:@"type"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.type forKey:@"type"];
}

-(id)copyWithZone:(NSZone *)zone
{
    THComparisonCondition * copy = [super copyWithZone:zone];
    
    copy.type = self.type;
    
    return copy;
}

#pragma mark - Methods

-(void) setValue1:(float) number{
    _value1set = YES;
    _value1 = number;
    if(_value2set){
        [self evaluateAndTrigger];
    }
}

-(void) setValue2:(float) number{
    _value2set = YES;
    _value2 = number;
    if(_value1set){
        [self evaluateAndTrigger];
    }
}

-(BOOL) testCondition{
    
    if(self.type == kConditionTypeBiggerThan){
        return self.value1 > self.value2;
    } else if(self.type == kConditionTypeSmallerThan){
        return self.value1 < self.value2;
    } else {
        return fabs(self.value1 - self.value2) < 0.0001;
    }
    
    return NO;
}

-(NSString*) description{
    return @"comparison";
}

-(void) prepareToDie{
    [super prepareToDie];
}
@end
