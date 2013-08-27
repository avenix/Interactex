//
//  THCustomEditor.m
//  TangoHapps
//
//  Created by Juan Haladjian on 11/28/12.
//  Copyright (c) 2012 Technische Universität München. All rights reserved.
//

#import "THCustomEditor.h"
#import "THPinEditable.h"
#import "THHardwareComponentEditableObject.h"
#import "THLilypadEditable.h"
#import "THElementPinEditable.h"
#import "THBoardPinEditable.h"
#import "THClothe.h"
#import "THViewEditableObject.h"
#import "THiPhoneEditableObject.h"
#import "THiPhone.h"
#import "THConditionEditableObject.h"
#import "THResistorExtension.h"
#import "THLilypadEditable.h"
#import "THValueEditable.h"
#import "THTimerEditable.h"
#import "THActionEditable.h"
#import "THWire.h"

@implementation THCustomEditor

float const kEditorMinScale = 0.5f;
float const kEditorMaxScale = 2.5f;

-(id) init{
    
    self = [super init];
    if(self){
        _zoomableLayer = [CCLayer node];
        [self addChild:_zoomableLayer z:-1];
    }
    return self;
}

-(void) drawWires{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    
    for (THHardwareComponentEditableObject * lilypadObject in project.hardwareComponents) {
        [lilypadObject drawPinWires];
    }
}

-(void) drawObjectsConnections {
    
    [TFHelper drawLines:self.currentObject.connections];
    
    TFProject * project = [TFDirector sharedDirector].currentProject;
    
    if(self.state == kEditorStateConnect){
        [TFHelper drawLinesForObjects:project.allObjects];
    }
}

-(void) draw{
    
    if(self.isLilypadMode){
        
        [self drawWires];
        
    } else {
        
        [self drawObjectsConnections];
    }
    
    [super draw];
}

#pragma mark - Methods

//iphone object
-(void)addIphoneObject:(THViewEditableObject*) object{
    
    [object willStartEdition];
    [self addChild:object z:object.z];
}

-(void) removeiPhoneObject:(THViewEditableObject*) object{
    
    [object removeFromParentAndCleanup:YES];
}

-(THWireNode*) wireNodeAtPosition:(CGPoint) position fromComponent:(THHardwareComponentEditableObject*) object{
    
    for (THElementPinEditable * pin in object.pins) {
        
        for (THWire * wire in pin.wires) {
            THWireNode * node = [wire nodeAtPosition:position];
            if(node) return node;
        }
    }
    
    return nil;
}

-(THWireNode*) wireNodeAtPosition:(CGPoint) position{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THHardwareComponentEditableObject * hardwareComponent in project.hardwareComponents) {
        THWireNode * node = [self wireNodeAtPosition:position fromComponent:hardwareComponent];
        if(node) {
            return node;
        }
    }
    
    return nil;
}

-(TFEditableObject*) objectAtPosition:(CGPoint) position{
    
    TFProject * project = [TFDirector sharedDirector].currentProject;
    
    TFEditableObject * object;
    
    if(self.isLilypadMode){
        object = [self wireNodeAtPosition:position];
    }
    
    if(!object){
        object = [project objectAtLocation:position];
    }
    
    return object;
}

#pragma mark - Pin highlighting

-(void) highlightPin:(THPinEditable*) pin{
    
    if(_currentHighlightedPin != nil){
        _currentHighlightedPin.highlighted = NO;
    }
    _currentHighlightedPin = pin;
    _currentHighlightedPin.highlighted = YES;
}

-(void) dehighlightCurrentPin{
    
    _currentHighlightedPin.highlighted = NO;
    _currentHighlightedPin = nil;
}

#pragma mark - Object Selection

-(void) selectObject:(TFEditableObject*) editableObject{
    [self unselectCurrentObject];
    editableObject.selected = YES;
    self.currentObject = editableObject;
    
    if([editableObject isKindOfClass:[THWireNode class]]){
        
        THWireNode * node = (THWireNode*) editableObject;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationObjectSelected object:node.wire];
        
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationObjectSelected object:editableObject];
        
    }
}

#pragma mark - Connection
/*
-(void) handleNewConnectionMade:(NSNotification*) notification{
    
    TFConnectionLine * connection = notification.object;
    
    if([connection.obj2 isKindOfClass:[THBoardPinEditable class]]){
        
        connection.type = kConnectionType90Degrees;
        THBoardPinEditable * pin = (THBoardPinEditable*) connection.obj2;
        if(pin.type == kPintypeMinus){
            connection.color = kMinusPinColor;
        } else if(pin.type == kPintypePlus){
            connection.color = kPlusPinColor;
        }
    }
    
    [super handleNewConnectionMade:notification];
}*/

-(void) connectElementPinToLilypad:(THElementPinEditable*) objectPin at:(CGPoint) position{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    THLilyPadEditable * lilypad = project.lilypad;
    THBoardPinEditable * lilypadPin = [lilypad pinAtPosition:position];
    
    if([objectPin acceptsConnectionsTo:lilypadPin]){
        [lilypadPin attachPin:objectPin];
        [objectPin attachToPin:lilypadPin animated:YES];
    }
}

