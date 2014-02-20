//
//  THPureData.m
//  TangoHapps
//
//  Created by Martijn ten Bhömer based on code from Juan Haladjian on 5/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "THPureData.h"

@implementation THPureData

//I don't know exactly what this synthesize line here is used for, it's taken from here:
//http://createdigitalmusic.com/files/2012/03/MakingMusicalAppsExcerpt.pdf
@synthesize audioController = audioController_;

-(id) init {
    self = [super init];
    if(self){
        
        self.variable1 = 255;
        self.variable2 = 255;
        
        [self loadPureData];
    }
    return self;
}

-(void) loadPureData {
    
    TFProperty * property1 = [TFProperty propertyWithName:@"on" andType:kDataTypeBoolean];
    TFProperty * property2 = [TFProperty propertyWithName:@"variable1" andType:kDataTypeInteger];
    TFProperty * property3 = [TFProperty propertyWithName:@"variable2" andType:kDataTypeInteger];

    self.properties = [NSMutableArray arrayWithObjects:property1,property2,property3,nil];
    
    TFMethod * method1 =[TFMethod methodWithName:@"setVariable1"];
    method1.numParams = 1;
    method1.firstParamType = kDataTypeInteger;
    
    TFMethod * method2 =[TFMethod methodWithName:@"setVariable2"];
    method2.numParams = 1;
    method2.firstParamType = kDataTypeInteger;
    
    TFMethod * method3 = [TFMethod methodWithName:kMethodTurnOn];
    TFMethod * method4 = [TFMethod methodWithName:kMethodTurnOff];
    
    self.methods = [NSMutableArray arrayWithObjects:method1,method2,method3,method4,nil];

    //start pure data library
    //[self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 mixingEnabled:YES];
    audioController_ = [[PdAudioController alloc] init];
    if ([self.audioController configurePlaybackWithSampleRate:44100 numberChannels:2 inputEnabled:NO mixingEnabled:NO] != PdAudioOK) {
        NSLog(@"failed to initialize pureData audio components");
    }
    self.dispatcher = [[PdDispatcher alloc] init];
	[PdBase openFile:@"synthesis.pd" path:[[NSBundle mainBundle] resourcePath]];
   
	//[self.audioController print];

    /*
    TFEvent * event0 = [TFEvent eventNamed:kEventOnChanged];
    event0.param1 = [TFPropertyInvocation invocationWithProperty:property1 target:self];
    TFEvent * event1 = [TFEvent eventNamed:kEventIntensityChanged];
    event1.param1 = [TFPropertyInvocation invocationWithProperty:property2 target:self];

    self.events = [NSArray arrayWithObjects:event0,event1,nil];
     */
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        self.variable1 = [decoder decodeIntegerForKey:@"variable1"];
        self.variable2 = [decoder decodeIntegerForKey:@"variable2"];
        [self loadPureData];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeInteger:self.variable1 forKey:@"variable1"];
    [coder encodeInteger:self.variable2 forKey:@"variable2"];
    
    [self loadPureData];
}

-(id)copyWithZone:(NSZone *)zone {
    THPureData * copy = [super copyWithZone:zone];
    
    copy.variable1 = self.variable1;
    copy.variable2 = self.variable2;
    
    return copy;
}

#pragma mark - Methods

-(void) setVariable1:(NSInteger)var1 {
    
    _variable1 = var1;
    [PdBase sendFloat:_variable1 toReceiver: @"left" ];
}

-(void) setVariable2:(NSInteger)var2 {
    
    _variable2 = var2;
    [PdBase sendFloat:_variable2 toReceiver: @"right" ];
}

- (void)turnOn {
    if(!self.on){
        NSLog(@"vibe on");
        self.on = YES;
        self.audioController.active = YES;
        
        [self triggerEventNamed:kEventTurnedOn];
    }
}

- (void)turnOff {
    if(self.on){
        NSLog(@"vibe off");
        self.on = NO;
        self.audioController.active = NO;
        
        [self triggerEventNamed:kEventTurnedOff];
    }
}

- (void)receivePrint:(NSString *)message {
	NSLog(@"Msg %@", message);
}

-(NSString*) description{
    return @"puredata";
}

@end
