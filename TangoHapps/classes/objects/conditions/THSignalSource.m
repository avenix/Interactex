//
//  THSignalSource.m
//  TangoHapps
//
//  Created by Michael Conrads on 27/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSource.h"

@interface THSignalSource ()
@property (nonatomic, assign, readwrite) NSInteger currentOutputValue;
@property (nonatomic, strong, readwrite) NSArray *data;
@property (nonatomic, assign, readwrite) BOOL sendingData;
@property (nonatomic, assign, readwrite) NSUInteger index;
@end

@implementation THSignalSource

- (void)load
{
    TFProperty * property = [TFProperty propertyWithName:@"currentOutputValue" andType:kDataTypeInteger];
    self.properties = [NSMutableArray arrayWithObject:property];
    
    
    TFMethod *startMethod = [TFMethod methodWithName:@"start"];
    TFMethod *stopMethod = [TFMethod methodWithName:@"stop"];
    TFMethod *toggleMethod = [TFMethod methodWithName:@"toggle"];
    
    self.methods = [NSMutableArray arrayWithObjects:startMethod, stopMethod, toggleMethod, nil];
    
    
    TFEvent * event = [TFEvent eventNamed:kEventValueChanged];
    event.param1 = [TFPropertyInvocation invocationWithProperty:property
                                                         target:self];
    self.events = [NSMutableArray arrayWithObject:event];
    
    NSData *d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"singletick" ofType:@"txt"]];
    assert(d != nil);
    
    NSString *content = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.data = [content componentsSeparatedByString:@"\n"];
}


#pragma mark - Methods

- (void)didStartSimulating
{
    [super didStartSimulating];
}

- (NSString *)description
{
    return @"SignalSource";
}


- (void)start
{
    self.index = 0;
    self.sendingData = YES;
}

- (void)stop
{
    self.sendingData = NO;
}

- (void)toggle
{
    self.sendingData = !self.sendingData;
}

- (void)updatedSimulation
{
    if(self.sendingData)
    {
        self.currentOutputValue = [self.data[self.index] integerValue];
        [self triggerEventNamed:kEventValueChanged];
        self.index = (self.index + 1) % self.data.count;
    }
}


#pragma mark - Archiving

- (id)init
{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone
{
    THSignalSource *copy = [super copyWithZone:zone];
    return copy;
}

- (void)switchSourceFile:(NSString *)filename
{
    NSData *d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:@"txt"]];
    assert(d != nil);
    
    NSString *content = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    self.data = [content componentsSeparatedByString:@"\n"];

}
@end
