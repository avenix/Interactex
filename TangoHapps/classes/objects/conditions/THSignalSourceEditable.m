//
//  THSignalSourceEditable.m
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//
#import "THSignalSourceProperties.h"
#import "THSignalSourceEditable.h"
#import "THSignalSource.h"


@implementation THSignalSourceEditable

- (void)load
{
    
    self.sprite = [CCSprite spriteWithFile:@"signalsource.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
}

-(id) init{
    self = [super init];
    if(self){
        self.simulableObject = [[THSignalSource alloc] init];
        [self load];
    }
    return self;
}

- (void)update
{
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source updatedSimulation];
}

- (void)start
{
    [(THSignalSource *)self.simulableObject start];
}

- (void)stop
{
    [(THSignalSource *)self.simulableObject stop];
}

- (void)toggle
{
    [(THSignalSource *)self.simulableObject toggle];
}


- (NSString *)description
{
    return @"SignalSource";
}

- (void)switchSourceFile:(NSString *)filename
{
    THSignalSource *source = (THSignalSource *)self.simulableObject;
    [source switchSourceFile:filename];
}

#pragma mark - Property Controller

- (NSArray *)propertyControllers
{
    NSArray *controllers = [super propertyControllers];
    THSignalSourceProperties *properties = [THSignalSourceProperties properties];
    //add property-controllers here
    return [controllers arrayByAddingObject:properties];
}


#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone {
    THSignalSourceEditable * copy = [super copyWithZone:zone];
    
    return copy;
}



@end
