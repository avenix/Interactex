/*
THClientConstants.h
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


#define kNumDataTypes 5

typedef enum{
    kDataTypeBoolean,
    kDataTypeInteger,
    kDataTypeFloat,
    kDataTypeString,
    kDataTypeAny
} TFDataType;

typedef enum {
    kDigitalPinValueLow = 0,
    kDigitalPinValueHigh = 1
} THDigitalPinValue ;

#define kNumHardwareTypes 12
#define kMaxNumPinsPerElement 5

typedef enum{
    kHardwareTypeLed,
    kHardwareTypeBuzzer,
    kHardwareTypeButton,
    kHardwareTypeSwitch,
    kHardwareTypePotentiometer,//5
    kHardwareTypeLightSensor,
    kHardwareTypeLSMCompass,
    kHardwareTypeThreeColorLed,
    kHardwareTypeVibeBoard,
    kHardwareTypeTemperatureSensor,//10
    kHardwareTypeAccelerometer,
    kHardwareTypeMPUCompass,
    kHardwareTypeLipoBattery
}THHardwareType;

#define kNumPinTypes 4

typedef enum{
    kPintypeDigital,
    kPintypeAnalog,
    kPintypeMinus,
    kPintypePlus,
} THPinType;


#define kNumPinModes 7
/*
typedef enum{
    kPinModeDigitalInput = 0,
    kPinModeDigitalOutput = 1,
    kPinModeAnalogInput = 2,
    kPinModePWM = 3,
    kPinModeBuzzer = 4,
    kPinModeCompass = 5,
    kPinModeUndefined = 6
} THPinMode;*/

typedef enum{
    kPinModeDigitalInput = 0x00,
    kPinModeDigitalOutput,
    kPinModeAnalogInput,
    kPinModePWM ,
    kPinModeServo,
    kPinModeShift,
    kPinModeI2C,
    kPinModeUndefined
} THPinMode;


#define kNumElementPinTypes 6
typedef enum{
    kElementPintypeDigital,
    kElementPintypeAnalog,
    kElementPintypePlus,
    kElementPintypeMinus,
    kElementPintypeScl,
    kElementPintypeSda
} THElementPinType;


typedef struct{
    THElementPinType type;
    CGPoint position;
    
} THPinDescriptor;



#define kNumiPhoneTypes 2

typedef enum{
    kiPhoneType4S,
    kiPhoneType5
} THIPhoneType;

extern CGRect const kiPhoneFrames[kNumiPhoneTypes];

typedef enum{
    kI2CComponentTypeLSM,
    kI2CComponentTypeMCU
    
}THI2CComponentType;

//notifications
extern NSString * const kNotificationLedOn;
extern NSString * const kNotificationLedOff;

extern NSString * const kNotificationBuzzerOn;
extern NSString * const kNotificationBuzzerOff;

extern NSString * const kNotificationBuzzerFrequencyChanged;
extern NSString * const kNotificationLedIntensityChanged;
extern NSString * const kNotificationPinValueChanged;

extern NSString * const kNotificationSwitchOn;
extern NSString * const kNotificationSwitchOff;


extern NSString * const kNotificationLilypadObjectAdded;
extern NSString * const kNotificationLilypadObjectRemoved;

extern NSString * const kNotificationLilypadAdded;
extern NSString * const kNotificationLilypadRemoved;

extern NSString * const kNotificationPinAttached;
extern NSString * const kNotificationPinDeattached;

//events
extern NSString * const kEventTurnedOn;
extern NSString * const kEventTurnedOff;
extern NSString * const kEventOnChanged;
extern NSString * const kEventIntensityChanged;
extern NSString * const kEventFrequencyChanged;
extern NSString * const kEventValueChanged;
extern NSString * const kEventMapperValueChanged;
extern NSString * const kEventDxChanged;
extern NSString * const kEventDyChanged;
extern NSString * const kEventLightChanged;
extern NSString * const kEventStartedPressing;
extern NSString * const kEventStoppedPressing;
extern NSString * const kEventConditionIsTrue;
extern NSString * const kEventConditionIsFalse;
extern NSString * const kEventConditionChanged;
extern NSString * const kEventXChanged;
extern NSString * const kEventYChanged;
extern NSString * const kEventZChanged;
extern NSString * const kEventHeadingChanged;
extern NSString * const kEventTapped;
extern NSString * const kEventDoubleTapped;
extern NSString * const kEventScaleChanged;
extern NSString * const kEventLongPressed;
extern NSString * const kEventColorChanged;
extern NSString * const kEventTriggered;

//methods
extern NSString * const kMethodTurnOn;
extern NSString * const kMethodTurnOff;
extern NSString * const kMethodSetValue1;
extern NSString * const kMethodSetValue2;
extern NSString * const kMethodSetRed;
extern NSString * const kMethodSetGreen;
extern NSString * const kMethodSetBlue;

#define kMaxNumNotifyBehaviors 3

typedef enum {
    kSensorNotifyBehaviorAlways,
    kSensorNotifyBehaviorWhenInRange,
    kSensorNotifyBehaviorOncePerPeak,
} THSensorNotifyBehavior;


extern NSString * const kGameKitSessionId;


extern NSString * const dataTypeStrings[kNumDataTypes];
extern NSInteger const kNumPinsPerElement[kNumHardwareTypes];


extern NSString* const kPinTexts[kNumPinTypes];
extern NSString* const kPinModeTexts[kNumPinModes];
extern NSString* const kElementPinTexts[kNumElementPinTypes];

extern NSString * const kPaletteItemsDirectory;
extern NSString * const kProjectsDirectory;
extern NSString * const kPresetsDirectory;

extern NSString * const kProjectImagesDirectory;
extern NSString * const kProjectProxiesFileName;

extern float const kMaxAnalogValue;


extern float const kBuzzerMaxFrequency;
extern float const kBuzzerMinFrequency;


#define kLilypadNumPwmPins 6

extern NSInteger const kLilypadPwmPins[kLilypadNumPwmPins];

extern float const kGraphViewGraphOffsetY;
extern CGSize const kGraphViewAxisLabelSize;
extern float const kGraphViewAxisLineWidth;
