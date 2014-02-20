/*
THLilypadPropertiesPinView.m
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

#import "THLilypadPropertiesPinView.h"
#import "THBoardPin.h"
#import "THBoardPinEditable.h"
#import "THElementPinEditable.h"
#import "THHardwareComponentEditableObject.h"

@implementation THLilypadPropertiesPinView

CGSize const kLilypadPropertyLabelSize = {50, 30};
CGSize const kLilypadPropertyTypeLabelSize = {120, 30};
CGSize const kLilypadPropertySegmentedSize = {130, 30};

float const kLilypadPropertyInnerPadding = 5;

-(UILabel*) labelWithFrame:(CGRect) frame text:(NSString*) text{
    
    UILabel * modeLabel = [[UILabel alloc] initWithFrame:frame];
    modeLabel.backgroundColor = [UIColor clearColor];
    modeLabel.textColor = [UIColor whiteColor];
    modeLabel.text = text;
    modeLabel.font = [UIFont systemFontOfSize:13];
    return modeLabel;
}

-(void) setPin:(THBoardPinEditable *)pin{
    _pin = pin;
    
    THBoardPin * realPin = (THBoardPin*) pin.simulableObject;
    
    CGRect labelFrame = CGRectMake(kLilypadPropertyInnerPadding, kLilypadPropertyInnerPadding, kLilypadPropertyLabelSize.width, kLilypadPropertyLabelSize.height);
    UILabel * label = [[UILabel alloc] initWithFrame:labelFrame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13];
    NSString * pintype = [NSString stringWithFormat:@"%@ - ",kPinTexts[realPin.type]];
    label.text = [NSString stringWithFormat:@"%@ %d",pintype,realPin.number];
    [self addSubview:label];
    
    CGRect typeLabelFrame = CGRectMake(labelFrame.origin.x + labelFrame.size.width + kLilypadPropertyInnerPadding, 5, kLilypadPropertyTypeLabelSize.width, kLilypadPropertyTypeLabelSize.height);
    
    if(pin.type == kPintypeAnalog){
        _modeView = [self labelWithFrame:typeLabelFrame text:@"Analog input"];
        
    } else {
        
        if(pin.mode == kPinModeDigitalInput){
            _modeView = [self labelWithFrame:typeLabelFrame text:@"Digital input"];
        } else if(pin.isPWM){
            
            _segmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Digital", @"PWM", nil]];
            
            CGRect segmentedControlFrame = CGRectMake(typeLabelFrame.origin.x, kLilypadPropertyInnerPadding, kLilypadPropertySegmentedSize.width, kLilypadPropertySegmentedSize.height);
            _segmentedControl.frame = segmentedControlFrame;
            if(realPin.mode == kPinModeDigitalOutput){
                _segmentedControl.selectedSegmentIndex = 0;
            } else if(realPin.mode == kPinModePWM){
                _segmentedControl.selectedSegmentIndex = 1;
            }
            
            _modeView = _segmentedControl;
            
            [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:)
                        forControlEvents:UIControlEventValueChanged];
        }
    }
    
    [self addSubview:_modeView];
}

-(void) segmentedControlValueChanged:(UISegmentedControl*) control{
    THBoardPin * pin = (THBoardPin*) self.pin.simulableObject;
    if(control.selectedSegmentIndex == 0){
        pin.mode = kPinModeDigitalOutput;
    } else {
        //THElementPinEditable * elementPin = [pin.attachedElementPins objectAtIndex:0];
        pin.mode = kPinModePWM;
    }
    //NSLog(@"seting mode: %@",kPinModeTexts[pin.mode]);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1.0f;
        // Initialization code
        
    }
    return self;
}


@end
