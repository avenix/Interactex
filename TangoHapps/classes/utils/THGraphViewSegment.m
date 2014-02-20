//
//  THGraphViewSegment.m
//  TangoHapps
//
//  Created by Juan Haladjian on 11/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGraphViewSegment.h"
#import "THGraphViewHelper.h"

@implementation THGraphViewSegment

@synthesize layer;

- (id)initWithHeight:(float) height {
    
	self = [super init];
	if (self != nil) {
        _height = height;
        
		layer = [[CALayer alloc] init];
		layer.delegate = self;
        
        //layer.bounds = CGRectMake(0.0, - self.height - kGraphViewGraphOffsetY, kGraphSegmentSize, height);
layer.bounds = CGRectMake(0.0, - self.height, kGraphSegmentSize, height);
        
		//layer.opaque = YES;
		self.index = kGraphSegmentSize;
	}
	return self;
}

- (void)reset {
	memset(points, 0, sizeof(points));
    
    for(int i = 0 ; i < kGraphSegmentSize ; i++){
        isFilled[i] = 0;
    }
    
	self.index = kGraphSegmentSize;
	[layer setNeedsDisplay];
}
                    
-(BOOL) isFull {
	return self.index == 0;
}

-(BOOL) isVisibleInRect:(CGRect)r {

    return (layer.frame.origin.x + layer.frame.size.width) < (r.origin.x + r.size.width) ;
}

-(BOOL) addValue:(float)value {
 	if (self.index > 0) 	{
		--self.index;
		points[self.index] = value;
        isFilled[self.index] = YES;

		[layer setNeedsDisplay];
	}
	return self.index == 0;
}

- (void)drawLayer:(CALayer*)l inContext:(CGContextRef)context{
    
    CGColorRef color = CreateDeviceRGBColor(1, 1, 1, 0);
    
	CGContextSetFillColorWithColor(context, color);
	CGContextFillRect(context, layer.bounds);
    
    int pointsCount = 0;
    BOOL previousFilled = false;
    
	for (int i = 0; i < kGraphSegmentSize-1; ++i) {
        
        if(isFilled[i] && isFilled[i+1]){
            
            lines[pointsCount*2].x = i;
            lines[pointsCount*2+1].x = i+1;
            
            lines[pointsCount*2].y = -points[i];
            lines[pointsCount*2+1].y = -points[i+1];
            
            previousFilled = YES;
            pointsCount++;
            
        } else {
            if(previousFilled){
                CGContextSetStrokeColorWithColor(context, self.color.CGColor);
                CGContextStrokeLineSegments(context, lines, pointsCount*2);
                previousFilled = NO;
                pointsCount = 0;
            }
        }
	}
    
    if(previousFilled){
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextStrokeLineSegments(context, lines, pointsCount*2);
    }
}


- (id)actionForLayer:(CALayer *)layer forKey :(NSString *)key {
	// We disable all actions for the layer, so no content cross fades, no implicit animation on moves, etc.
	return [NSNull null];
}

// The accessibilityValue of this segment should be the x,y,z values last added.
- (NSString *)accessibilityValue {
	return [NSString stringWithFormat:NSLocalizedString(@"graphSegmentFormat", @""), points[self.index]];
}

@end
