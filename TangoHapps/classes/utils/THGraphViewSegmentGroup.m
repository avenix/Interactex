//
//  THGraphViewSegmentGroup.m
//  TangoHapps
//
//  Created by Juan Haladjian on 12/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGraphViewSegmentGroup.h"
#import "THGraphViewSegment.h"
#import "THGraphViewHelper.h"

float const kGraphViewOffsetX = 10.0f;

@implementation THGraphViewSegmentGroup

-(id) initWithFrame:(CGRect)frame color:(UIColor*) color{
    self = [super initWithFrame:frame];
    if(self){
        self.color = color;
        _segments = [[NSMutableArray alloc] init];
        self.currentSegment = [self addSegment];
    }
    return self;
}

-(void)addValue:(float)value{
    
	if ([self.currentSegment addValue:value]) {
		[self recycleSegment];
		[self.currentSegment addValue:value];
	}
    
	for (THGraphViewSegment *s in self.segments) {
		CGPoint position = s.layer.position;
		position.x += 1.0;
		s.layer.position = position;
	}
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
}

-(THGraphViewSegment*) addSegment{
    
	THGraphViewSegment * segment = [[THGraphViewSegment alloc] initWithHeight:self.frame.size.height];
    segment.color = self.color;
    
    //segment.layer.borderWidth = 1.0f;
    //segment.layer.borderColor = [UIColor redColor].CGColor;
    
	[self.segments insertObject:segment atIndex:0];
    [self.layer addSublayer:segment.layer];
    
    segment.layer.position = CGPointMake(- segment.layer.frame.size.width/2, self.frame.size.height/2);
	return segment;
}

-(void) recycleSegment{
	THGraphViewSegment * last = [self.segments lastObject];
    
	if ([last isVisibleInRect:self.layer.bounds]) {
        
		self.currentSegment = [self addSegment];
        
	} else {
        
		[last reset];
        
        last.layer.position = CGPointMake(- last.layer.frame.size.width/2, self.frame.size.height/2);
		[self.segments insertObject:last atIndex:0];
		[self.segments removeLastObject];
		self.currentSegment = last;
	}
}

// Return an up-to-date value for the graph.
-(NSString *)accessibilityValue {
	if (self.segments.count == 0) {
		return nil;
	}
	
	// Let the GraphViewSegment handle its own accessibilityValue;
	THGraphViewSegment *graphViewSegment = self.segments[0];
	return [graphViewSegment accessibilityValue];
}

@end
