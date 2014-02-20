
#import "THGraphView.h"
#import "THGraphTextView.h"
#import "THGraphViewHelper.h"
#import "THGraphViewSegment.h"
#import "THGraphViewSegmentGroup.h"

@implementation THGraphView

float const kGraphViewLeftAxisWidth = 42.0;

- (id)initWithFrame:(CGRect)frame maxAxisY:(float) maxAxisY minAxisY:(float) minAxisY {
    
	self = [super initWithFrame:frame];
	if (self != nil) {
        
        _maxAxisY = maxAxisY;
        _minAxisY = minAxisY;
        
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	if (self != nil) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
    
    CGRect frame = CGRectMake(kGraphViewLeftAxisWidth, 0.0, self.frame.size.width - kGraphViewLeftAxisWidth, self.frame.size.height);
    self.groupX = [[THGraphViewSegmentGroup alloc] initWithFrame:frame color:[UIColor blueColor]];
    self.groupX.hidden = YES;
    [self addSubview:self.groupX];
    
    self.groupY = [[THGraphViewSegmentGroup alloc] initWithFrame:frame color:[UIColor redColor]];
    self.groupY.hidden = YES;
    [self addSubview:self.groupY];
    
    //self.groupX.layer.borderWidth = 1.0f;
    
    frame = CGRectMake(0.0, 0.0, kGraphViewLeftAxisWidth, self.frame.size.height);
	_textView = [[THGraphTextView alloc] initWithFrame:frame maxAxisY: self.maxAxisY minAxisY:self.minAxisY];
	[self addSubview:self.textView];
}

-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    frame = CGRectMake(0.0, 0.0, kGraphViewLeftAxisWidth, self.frame.size.height);
    self.textView.frame = frame;
    
    frame = CGRectMake(kGraphViewLeftAxisWidth, 0.0, self.frame.size.width - kGraphViewLeftAxisWidth, self.frame.size.height);
    self.groupX.frame = frame;
    self.groupY.frame = frame;
}

-(void) setMaxAxisY:(float)maxAxisY{
    self.textView.maxAxisY = maxAxisY;
    [self.textView setNeedsDisplay];
}

-(void) setMinAxisY:(float)minAxisY{
    self.textView.minAxisY = minAxisY;
        [self.textView setNeedsDisplay];
}

- (void)addX:(float)value{
    
	[self.groupX addValue:value];
}

- (void)addY:(float)value{
    
	[self.groupY addValue:value];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	// Fill in the background
	CGContextSetFillColorWithColor(context, graphBackgroundColor());
	CGContextFillRect(context, self.bounds);
    
    DrawHorizontalLine(context, 0.0, kGraphViewGraphOffsetY + kGraphViewAxisLabelSize.height / 2.0f , self.bounds.size.width);
	//DrawHorizontalLine(context, 0.0, self.bounds.size.height / 2.0f + kGraphViewAxisLabelSize.height / 2.0f, self.bounds.size.width);
	DrawHorizontalLine(context, 0.0, self.bounds.size.height - kGraphViewGraphOffsetY - kGraphViewAxisLabelSize.height / 2.0f, self.bounds.size.width);
    StrokeLines(context);
}

-(void) stop{
    
    self.groupX.hidden = YES;
    self.groupY.hidden = YES;
}

-(void) start{
    
    self.groupX.hidden = NO;
    self.groupY.hidden = NO;

}

@end
