//
//  THPinViewCell.m
//  TangoHapps
//
//  Created by Juan Haladjian on 16/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THBoardPropertiesPinCell.h"
#import "THBoardPinEditable.h"

@implementation THBoardPropertiesPinCell

#pragma mark - properties

CGSize const frameSize = {215,44};
CGSize const segmentSize = {105,29};
CGSize const pinLabelSize = {54,21};
CGSize const infoLabelSize = {105,21};
CGPoint const offset = {40,10};

-(id) init {
    self = [super init];
    if(self) {
        
        self.frame = CGRectMake(0, 0, frameSize.width, frameSize.height);
        
        UIFont * font = [UIFont systemFontOfSize:14];
        
        CGRect frame = CGRectMake(offset.x, (frameSize.height - pinLabelSize.height) / 2, pinLabelSize.width, pinLabelSize.height);
        self.pinLabel = [[UILabel alloc] initWithFrame:frame];
        self.pinLabel.font = font;
        [self addSubview:self.pinLabel];
        
        frame = CGRectMake(self.pinLabel.frame.origin.x + self.pinLabel.frame.size.width + 5, (frameSize.height - infoLabelSize.height ) / 2, infoLabelSize.width, infoLabelSize.height);
        self.pinInfoLabel = [[UILabel alloc] initWithFrame:frame];
        self.pinInfoLabel.font = font;
        [self addSubview:self.pinInfoLabel];
        
        frame = CGRectMake(self.pinLabel.frame.origin.x + self.pinLabel.frame.size.width + 5, (frameSize.height - segmentSize.height) / 2, segmentSize.width, segmentSize.height);
        self.pwmControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Digital", @"PWM", nil]];
        self.pwmControl.frame = frame;
        [self.pwmControl addTarget:self action:@selector(pwmControlChanged:) forControlEvents:UIControlEventValueChanged];
        self.pwmControl.hidden = YES;
        [self addSubview:self.pwmControl];
    }
    return self;
}

-(void) setBoardPin:(THBoardPinEditable *)boardPin {
    
    if(boardPin != _boardPin){
        _boardPin = boardPin;
        
        [self reloadUI];
    }
}

-(void) reloadUI {
    
    self.pinLabel.text = [NSString stringWithFormat:@"PIN %d - ",self.boardPin.number];
    NSString * pintype = [NSString stringWithFormat:@"%@",kPinTexts[self.boardPin.type]];
    self.pinInfoLabel.text = pintype;
    
    if(self.boardPin.type == kPintypeAnalog){
        if(self.boardPin.supportsSCL && self.boardPin.mode == kPinModeI2C){
            self.pinInfoLabel.text = @"SCL";
        } else if(self.boardPin.supportsSDA && self.boardPin.mode == kPinModeI2C){
            self.pinInfoLabel.text = @"SDA";
        } else {
            self.pinInfoLabel.text = @"Analog input";
        }
    } else {
        self.pinInfoLabel.text = @"Digital input";
    }
    
    if(self.boardPin.isPWM){
        self.pwmControl.selectedSegmentIndex = (self.boardPin.mode == kPinModePWM);
        self.pwmControl.hidden = NO;
        self.pinInfoLabel.hidden = YES;
    } else {
        self.pwmControl.hidden = YES;
        self.pinInfoLabel.hidden = NO;
    }
}

#pragma mark - UI interaction

- (void)pwmControlChanged:(id)sender {
    BOOL pwm = (self.pwmControl.selectedSegmentIndex == 1);
    [self.delegate pinViewCell:self didChangePwmStateTo:pwm];
}

@end