-(void)moveCurrentConnection:(CGPoint)position {
    
    self.currentConnection.p2 = position;
    if(self.isLilypadMode){
        
        THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
        
        if([project.lilypad testPoint:position]){
            
            THBoardPinEditable * pin = [project.lilypad pinAtPosition:position];
            if(pin != nil && [self.currentConnection.obj1 acceptsConnectionsTo:pin]){
                [self highlightPin:pin];
            } else {
                [self dehighlightCurrentPin];
            }
            
        } else {
            
            THHardwareComponentEditableObject * clotheObject = [project clotheObjectAtLocation:position];
            
            if(clotheObject){
                THElementPinEditable * pin = [clotheObject pinAtPosition:position];
                if(pin != nil && [self.currentConnection.obj1 acceptsConnectionsTo:pin]){
                    [self highlightPin:pin];
                } else {
                    [self dehighlightCurrentPin];
                }
            } else {
                [self dehighlightCurrentPin];
            }
        }
    }
}

-(void) handleConnectionEndedAt:(CGPoint) location{
    
    TFProject * project = [TFDirector sharedDirector].currentProject;
    TFEditableObject * object2 = [project objectAtLocation:location];
    TFEditableObject * object1 = self.currentConnection.obj1;

    if(self.isLilypadMode){
        if([object1 isKindOfClass:[THElementPinEditable class]]){
            THElementPinEditable * objectPin = (THElementPinEditable*) object1;
            if([object2 isKindOfClass:[THLilyPadEditable class]]){
                [self connectElementPinToLilypad:objectPin at:location];
            }
        } else if([object1 isKindOfClass:[THResistorExtension class]]){
            THResistorExtension * extension = (THResistorExtension*) object1;
            if([object2 isKindOfClass:[THLilyPadEditable class]]){
                THElementPinEditable * objectPin = extension.pin;
                [self connectElementPinToLilypad:objectPin at:location];
            }
        }
        
        [self dehighlightCurrentPin];
    } else{
        [super showMethodSelectionPopupFor:object1 and:object2];
    }
    
    [super handleConnectionEndedAt:location];
}

-(void) handleConnectionStartedAt:(CGPoint) location{
    TFProject * project = [TFDirector sharedDirector].currentProject;
    TFEditableObject * object = [project objectAtLocation:location];
    if(self.isLilypadMode){
        THHardwareComponentEditableObject * obj = (THHardwareComponentEditableObject*) object;
        
        if([obj isKindOfClass:[THHardwareComponentEditableObject class]]){
            THElementPinEditable * object1 = [obj pinAtPosition:location];
            
            if(object1 != nil){
                [self startNewConnectionForObject:object1];
            }
        }
    } else {
        if(object != nil && object.acceptsConnections){
            [self startNewConnectionForObject:object];
        }
    }
}

-(void) addEditableObject:(TFEditableObject*) editableObject{
    if(editableObject.zoomable){
        [_zoomableLayer addChild:editableObject z:editableObject.z];
    } else{
        [super addEditableObject:editableObject];
    }
}

-(void) moveCurrentObject:(CGPoint) d{
    
    if(self.currentObject.parent == _zoomableLayer){
        d = ccpMult(d, 1.0f/_zoomableLayer.scale);
    }
    
    [self.currentObject displaceBy:d];
}

-(void) moveLayer:(CGPoint) d{
    //if(_zoomableLayer.scale > 1){
        _zoomableLayer.position = ccpAdd(_zoomableLayer.position, d);
    //}
}

-(void)scale:(UIPinchGestureRecognizer*)sender{
    
    CGPoint location = [sender locationInView:sender.view];
    location = [self toLayerCoords:location];
    
    TFProject * project = [TFDirector sharedDirector].currentProject;
    TFEditableObject * object = [project objectAtLocation:location];
    
    if(object && [object isKindOfClass:[THClothe class]]){
        [object scaleBy:sender.scale];
    } else {
        float newScale = _zoomableLayer.scale * sender.scale;
        if(newScale > kEditorMinScale && newScale < kEditorMaxScale)
            _zoomableLayer.scale = newScale;
    }
    sender.scale = 1.0f;
}

/*
-(void) tapped:(UITapGestureRecognizer*)sender{
    
    CGPoint location = [sender locationInView:sender.view];
    location = [self toLayerCoords:location];
    
    TFEditableObject * object = [self objectAtLocation:location];
    
    if(self.state == kEditorStateDelete){
        [object removeFromWorld];
        [self unselectAllObjects];
    } else if(state == kEditorStateRemoveConnections){
        //[self removeActionFromToObject:object];
    } else {
        [self selectObject:object];
    }
}*/

-(void) checkPinClotheObject:(THHardwareComponentEditableObject*) clotheObject{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    THClothe * clothe = [project clotheAtLocation:clotheObject.position];
    if(clothe != nil){
        [project pinClotheObject:clotheObject toClothe:clothe];
        [[SimpleAudioEngine sharedEngine] playEffect:@"sewed.mp3"];
    }
}

