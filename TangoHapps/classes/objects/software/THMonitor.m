/*
THMonitor.m
Interactex Designer

Created by Juan Haladjian on 04/11/2013.

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

#import "THMonitor.h"
#import "THGraphView.h"

@implementation THMonitor

//float const kMonitorUpdateFrequency = 1/20.0f; //monitor updated every 0.5 seconds
float const kMonitorNewValueX = 75.0f;

-(void) loadMonitor{
    
    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    
    THGraphView * view = [[THGraphView alloc] initWithFrame:frame maxAxisY:self.maxValue minAxisY:self.minValue];
    view.layer.borderWidth = 1.0f;
    view.contentMode = UIViewContentModeScaleAspectFit;

    self.view = view;
    
    [self addMethods];
}

-(void) addMethods{
    
    TFMethod * method1 =[TFMethod methodWithName:@"addValue1"];
    method1.firstParamType = kDataTypeFloat;
    method1.numParams = 1;
    
    TFMethod * method2 =[TFMethod methodWithName:@"addValue2"];
    method2.firstParamType = kDataTypeFloat;
    method2.numParams = 1;
    
    self.methods = [NSMutableArray arrayWithObjects:method1,method2,nil];
}

-(id) init{
    
    self = [super init];
    
    if(self){
        
        self.width = 265;
        self.height = 130;
        
        _maxValue = 255;
        _minValue = -255;
        
        [self loadMonitor];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    
    self = [super initWithCoder:decoder];
    
    if(self){
        
        _maxValue = [decoder decodeIntegerForKey:@"maxValue"];
        _minValue = [decoder decodeIntegerForKey:@"minValue"];
        
        [self loadMonitor];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.maxValue forKey:@"maxValue"];
    [coder encodeInteger:self.minValue forKey:@"minValue"];
}


-(id)copyWithZone:(NSZone *)zone {
    THMonitor * copy = [super copyWithZone:zone];
    
    copy.maxValue = self.maxValue;
    copy.minValue = self.minValue;
    
    return copy;
}

#pragma mark - Methods

-(float) mapValueToGraphRange:(float) value{
    float range = (self.maxValue - self.minValue);
    value = (value + fabs(self.minValue)) / range;
    
    float offset = (kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f);
    value *= (self.view.frame.size.height - 2 * offset);
    value += offset;
    
    return value;
}

-(void) addValue1:(float) value{
    
    value = [self mapValueToGraphRange:value];
    
    THGraphView * view = (THGraphView*)self.view;
    [view addX:value];
    
}

-(void) addValue2:(float) value{
    value = [self mapValueToGraphRange:value];
    
    THGraphView * view = (THGraphView*)self.view;
    [view addY:value];
}

-(void) setMaxValue:(NSInteger)maxValue{
    
    THGraphView * view = (THGraphView*)self.view;
    view.maxAxisY = maxValue;
    
    _maxValue = maxValue;
}

-(void) setMinValue:(NSInteger)minValue{
    
    THGraphView * view = (THGraphView*)self.view;
    view.minAxisY = minValue;
    
    _minValue = minValue;
}

#pragma mark - Lifecycle

-(NSString*) description{
    return @"monitor";
}

-(void) willStartSimulating{
    
    THGraphView* view = (THGraphView*) self.view;
    [view start];
    
    [super willStartSimulating];
}

-(void) stopSimulating{
    THGraphView* view = (THGraphView*) self.view;
    [view stop];
    
    [super stopSimulating];
}

@end
