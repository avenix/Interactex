/*
THProjectViewController.h
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
#import "TFConstants.h"

@class TFProject;
@class TFLayer;
@class THPalette;
@class THTabbarViewController;
@class THEditorToolsViewController;

@interface THProjectViewController : UIViewController<UIGestureRecognizerDelegate, UITextFieldDelegate, CCDirectorDelegate> {
    
    UIBarButtonItem * _playButton;
    UIBarButtonItem * _stopButton;
    
    NSString * _currentProjectName;
    
    CGPoint lastEditorZoomableLayerPosition;
    float lastEditorZoom;
}

@property (nonatomic, readonly) TFLayer * currentLayer;
@property (nonatomic, readonly) CCScene * currentScene;
@property (nonatomic, readonly) CCGLView * glview;
@property (nonatomic, readonly) TFAppState state;
@property (nonatomic, readonly) THTabbarViewController * tabController;
@property (nonatomic, readonly) THEditorToolsViewController * toolsController;
@property (nonatomic, strong) UIPanGestureRecognizer * panRecognizer;

@property (nonatomic, readonly) BOOL editingSceneName;
@property (nonatomic) BOOL movingTabBar;
@property (nonatomic, strong) UIImageView * palettePullImageView;

@property (strong, nonatomic) NSArray * editingTools;
@property (strong, nonatomic) NSArray * simulatingTools;
@property (strong, nonatomic) NSArray * lilypadTools;

//edition tools
@property (strong, nonatomic) UIBarButtonItem * connectButton;
@property (strong, nonatomic) UIBarButtonItem * duplicateButton;
@property (strong, nonatomic) UIBarButtonItem * removeButton;
@property (strong, nonatomic) UIBarButtonItem * pushButton;
@property (strong, nonatomic) UIBarButtonItem * playButton;

//lilypad tools
@property (strong, nonatomic) UIBarButtonItem * lilypadButton;
@property (strong, nonatomic) UIBarButtonItem * hideiPhoneButton;

//simulation tools
@property (strong, nonatomic) UIBarButtonItem * pinsModeButton;
@property (strong, nonatomic) UIBarButtonItem * stopButton;

//other tools
@property (strong, nonatomic) UIBarButtonItem * divider;
@property (strong, nonatomic) UIBarButtonItem * divider2;
@property (strong, nonatomic) UIBarButtonItem * emptyItem1;
@property (strong, nonatomic) UIBarButtonItem * emptyItem2;

//tool colors
@property (strong, nonatomic) UIColor * highlightedItemTintColor;
@property (strong, nonatomic) UIColor * unselectedTintColor;

-(void) startWithEditor;
-(void) startSimulation;
-(void) endSimulation;
-(void) toggleAppState;
-(void) reloadContent;
-(void) saveCurrentProjectAndPalette;
-(void) updatePushButtonState;

@end