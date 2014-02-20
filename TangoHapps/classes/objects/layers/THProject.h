/*
THProject.h
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

@class THHardwareComponentEditableObject;
@class THiPhoneEditableObject;
@class THViewEditableObject;
@class THClothe;
@class THLilyPadEditable;
@class THiPhoneEditableObject;
@class THClientProject;
@class THAssetCollection;
@class THWire;
@class THElementPinEditable;
@class THBoardPinEditable;
@class THInvocationConnectionLine;
@class THBoardEditable;

@class TFEditableObject;
@class TFAction;
@class TFEvent;

@interface THProject : NSObject
{
    
}

//static methods
+(BOOL) doesProjectExistWithName:(NSString*) name;
+(NSString*) newProjectName;
+(BOOL) renameProjectNamed:(NSString*) name toName:(NSString*) newName;
+(NSString*) nextProjectNameForName:(NSString*) name;


//static constructors
+(THProject*) emptyProject;
+(THProject*) projectSavedWithName:(NSString*) name;

+(id) newProject;
+(id) projectNamed:(NSString*) name;

//init
-(id) initWithName:(NSString*) name;

//saving and renaming
-(void) save;
-(BOOL) renameTo:(NSString*) newName;

//objects
-(TFEditableObject*) objectAtLocation:(CGPoint) location;

//lifecycle
-(void) willStartSimulation;
-(void) didStartSimulation;
-(void) prepareForEdition;
-(void) prepareToDie;

//actions
-(NSMutableArray*) actionsForTarget:(TFEditableObject*) target;
-(NSMutableArray*) actionsForSource:(TFEditableObject*) source;
-(void) registerAction:(TFAction*) action forEvent:(TFEvent*) event;
-(void) deregisterAction:(TFAction*) action;
-(void) deregisterActionsForObject:(TFEditableObject*) object;

//pin
-(void) pinClotheObject:(THHardwareComponentEditableObject*) clotheObject toClothe:(THClothe*) clothe;
-(void) unpinClotheObject:(THHardwareComponentEditableObject*) clotheObject;

//iPhone
-(void) addiPhone:(THiPhoneEditableObject *)iPhone;
-(void) removeiPhone;

//iPhone objects
-(void) addiPhoneObject:(THViewEditableObject*) object;
-(void) removeiPhoneObject:(THViewEditableObject*) object;
-(THViewEditableObject*) iPhoneObjectAtLocation:(CGPoint) location;

//lilypad
-(void) addBoard:(THBoardEditable *) board;
-(void) removeBoard:(THBoardEditable*) board;
-(THBoardEditable*) boardAtLocation:(CGPoint) location;

//clotheObjects
-(void) addHardwareComponent:(THHardwareComponentEditableObject*) clotheObject;
-(void) removeHardwareComponent:(THHardwareComponentEditableObject*) clotheObject;
-(THHardwareComponentEditableObject*) hardwareComponentAtLocation:(CGPoint) location;
-(void) tryAttachClotheObject: (THHardwareComponentEditableObject*) clotheObject;

//other hardware components
-(void) addOtherHardwareComponent:(THHardwareComponentEditableObject*) hardwareComponent;
-(void) removeOtherHardwareComponent:(THHardwareComponentEditableObject*) hardwareComponent;
-(THHardwareComponentEditableObject*) otherHardwareComponentAtLocation:(CGPoint) location;

//clothes
-(void) addClothe:(THClothe*) object;
-(void) removeClothe:(THClothe*) object;
-(THClothe*) clotheAtLocation:(CGPoint) location;

//condition
-(void) addCondition:(TFEditableObject*) condition;
-(void) removeCondition:(TFEditableObject*) condition;
-(TFEditableObject*) conditionAtLocation:(CGPoint) location;

//values
-(void) addValue:(TFEditableObject*) condition;
-(void) removeValue:(TFEditableObject*) condition;
-(TFEditableObject*) valueAtLocation:(CGPoint) location;

//triggers
-(void) addTrigger:(TFEditableObject*) trigger;
-(void) removeTrigger:(TFEditableObject*) trigger;
-(TFEditableObject*) triggerAtLocation:(CGPoint) location;

//actions
-(void) addAction:(TFEditableObject*) action;
-(void) removeAction:(TFEditableObject*) action;
-(TFEditableObject*) actionAtLocation:(CGPoint) location;

//wires
-(void) addWire:(THWire*) wire;
-(void) removeWire:(THWire*) wire;
-(void) addWireFrom:(THElementPinEditable*) elementPin to:(THBoardPinEditable*) boardPin;
-(void) removeAllWiresFrom:(id) object notify:(BOOL) notify;
-(void) removeAllWiresFromElementPin:(THElementPinEditable*) elementPin notify:(BOOL) notify;
-(TFEditableObject*) wireAtLocation:(CGPoint) location;

//invocation connections
-(NSArray*) invocationConnectionsForObject:(TFEditableObject*) object;
-(NSArray*) invocationConnectionsFrom:(TFEditableObject*) obj1 to:(TFEditableObject*) obj2;
-(void) addInvocationConnection:(THInvocationConnectionLine*) connection animated:(BOOL) animated;
-(void) removeInvocationConnection:(THInvocationConnectionLine*) connection;

-(void) removeAllInvocationConnectionsFrom:(id) object;
-(void) removeAllInvocationConnectionsTo:(id) object;
-(void) removeAllConnectionsFrom:(TFEditableObject*) obj1 to:(TFEditableObject*) obj2;

//non editable project
-(THClientProject*) nonEditableProject;

@property (nonatomic,readonly) THiPhoneEditableObject * iPhone;
@property (nonatomic,readonly) NSMutableArray * boards;
@property (nonatomic,readonly) NSMutableArray * hardwareComponents;
@property (nonatomic,readonly) NSMutableArray * otherHardwareComponents;
@property (nonatomic,readonly) NSMutableArray * clothes;
@property (nonatomic,readonly) NSMutableArray * iPhoneObjects;
@property (nonatomic,readonly) NSMutableArray * conditions;
@property (nonatomic,readonly) NSMutableArray * values;
@property (nonatomic,readonly) NSMutableArray * triggers;
@property (nonatomic,readonly) NSMutableArray * actions;
@property (nonatomic, readonly) NSMutableArray * wires;
@property (nonatomic, readonly) NSMutableArray * invocationConnections;

@property (nonatomic, readonly) NSArray * allObjects;
@property (nonatomic, readonly) NSMutableArray * eventActionPairs;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, readonly) BOOL isEmpty;

@property (nonatomic,readonly) THAssetCollection * assetCollection;

@end
