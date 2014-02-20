//
//  THGraphTextView.m
//  TangoHapps
//
//  Created by Juan Haladjian on 11/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THGraphTextView.h"
#import "THGraphViewHelper.h"

@implementation THGraphTextView

- (id)initWithFrame:(CGRect)frame maxAxisY:(float) maxAxisY minAxisY:(float) minAxisY {
    self = [super initWithFrame:frame];
    if(self){
        _maxAxisY = maxAxisY;
        _minAxisY = minAxisY;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphBackgroundColor());
	CGContextFillRect(context, self.bounds);
    
	// Draw the grid lines
    float height = self.frame.size.height;
    DrawHorizontalLine(context, kGraphViewAxisLabelSize.width, kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f , kGraphViewAxisLineWidth);
	DrawHorizontalLine(context, kGraphViewAxisLabelSize.width, height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height / 2.0f, kGraphViewAxisLineWidth);
    StrokeLines(context);
    
	// Draw the text
	UIFont *systemFont = [UIFont systemFontOfSize:12.0];
	[[UIColor whiteColor] set];
    
    NSString * topValue = [NSString stringWithFormat:@"%.1f",self.maxAxisY];
    NSString * bottomValue = [NSString stringWithFormat:@"%.1f",self.minAxisY];
    
	[topValue drawInRect:CGRectMake(0.0, kGraphViewGraphOffsetY, kGraphViewAxisLabelSize.width, kGraphViewAxisLabelSize.height) withFont:systemFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
    
	[bottomValue drawInRect:CGRectMake(0.0, height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height, kGraphViewAxisLabelSize.width, kGraphViewAxisLabelSize.height) withFont:systemFont lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
}


@end
