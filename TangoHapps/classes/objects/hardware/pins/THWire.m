/*
THWire.m
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


#import "THWire.h"
#import "THWireProperties.h"
#import "THEditor.h"
#import "THElementPinEditable.h"
#import "THBoardPinEditable.h"

@implementation THWireNode

-(void) draw{
    
    ccDrawColor4B(kWireNodeColor.r, kWireNodeColor.g, kWireNodeColor.b, 255);
    ccDrawCircle(ccp(0,0), kWireNodeRadius, 0, 30, NO);
}

-(BOOL) testPoint:(CGPoint)point{
    CGPoint global = [self convertToWorldSpace:ccp(0,0)];
    return ccpDistance(global, point) < kWireNodeRadius;
}

@end

@implementation THWire

@synthesize p1 = _p1;
@synthesize p2 = _p2;

-(void) loadWire{
    
    self.z = kWireObjectZ;
    self.canBeScaled = YES;
}

-(id)initWithObj1:(THElementPinEditable*) obj1 obj2:(THBoardPinEditable*) obj2 {
    self = [super init];
    if (self) {
        
        [self loadWire];
        
        self.position = ccp(0,0);
        self.color = kConnectionLineDefaultColor;
        self.obj1 = obj1;
        self.obj2 = obj2;
        
        _nodes = [NSMutableArray array];
        
        [self addNodeInLongestEdge];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if(self){
        [self loadWire];
        
        self.obj1 = [decoder decodeObjectForKey:@"obj1"];
        self.obj2 = [decoder decodeObjectForKey:@"obj2"];
        self.p2 = [decoder decodeCGPointForKey:@"p2"];
        NSInteger red = [decoder decodeIntegerForKey:@"colorR"];
        NSInteger green = [decoder decodeIntegerForKey:@"colorG"];
        NSInteger blue = [decoder decodeIntegerForKey:@"colorB"];
        self.color = ccc3(red, green, blue);
        
        _nodes = [NSMutableArray array];
        NSArray * nodes = [decoder decodeObjectForKey:@"nodes"];
        
        for (THWireNode * node in nodes) {
            [self addNode:node];
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.obj1 forKey:@"obj1"];
    [coder encodeObject:self.obj2 forKey:@"obj2"];
    [coder encodeCGPoint:self.p2 forKey:@"p2"];
    [coder encodeInt:self.color.r forKey:@"colorR"];
    [coder encodeInt:self.color.g forKey:@"colorG"];
    [coder encodeInt:self.color.b forKey:@"colorB"];
    [coder encodeObject:self.nodes forKey:@"nodes"];
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    [controllers addObject:[THWireProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Drawing

-(void) startDrawingSelectedLines{
    
    float kColorHighlightIncreaseFactor = 1.20f;
    
    float r = MIN(255, self.color.r * kColorHighlightIncreaseFactor);
    float g = MIN(255, self.color.g * kColorHighlightIncreaseFactor);
    float b = MIN(255, self.color.b * kColorHighlightIncreaseFactor);
    
    ccDrawColor4B(r, g, b, 255);
    
    glLineWidth(kLineWidthSelected);
}

-(void) startDrawingNormalLines{
    
    ccDrawColor4B(self.color.r, self.color.g, self.color.b, 255);
    glLineWidth(kLineWidthNormal);
}

-(void) drawLineSegmentBetween:(CGPoint) p1 and:(CGPoint) p2{

     ccDrawLine(p1, p2);
}

-(void) drawLineSegments{
    
    CGPoint currentPoint = self.p1;
    CGPoint nextPoint = self.p2;
    
    if(self.nodes.count > 0){
        THWireNode * node = [self.nodes objectAtIndex:0];
        nextPoint = node.position;
    }
    
    [self drawLineSegmentBetween:currentPoint and:nextPoint];
    
    for (int i = 1; i < self.nodes.count; i++) {
        currentPoint = nextPoint;
        THWireNode * node = [self.nodes objectAtIndex:i];
        nextPoint = node.position;
        [self drawLineSegmentBetween:currentPoint and:nextPoint];
    }
    
    if(self.nodes.count > 0){
        [self drawLineSegmentBetween:nextPoint and:self.p2];
    }
}

-(void) draw{
    if(self.selected){
        [self startDrawingSelectedLines];
    } else {
        [self startDrawingNormalLines];
    }
    
    [self drawLineSegments];
    
    ccDrawCircle(self.p1, 3, 0, 5, NO);
    ccDrawCircle(self.p2, 3, 0, 5, NO);
    
    //ccDrawColor4F(1, 1, 1, 1);
}

#pragma mark - Properties

-(CGPoint)p1{
    if(self.obj1 == nil)
        return _p1;
    
    //THCustomEditor * editor = (THCustomEditor*) [THDirector sharedDirector].currentLayer;
    CGPoint pos = [self.obj1 convertToWorldSpace:ccp(0,0)];
    return [self convertToNodeSpace:pos];
}

-(CGPoint)p2{
    if(self.obj2 == nil)
        return _p2;
    
    //return self.obj2.position;
    
    //THCustomEditor * editor = (THCustomEditor*) [THDirector sharedDirector].currentLayer;
    CGPoint pos = [self.obj2 convertToWorldSpace:ccp(0,0)];
    return [self convertToNodeSpace:pos];
}

-(void) setP1:(CGPoint) pos{
    _p1 = pos;
}

-(void) setP2:(CGPoint) pos{
    _p2 = pos;
}

-(BOOL) canColorBeChanged{
    if(self.obj2.type == kPintypeMinus || self.obj2.type == kPintypePlus){
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Nodes

-(void) removeNodeObservers{
    for (THWireNode * node in self.nodes) {
        [node removeObserver:self forKeyPath:@"selected"];
    }
}

-(void) addNodeObservers{
    for (THWireNode * node in self.nodes) {
        [node addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void) setNodes:(NSMutableArray *)nodes{
    if(_nodes != nodes){
        if(_nodes){
            [self removeNodeObservers];
        }
        
        _nodes = nodes;
        
        [self addNodeObservers];
    }
}

-(NSInteger) findLongestSegment{
    float maxDist = 0;
    NSInteger maxDistIdx = -1;
    
    CGPoint previousNodePosition = self.p1;
    for (int i = 0; i < self.nodes.count; i++) {
        THWireNode * node = [self.nodes objectAtIndex:i];
        float distance = ccpDistance(node.position, previousNodePosition);
        if(distance > maxDist){
            maxDist = distance;
            maxDistIdx = i-1;
        }
        previousNodePosition = node.position;
    }
    
    float distance = ccpDistance(self.p2, previousNodePosition);
    if(distance > maxDist){
        maxDistIdx = self.nodes.count-1;
    }
    
    return maxDistIdx;
}

-(CGPoint) positionForNodeOrObjectAtIndex:(NSInteger) index{
    CGPoint p1;
    
    if(index < 0){
        p1 = [self.obj1 convertToWorldSpace:ccp(0,0)];
    } else if(index >= self.nodes.count){
        p1 = [self.obj2 convertToWorldSpace:ccp(0,0)];
    } else {
        THWireNode * node = [self.nodes objectAtIndex:index];
        p1 = [node convertToWorldSpace:ccp(0,0)];
    }
    return p1;
}

-(void) addNodeInLongestEdge{
    
    NSInteger index = [self findLongestSegment];
    
    CGPoint p1 = [self positionForNodeOrObjectAtIndex:index];
    CGPoint p2 = [self positionForNodeOrObjectAtIndex:index+1];
        
    THWireNode * node = [[THWireNode alloc] init];
    
    CGPoint position = ccp((p1.x + p2.x) / 2.0f, (p1.y + p2.y) / 2.0f);
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    
    node.position = [editor convertToNodeSpace:position];
    
    
    [self insertNode:node atIndex:index+1];
}

-(void) insertNode:(THWireNode*) node atIndex:(NSUInteger) index{
    [node addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    node.wire = self;
    [self addChild:node];
    [self.nodes insertObject:node atIndex:index];
}

-(void) addNode:(THWireNode*) node{
    [self insertNode:node atIndex:self.nodes.count];
}

-(void) removeNode:(THWireNode*) node{
    [node removeObserver:self forKeyPath:@"selected"];
    node.wire = nil;
    [self.nodes removeObject:node];
    [node removeFromParentAndCleanup:YES];
}

-(void) removeAllNodes{
    [self removeNodeObservers];
    for (THWireNode * node in self.nodes) {
        node.wire = nil;
    }
    [self.nodes removeAllObjects];
}

-(THWireNode*) nodeAtPosition:(CGPoint) position{
    for (THWireNode * node in self.nodes) {
        if([node testPoint:position]){
            return node;
        }
    }
    return nil;
}

#pragma mark - Layer

-(void) addToLayer:(TFLayer *)layer{
    [layer addEditableObject:self];
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    self.visible = editor.isLilypadMode;
}

-(void) removeFromLayer:(TFLayer *)layer{
    [layer removeEditableObject:self];
}

-(void) addToWorld{
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    [project addWire:self];
}

-(void) removeFromWorld{
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    [project removeWire:self];
    [super removeFromWorld];
}

#pragma mark - Node Observer

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"selected"]){
        THWireNode * node = object;
        self.selected = node.selected;
    }
}

#pragma mark - Other

-(NSString*) description{
    return @"Wire";
}

-(void) prepareToDie{

    [self removeAllNodes];
    [super prepareToDie];
    
}
@end