-(void) checkUnPinClotheObject:(THHardwareComponentEditableObject*) clotheObject{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    THClothe * clothe = [project clotheAtLocation:clotheObject.position];
    if(clothe != nil){
        [project unpinClotheObject:clotheObject];
        [[SimpleAudioEngine sharedEngine] playEffect:@"sewed.mp3"];
    }
}

-(void) doubleTapped:(UITapGestureRecognizer*)sender{
    
    CGPoint location = [sender locationInView:sender.view];
    location = [self toLayerCoords:location];
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    THHardwareComponentEditableObject * clotheObject = [project clotheObjectAtLocation:location];
    if(clotheObject){
        if(clotheObject.pinned){
            [self checkUnPinClotheObject:clotheObject];
        } else {
            [self checkPinClotheObject:clotheObject];
        }
    } else {
        _zoomableLayer.scale = 1.0f;
        _zoomableLayer.position = ccp(0,0);
    }
    
    [super doubleTapped:sender];
}

#pragma mark - Lifecycle

-(void) addConditions{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THConditionEditableObject * object in project.conditions) {
        [object addToLayer:self];
    }
}

-(void) removeConditions{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THConditionEditableObject * object in project.conditions) {
        [object removeFromLayer:self];
    }
}

-(void) showConditions{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THConditionEditableObject * object in project.conditions) {
        object.visible = YES;
    }
}

-(void) hideConditions{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THConditionEditableObject * object in project.conditions) {
        object.visible = NO;
    }
}

-(void) showValues{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THValueEditable * object in project.values) {
        object.visible = YES;
    }
}

-(void) hideValues{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THValueEditable * object in project.values) {
        object.visible = NO;
    }
}

-(void) showTriggers{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THTriggerEditable * object in project.triggers) {
        object.visible = YES;
    }
}

-(void) hideTriggers{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THTriggerEditable * object in project.triggers) {
        object.visible = NO;
    }
}

-(void) showActions{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THActionEditable * object in project.actions) {
        object.visible = YES;
    }
}

-(void) hideActions{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THActionEditable * object in project.actions) {
        object.visible = NO;
    }
}


-(void) hideiPhone{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    project.iPhone.visible = NO;
}

-(void) showiPhone{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    project.iPhone.visible = YES;
}

/*
-(void) addValues{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (TFEditableObject * object in project.values) {
        [self addEditableObject:object];
    }
}

-(void) removeValues{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (TFEditableObject * object in project.values) {
        [object removeFromParentAndCleanup:YES];
    }
}
*/

-(void) addClothes{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (TFEditableObject * object in project.clothes) {
        [object addToLayer:self];
    }
}

-(void) removeClothes{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (TFEditableObject * object in project.clothes) {
        [object removeFromLayer:self];
    }
}

-(void) showClothes{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (TFEditableObject * object in project.clothes) {
        object.visible = YES;
    }
}


-(void) hideClothes{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (TFEditableObject * object in project.clothes) {
        object.visible = NO;
    }
}

-(void) addEditableObjects{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THHardwareComponentEditableObject * object in project.allObjects) {
        [object addToLayer:self];
    }
}

-(void) removeEditableObjects{
    //[self removeAllChildrenWithCleanup:YES];
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    for (THHardwareComponentEditableObject * object in project.allObjects) {
        [object removeFromLayer:self];
    }
    
    //[self removeiPhoneObjects];
}


#pragma mark - Lilypad Mode

-(void) addLilypadObjects{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    
    [self addEditableObject:project.lilypad];
}

-(void) removeLilypadObjects{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    
    if(project.lilypad != nil){
        [project.lilypad removeFromParentAndCleanup:YES];
    }
}

-(void) hideNonLilypadObjects{
    [self hideClothes];
    [self hideConditions];
    [self hideValues];
    [self hideTriggers];
    [self hideActions];
    [self hideiPhone];
}

-(void) showNonLilypadObjects{
    [self showClothes];
    [self showConditions];
    [self showValues];
    [self showTriggers];
    [self showActions];
    [self showiPhone];
}

-(void) startLilypadMode{
    
    self.isLilypadMode = YES;
    
    [self unselectCurrentObject];
    
    [self hideNonLilypadObjects];
    [self addLilypadObjects];
}

-(void) stopLilypadMode{
    
    self.isLilypadMode = NO;
    
    [self removeLilypadObjects];
    [self showNonLilypadObjects];
    
    [self unselectCurrentObject];
}

-(void) removeObjects{
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    [project.iPhone removeFromLayer:self];
    
    for (TFEditableObject * object in project.allObjects) {
        [object removeFromLayer:self];
    }
}

-(void) addiPhone{
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    if(project.iPhone != nil){
        [project.iPhone addToLayer:self];
    }
}

-(void) addObjects{
    TFProject * project = [TFDirector sharedDirector].currentProject;
    
    for (TFEditableObject * object in project.allObjects) {
        [object addToLayer:self];
    }
}

-(void) willAppear{
    [super willAppear];
    [self addiPhone];
    [self addObjects];
}

-(void) willDisappear{
    
    [super willDisappear];
    [self removeObjects];
}
@end
