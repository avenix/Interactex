/*
TFConstants.m
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

#import "TFConstants.h"

float const kTabWidth = 215;

float const kPaletteSectionPadding = 5;
float const kPaletteSectionWidth = 215;

float const kGridItemWidth = 200;
float const kGridItemHeight = 230;

float const kLineAcceptedTiltingTime = 0.35f;

NSString * const kNotificationActionAdded = @"notificationActionAdded";
NSString * const kNotificationActionRemoved = @"notificationActionRemoved";
NSString * const kNotificationObjectAdded = @"notificationEntityAdded";
NSString * const kNotificationObjectRemoved = @"notificationEntityRemoved";
NSString * const kNotificationObjectSelected = @"notificationObjectSelected";
NSString * const kNotificationObjectDeselected = @"notificationObjectDeselected";
NSString * const kNotificationPaletteItemSelected = @"notificationPaletteItemSelected";
NSString * const kNotificationPaletteItemDeselected = @"notificationPaletteItemDeselected";
NSString * const kNotificationInvocationCompleted = @"notificationInvocationCompleted";
NSString * const kNotificationConnectionMade = @"notificationConnectionMade";
NSString * const kConnectionMadeEffect = @"connectionMade.mp3";

float kPaletteItemsPadding = 8;
float kPaletteItemSize = 60;
CGSize const kPaletteItemImageSize = {45,45};
//CGSize const kPaletteItemLabelSize = {58,10};
CGSize const kPaletteItemLabelSize = {58,25};

float const kPaletteLabelHeight = 14;
float const kPaletteItemImagePadding = 3;

float const kPaletteContainerTitleHeight = 40;

ccColor4F const kSelectionPopupsDefaultColor = {0.11, 0.58, 0.83,1};

ccColor3B const kConnectionLineDefaultColor = {30, 148, 214};
ccColor4B const kDefaultObjectHighlightColor = {200, 150, 150, 100};
ccColor4B const kDefaultObjectSelectionColor = {180, 180, 200, 15};

float const kLineAcceptedShinningTime = 0.9f;

float const kLineWidthNormal = 1.0f;
float const kLineWidthSelected = 2.0f;

float const kDragViewDefaultOpacity = 0.8f;

float const kNavigationBarHeight = 44;


float const kMethodSelectionPopupRowHeight = 30;
float const kMethodSelectionPopupCharacterWidth = 13;

float const kMethodSelectionMinWidth = 110;
float const kMethodSelectionMaxWidth = 200;

float const kPopupHeaderHeight = 25;

NSInteger const kEditableObjectTableRowHeight = 30;
NSString * const kEditableObjectTableFont = @"Arial";
float const kEditableObjectTableFontSize = 13;


NSString * const kNotificationStartRemovingConnections = @"notificationStartRemovingConnections";
NSString * const kNotificationStopRemovingConnections = @"notificationStopRemovingConnections";

