/*
TFConstants.h
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
#import <UIKit/UIKit.h>

extern NSString * const kNotificationActionAdded;
extern NSString * const kNotificationActionRemoved;

extern float const kTabWidth;

extern float const kPaletteSectionPadding;
extern float const kPaletteSectionWidth;

extern float const kGridItemWidth;
extern float const kGridItemHeight;
extern float const kLineAcceptedTiltingTime;

extern NSString * const kNotificationObjectAdded;
extern NSString * const kNotificationObjectRemoved;
extern NSString * const kNotificationObjectSelected;
extern NSString * const kNotificationObjectDeselected;
extern NSString * const kNotificationPaletteItemSelected;
extern NSString * const kNotificationPaletteItemDeselected;
extern NSString * const kNotificationConnectionMade;
extern NSString * const kConnectionMadeEffect;
extern NSString * const kNotificationInvocationCompleted;

extern float kPaletteItemsPadding;
extern float kPaletteItemSize;
extern CGSize const kPaletteItemImageSize;
extern CGSize const kPaletteItemLabelSize;

extern float const kPaletteLabelHeight;

extern float const kPaletteItemImagePadding;

extern float const kPaletteContainerTitleHeight;

extern ccColor4F const kSelectionPopupsDefaultColor;
extern ccColor3B const kConnectionLineDefaultColor;
extern ccColor4B const kDefaultObjectHighlightColor;
extern ccColor4B const kDefaultObjectSelectionColor;

extern float const kLineAcceptedShinningTime;
extern float const kLineWidthNormal;
extern float const kLineWidthSelected;

extern float const kDragViewDefaultOpacity;

extern float const kNavigationBarHeight;


extern float const kMethodSelectionPopupRowHeight;
extern float const kMethodSelectionPopupCharacterWidth;

extern float const kMethodSelectionMinWidth;
extern float const kMethodSelectionMaxWidth;

extern float const kPopupHeaderHeight;


extern NSInteger const kEditableObjectTableRowHeight;
extern NSString * const kEditableObjectTableFont;
extern float const kEditableObjectTableFontSize;


typedef enum {
    kAppStateEditor,
    kAppStateSimulator
} TFAppState;

extern NSString * const kNotificationStartRemovingConnections;
extern NSString * const kNotificationStopRemovingConnections;