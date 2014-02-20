/*
TFEditableObject.h
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

#import <Foundation/Foundation.h>

@class TFSimulableObject;
@class THTriggerableProperties;
@class THViewableProperties;
@class THInvokableProperties;
@class TFEvent;
@class TFMethod;
@class THPaletteItem;
@class TFLayer;
@class TFAction;

@protocol TFEditable <NSObject>

@property (nonatomic, readonly) NSArray * propertyControllers;

@end

@interface TFEditableObject : CCNode <NSCoding, NSCopying, TFEditable> {
    CCLabelTTF * _selectionLabel;
}

@property (nonatomic) BOOL active;
@property (nonatomic) BOOL canBeDuplicated;
@property (nonatomic) BOOL canBeAddedToPalette;
@property (nonatomic) BOOL canBeScaled;
@property (nonatomic) BOOL canBeMoved;

@property (nonatomic) float rotation;
@property (nonatomic) float scale;
@property (nonatomic) CGPoint position;
@property (nonatomic, readonly) CGPoint absolutePosition;
@property (nonatomic, readonly) CGPoint center;

@property (nonatomic) CGSize size;
@property (nonatomic) float width;
@property (nonatomic) float height;

@property (nonatomic) NSInteger z;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL acceptsConnections;
@property (nonatomic,retain) CCSprite * sprite;
//@property (nonatomic, readonly) NSMutableArray * connections;

@property (nonatomic, readonly) NSString * shortDescription;
@property (nonatomic, strong) TFSimulableObject * simulableObject;

@property (nonatomic) BOOL highlighted;
@property (nonatomic) ccColor4B highlightColor;

@property (nonatomic) BOOL isAccelerometerEnabled;

@property (nonatomic, readonly) THPaletteItem * paletteItem;


@property (nonatomic) THTriggerableProperties * triggerableProperties;
@property (nonatomic) THViewableProperties * viewableEditableProperties;
@property (nonatomic) THInvokableProperties * invokableEditableProperties;

//transformation
-(void) displaceBy: (CGPoint) displacement;
-(void) scaleBy:(float) scaleDx;
-(void) rotateBy: (float) rotation;

//ui
//-(void) handleAccelerated:(UIAcceleration*) acceleration;
-(void) handleRotation:(float) degree;
-(void) handleTap;
-(BOOL) testPoint:(CGPoint)point;
-(void) handleTouchBegan;
-(void) handleTouchEnded;

//hierarchy
-(void) addToWorld;
-(void) removeFromWorld;

-(void) addToLayer:(TFLayer*) layer;
-(void) removeFromLayer:(TFLayer*) layer;

//lifecycle
-(void) willStartSimulation;
-(void) didStartSimulation;
-(void) willStartEdition;
-(void) prepareToDie;

-(BOOL) acceptsConnectionsTo:(TFEditableObject*) object;
/*
//connections
-(void) addConnectionTo:(TFEditableObject*) object animated:(BOOL) animated;
-(NSArray*) connectionsToObject:(TFEditableObject*) target;
-(void) removeConnectionTo:(TFEditableObject*) object;
-(void) removeAllConnectionsTo:(TFEditableObject*) object;
-(void) registerNotificationsFor:(TFEditableObject*) object;
-(void) handleEditableObjectRemoved:(NSNotification*) notification;
*/

//actions
-(void) handleRegisteredAsSourceForAction:(TFAction*) action;
-(void) handleRegisteredAsTargetForAction:(TFAction*) action;

//methods
-(TFMethod*) methodNamed:(NSString*) methodName;
-(TFEvent*) eventNamed:(NSString*) eventName;

-(void) reloadProperties;

//boxes
-(void) update;

@property (nonatomic) NSMutableArray* viewableProperties;
@property (nonatomic) NSMutableArray* events;
@property(nonatomic) NSMutableArray * methods;


@end
