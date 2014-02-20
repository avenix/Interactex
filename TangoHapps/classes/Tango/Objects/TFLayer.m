/*
TFLayer.m
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

#import "TFLayer.h"

#import "THProjectViewController.h"

@implementation TFLayer

//@synthesize lastAcceleration;

+(CCScene*) scene{
    CCScene * scene = [CCScene node];
    [scene addChild: [self node]];
    
    return scene;
}

-(id) init{
    self = [super init];
    if(self){
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;

        //_zoomableLayer.contentSize = self.contentSize;

        //[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0f/30.0f];
    }
    return self;
}

#pragma mark - Gesture Recognition

-(void)addGestureRecognizers
{
    UIView * glView = [CCDirector sharedDirector].view;
    
    // Pinch
    UIPinchGestureRecognizer *pinchRecognizer =
    [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    pinchRecognizer.cancelsTouchesInView = NO;
	[glView addGestureRecognizer:pinchRecognizer];
    
    // Rotate
    UIRotationGestureRecognizer *rotationRecognizer =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [rotationRecognizer setDelegate:self];
    rotationRecognizer.cancelsTouchesInView = NO;
	[glView addGestureRecognizer:rotationRecognizer];
    
    // Pan
    self.panRecognizer =
    [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [self.panRecognizer setDelegate:self];
	[self.panRecognizer setMinimumNumberOfTouches:1];
	[self.panRecognizer setMaximumNumberOfTouches:3];
    self.panRecognizer.cancelsTouchesInView = NO;
	[glView addGestureRecognizer:self.panRecognizer];
    
    // Tap
    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setDelegate:self];
	[tapRecognizer setNumberOfTapsRequired:1];
    tapRecognizer.cancelsTouchesInView = NO;
	[glView addGestureRecognizer:tapRecognizer];
    
    // Double Tap
    UITapGestureRecognizer *doubleTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    [doubleTapRecognizer setDelegate:self];
	[doubleTapRecognizer setNumberOfTapsRequired:2];
    doubleTapRecognizer.cancelsTouchesInView = NO;
	[glView addGestureRecognizer:doubleTapRecognizer];
    
    // Long Press
    UILongPressGestureRecognizer *longpressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
    [longpressRecognizer setDelegate:self];
    longpressRecognizer.cancelsTouchesInView = NO;
	[glView addGestureRecognizer:longpressRecognizer];
}

-(void) removeGestureRecognizers{
    UIView * glView = [CCDirector sharedDirector].view;
    glView.gestureRecognizers = nil;
}

//-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    //return ![THDirector sharedDirector].projectController.movingTabBar;
//}
/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    return YES;
}*/

-(void) scale:(UIPinchGestureRecognizer*)sender{}
-(void) rotate:(UIRotationGestureRecognizer*) sender{}
-(void) move:(UIPanGestureRecognizer*)sender{}
-(void) tapped:(UITapGestureRecognizer*)sender{}
-(void) doubleTapped:(UITapGestureRecognizer*)sender{}
-(void) pressedLong:(UILongPressGestureRecognizer*)sender{NSLog(@"pressed long");}

#pragma mark - Methods

-(void) addEditableObject:(TFEditableObject*) editableObject{
    
    [self addChild:editableObject z:editableObject.z];
}

-(void) removeEditableObject:(TFEditableObject*) editableObject{
    [editableObject removeFromParentAndCleanup:YES];
}

#pragma mark - Lifecycle

-(void) willDisappear{
    self.isAccelerometerEnabled = NO;
    [self removeGestureRecognizers];
}

-(void) willAppear{
    
    self.isAccelerometerEnabled = YES;
    [self addGestureRecognizers];
}

#pragma mark - Coordinates

- (CGPoint)toLayerCoords:(CGPoint)touchLocation {
	CGPoint newPos = [[CCDirector sharedDirector] convertToGL: touchLocation];
	newPos = [self convertToNodeSpace:newPos];
	return newPos;
}

-(void) prepareToDie{
    [self removeGestureRecognizers];
}

-(void) dealloc{
}

@end
