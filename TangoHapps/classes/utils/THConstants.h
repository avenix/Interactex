/*
THConstants.h
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

#define PTM_RATIO 32.0f

#define BACKGROUND_Z -1
#define PALETTE_ITEM_Z 1

#define OBJECT_Z 3
#define JOINT_Z 6
#define REMOVE_OBJ_IMG_Z 7
#define ADD_OBJ_IMG_Z 7
#define RED_DOT_Z 10
#define MOVE_TARGET_Z 15

#define PALETTE_RECTANGLE 0
#define PALETTE_CIRCLE 1

#define PALETTE_X_MARGIN 4
#define PALETTE_Y_MARGIN 4

#define PALETTE_LABEL_HEIGHT 14

#define SIDEBAR_WIDTH 250
#define SIDEBAR_PADDING 8
#define INIT_OBJECT_SIZE 40

#define OBJ_ACCELERATION 100000

#define THUMBNAIL_WIDTH 75
#define THUMBNAIL_HEIGHT 75
#define THUMBNAIL_MARGIN 10

#define MIN_DRAGGED_DISTANCE 150

#define TAB_ALPHA 1.0f

#define MIN_SHAPE_SIZE 5
#define MAX_SHAPE_SIZE 150

#define MIN_SCALE 1.0
#define MAX_SCALE 2.0

#define PALETTE_ITEMS_PADDING 8
#define PALETTE_ITEMS_SIZE 64
#define DRAGGED_IMAGE_SHIFT 40

#define FINGER_LENGTH 25

#define ROPE_NUM_PARTS 10

#define ROPE_HEIGHT 16
#define ROPE_WIDTH 8

#define MAX_PALETTE_IMAGE_SIZE 85
#define MIN_PALETTE_IMAGE_SIZE 44

#define SPRITE_OPACITY_EDITOR_ACTIVE 180
#define SPRITE_OPACITY_EDITOR_INACTIVE 100
#define SPRITE_OPACITY_SIMULATOR 255
#define BACKGROUND_OPACITY 60

#define VELOCITY_ITERATIONS 10
#define POSITION_ITERATIONS 10

#define SWITCH_TIME 2.0f
#define REMOVE_CUTTED_ROPE_TIME 1.5f

#define INITIAL_TRIGGER_AREA 100

enum zPositions{
    kYannicZ = -30,
    kLilypadZ = -25,
    kDefaultZ = -20,
    kClotheZ = -20,
    kClotheObjectZ = -10,
    kValueZ = -9,
    kConditionZ = -8,
    kNormalObjectZ = -7,
    kiPhoneZ = -6,
    kWireObjectZ = -5,
    kSelectedObjectZ = -4,
    kSelectionSpriteZ = 2
};

//#define ARC4RANDOM_MAX      0x10000000
#define ARC4RANDOM_MAX 0xFFFFFFFFu

extern NSString * const kNotificationPropertyValueChanged;
extern NSString * const kNotificationSimulationStarted;
extern NSString * const kNotificationSimulationEnded;

extern NSString * const kNotificationPropertiesChanged;


extern float const kWifiCellHeightCollapsed;
extern float const kWifiCellHeightExtended;

extern CGPoint const kiPhoneImageDistanceViewTopLeftToCenter;

extern float const kLilypadPinRadius;

extern CGPoint const kLilypadDefaultPosition;

extern NSString * const kPaletteNameClothes;
extern NSString * const kPaletteNameSoftware;
extern NSString * const kPaletteNameHardware;
extern NSString * const kPaletteNameTriggers;


extern CGPoint const kPinPositions[kNumHardwareTypes][kMaxNumPinsPerElement];


extern float const kUiViewOpacityEditor;

typedef enum {
    kImageViewScaleModeFit,
    kImageViewScaleModeFill
} THImageViewScaleMode;


NSString * kNotifyBehaviorsText[kMaxNumNotifyBehaviors];

extern NSInteger const kCompassMin;
extern NSInteger const kAnalogInMin;

extern NSString * kSimulatorDefaultBoldFont;
extern NSString * kSimulatorDefaultFont;
extern CGSize const kDefaultViewMinSize;
extern CGSize const kDefaultViewMaxSize;

extern ccColor3B const kMinusPinColor;
extern ccColor3B const kPlusPinColor;
extern ccColor3B const kOtherPinColor;

extern ccColor4B const kMinusPinHighlightColor;
extern ccColor4B const kPlusPinHighlightColor;
extern ccColor4B const kDefaultPinHighlightColor;

extern ccColor3B const kWireDefaultColor;
extern ccColor3B const kWireDefaultHighlightColor;

extern float const kWireNodeRadius;
extern ccColor3B const kWireNodeColor;

extern CGSize const kDefaultPinSize;
extern CGSize const kiPhoneButtonDefaultSize;

extern CGPoint const kDefaultiPhonePosition;

extern CGPoint const kSewedPositions[kNumHardwareTypes];


extern float const kLayerMinScale;
extern float const kLayerMaxScale;
