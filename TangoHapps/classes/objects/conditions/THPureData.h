//
//  THPureData.h
//  TangoHapps
//
//  Created by Juan Haladjian on 4/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudioController.h"
#import "PdBase.h"
#import "PdDispatcher.h"

@interface THPureData : TFAction
{
}

@property (nonatomic) BOOL on;
@property (nonatomic) NSInteger variable1;
@property (nonatomic) NSInteger variable2;

-(void) turnOn;
-(void) turnOff;

@property (strong, nonatomic, readonly) PdAudioController *audioController;
@property (nonatomic) PdDispatcher *dispatcher;

@end
