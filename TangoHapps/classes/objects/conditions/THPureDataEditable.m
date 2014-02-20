//
//  THPureDataEditable.m
//  TangoHapps
//
//  Created by Juan Haladjian on 4/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "THPureDataEditable.h"
#import "THPureData.h"
#import "THPureDataProperties.h"

@implementation THPureDataEditable

@dynamic variable1;
@dynamic variable2;

@dynamic on;

-(void) loadPureData{
    self.sprite = [CCSprite spriteWithFile:@"puredata.png"];
    [self addChild:self.sprite];
    
    self.acceptsConnections = YES;
}

-(id) init{
    self = [super init];
    if(self){
        self.simulableObject = [[THPureData alloc] init];
        
        [self loadPureData];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        [self loadPureData];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone {
    THPureDataEditable * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    [controllers addObject:[THPureDataProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(BOOL) on{
    THPureData * puredata = (THPureData*)self.simulableObject;
    return puredata.on;
}

- (void)turnOn{
    THPureData * puredata = (THPureData*)self.simulableObject;
    [puredata turnOn];
}

- (void)turnOff{
    THPureData * puredata = (THPureData*)self.simulableObject;
    [puredata turnOff];
}

-(NSInteger) variable1{
    THPureData * pureData = (THPureData*)self.simulableObject;
    return pureData.variable1;
}

-(NSInteger) variable2{
    THPureData * pureData = (THPureData*)self.simulableObject;
    return pureData.variable2;
}

-(void) setVariable1:(NSInteger)var1{

    THPureData * pureData = (THPureData*)self.simulableObject;
    pureData.variable1 = var1;
}

-(void) setVariable2:(NSInteger)var2{

    THPureData * pureData = (THPureData*)self.simulableObject;
    pureData.variable2 = var2;
}

-(NSString*) description{
    return @"PureData";
}

@end
