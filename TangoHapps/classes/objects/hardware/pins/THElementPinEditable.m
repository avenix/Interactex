//
//  THElementPinEditable.m
//  TangoHapps
//
//  Created by Juan Haladjian on 10/14/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "THElementPinEditable.h"
#import "THPinEditable.h"
#import "THLilypadEditable.h"
#import "THElementPin.h"
#import "THBoardPinEditable.h"
#import "THClotheObjectEditableObject.h"

@implementation THElementPinEditable

@dynamic type;
@dynamic connected;

-(void) load{
    self.acceptsConnections = YES;
}

-(id) init{
    self = [super init];
    if(self){
        [self load];
    }
    return self;
}


#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    _attachedToPin = [decoder decodeObjectForKey:@"attachedToPin"];
    
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:_attachedToPin forKey:@"attachedToPin"];
}

#pragma mark - Connectable

-(BOOL) acceptsConnectionsTo:(id)anObject{
    if([anObject isKindOfClass:[THLilyPadEditable class]] || [anObject isKindOfClass:[THClotheObjectEditableObject class]]){
        return YES;
    }
    
    if([anObject isKindOfClass:[THBoardPinEditable class]]){
        THBoardPinEditable * pin = anObject;
        
        if(((pin.type == kPintypeDigital && self.type == kElementPintypeDigital))
           || (pin.type == kPintypeAnalog && self.type == kElementPintypeAnalog)
           || (pin.type == kPintypeMinus && self.type == kElementPintypeMinus)
           || (pin.type == kPintypePlus && self.type == kElementPintypePlus)
           || (self.type == kElementPintypeScl && pin.type == kPintypeAnalog && pin.number == 5)
           || (self.type == kElementPintypeSda && pin.type == kPintypeAnalog && pin.number == 4)){
            return YES;
        }
    } /*else if([anObject isKindOfClass:[THElementPinEditable class]]){
        THElementPinEditable * pin = anObject;
        if(pin.type == kElementPintypePlus && self.type == kElementPintypeMinus){
            return YES;
        }
    }*/
    
    return NO;
}

-(void) handleLilypadRemoved:(NSNotification*) notification{
    
    TFEditableObject * object = notification.object;
    [self removeAllConnectionsTo:object];
}

-(void) registerNotificationsFor:(TFEditableObject*) object{
    if([object isKindOfClass:[THLilyPadEditable class]]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLilypadRemoved:) name:kNotificationLilypadRemoved object:object];
    }
}

#pragma mark - Methods

-(THPinMode) defaultBoardPinMode{
    THElementPin * pin = (THElementPin*) self.simulableObject;
    return pin.defaultBoardPinMode;
}

-(void) setAttachedToPin:(THBoardPinEditable *)attachedToPin{
    _attachedToPin = attachedToPin;
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    [pin attachToPin:(THBoardPin*) attachedToPin.simulableObject];
}

-(BOOL) connected{
    return self.attachedToPin != nil;
}

-(THElementPinType) type{
    THElementPin * pin = (THElementPin*) self.simulableObject;
    return pin.type;
}

-(void) setType:(THElementPinType)type{
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    pin.type = type;
}

-(CGPoint) center{
    return [self convertToWorldSpace:ccp(0,0)];
}

-(void) draw{
    
    //ccDrawCircle(ccp(0,0), kLilypadPinRadius, 0, 15, 0);
    
    if(self.highlighted){
        glLineWidth(2);
        if(self.attachedToPin){
            glColor4f(0.82, 0.58, 0.58, 1.0);
        } else {
            glColor4f(0.12, 0.58, 0.84, 1.0);
        }
        
        ccDrawCircle(ccp(0,0), kLilypadPinRadius, 0, 15, 0);
        
        glLineWidth(1);
        glColor4ub(255,255,255,255);
    }
    
    
    if(self.state == kElementPinStateProblem){
        glLineWidth(2);
        glColor4f(0.82, 0.58, 0.58, 1.0);
        
        ccDrawCircle(ccp(0,0), kLilypadPinRadius, 0, 15, 0);
        
        glLineWidth(1);
        glColor4ub(255,255,255,255);
    }
}

-(void) attachToPin:(THBoardPinEditable*) pinEditable animated:(BOOL) animated{
    if(_attachedToPin != nil){
        [_attachedToPin deattachPin:self];
    }
    
    _attachedToPin = pinEditable;
    [self addConnectionTo:_attachedToPin animated:animated];
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    [pin attachToPin:(THBoardPin*) pinEditable.simulableObject];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPinAttached object:self];
}

-(void) deattach{
    [self removeAllConnectionsTo:_attachedToPin];
    
    _attachedToPin = nil;
    
    THElementPin * pin = (THElementPin*) self.simulableObject;
    [pin deattach];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPinDeattached object:self];
}

-(NSString*) shortDescription{
    THElementPin * pin = (THElementPin*) self.simulableObject;
    return pin.shortDescription;
}

-(NSString*) description{
    return self.simulableObject.description;
}

-(void) prepareToDie{
    [self.attachedToPin deattachPin:self];
    [super prepareToDie];
}

@end