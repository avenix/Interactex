/*
THLightSensorEditableObject.m
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

#import "THLightSensorEditableObject.h"
#import "THLightSensor.h"
#import "THElementPinEditable.h"
#import "THElementPin.h"
#import "THBoardPinEditable.h"

@implementation THLightSensorEditableObject

-(void) loadLightSensor{
    self.sprite = [CCSprite spriteWithFile:@"lightSensor.png"];
    [self addChild:self.sprite z:kClotheObjectZ];
    
    _lightSprite = [CCSprite spriteWithFile: @"light.png"];
    _lightSprite.opacity = 0;
    _lightSprite.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
    [self addChild:_lightSprite];
    
    self.acceptsConnections = YES;
    
}

-(id) init{
    self = [super init];
    if(self){
        self.simulableObject = [[THLightSensor alloc] init];
        
        self.type = kHardwareTypeLightSensor;
        
        [self loadLightSensor];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    [self loadLightSensor];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone {
    THLightSensorEditableObject * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers
{
    NSMutableArray *controllers = [NSMutableArray array];
    //[controllers addObject:[THLightSensorProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(void) handleTouchBegan{
        NSLog(@"%s",__PRETTY_FUNCTION__);
    self.isDown = YES;
}

-(void) handleTouchEnded{
            NSLog(@"%s",__PRETTY_FUNCTION__);
    self.isDown = NO;
}

-(THElementPinEditable*) minusPin{
    return [self.pins objectAtIndex:0];
}

-(THElementPinEditable*) analogPin{
    return [self.pins objectAtIndex:1];
}

-(THElementPinEditable*) plusPin{
    return [self.pins objectAtIndex:2];
}

-(void) updatePinValue{
    THElementPinEditable * analogPin = self.analogPin;
    THBoardPinEditable * boardPin = analogPin.attachedToPin;
    THLightSensor * sensor = (THLightSensor*) self.simulableObject;
    boardPin.value = sensor.light;
}

-(void) update{
    
    if(self.isDown){
        _lightTouchDownIntensity += 1.5f;
    } else {
        _lightTouchDownIntensity -= 1.0f;
    }
    THLightSensor * lightSensor = (THLightSensor*) self.simulableObject;
    _lightTouchDownIntensity = [THClientHelper Constrain:_lightTouchDownIntensity min:0 max:255];
    
    lightSensor.light =_lightTouchDownIntensity;
    _lightSprite.opacity = _lightTouchDownIntensity;
}

-(void) willStartSimulation{
    _lightSprite.visible = YES;
    [super willStartSimulation];
}

-(void) willStartEdition{
    _lightSprite.visible = NO;
    [super willStartEdition];
}

-(NSInteger) light{
    THLightSensor * lightSensor = (THLightSensor*) self.simulableObject;
    return lightSensor.light;
}

-(NSString*) description{
    return @"Light Sensor";
}

@end
