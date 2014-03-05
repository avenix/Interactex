//
//  THSignalSourcePopoverContentView.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourcePopoverContentView.h"
#define BAR_WIDTH 20

@interface THSignalSourcePopoverContentView ()
@property (nonatomic, assign, readwrite) CGRect leftHandle;
@property (nonatomic, assign, readwrite) CGRect rightHandle;
@property (nonatomic, assign, readwrite) BOOL draggingLeft;
@property (nonatomic, assign, readwrite) BOOL draggingRight;


@end

@implementation THSignalSourcePopoverContentView


- (id)initWithFrame:(CGRect)frame
         leftPercentage:(float)leftPercentage
    rightPercentage:(float)rightPercentage
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.opaque = NO;
        //TODO: add percentage
        self.leftHandle = CGRectMake(0, 0, BAR_WIDTH, frame.size.height);
        self.rightHandle = CGRectMake(frame.size.width-BAR_WIDTH, 0, 20, frame.size.height);
        
        UIPanGestureRecognizer *pangestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                               action:@selector(panned:)];
        
        pangestureRecognizer.minimumNumberOfTouches = pangestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:pangestureRecognizer];

    }
    return self;
}

- (void)panned:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint position = [panGestureRecognizer locationInView:panGestureRecognizer.view];

    if(self.draggingLeft)
    {
        
        if(position.x < self.rightHandle.origin.x - BAR_WIDTH && position.x > 0)
        {
            CGRect f = self.leftHandle;
            f.origin.x = position.x;
            self.leftHandle = f;
        }
        [self setNeedsDisplay];
    }
    else if(self.draggingRight)
    {
        if(position.x > self.leftHandle.origin.x + BAR_WIDTH && position.x < self.frame.size.width-BAR_WIDTH)
        {
            CGRect f = self.rightHandle;
            f.origin.x = position.x;
            self.rightHandle = f;
        }
        [self setNeedsDisplay];
    }
    
    if(panGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self stoppedDragging];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{

    UITouch *t = [touches anyObject];
    CGPoint position = [t locationInView:self.superview];
    
    if(CGRectContainsPoint(self.leftHandle, position))
    {
        self.draggingLeft = YES;
        self.draggingRight = NO;
    }
    else if(CGRectContainsPoint(self.rightHandle, position))
    {
        self.draggingLeft = NO;
        self.draggingRight = YES;
    }
    else
    {
        self.draggingLeft = self.draggingRight = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [self stoppedDragging];
}


- (void)stoppedDragging
{
    self.draggingLeft = NO;
    self.draggingRight = NO;
    
    
    NSDictionary *d = @{@"left":@(self.leftHandle.origin.x + BAR_WIDTH),
                        @"right":@(self.rightHandle.origin.x)};
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"movedBar" object:Nil userInfo:d]];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:0.165 green:0.333 blue:0.215 alpha:1.000].CGColor);

    CGContextFillRect(contextRef, self.leftHandle);
    CGContextFillRect(contextRef, self.rightHandle);
    
    
    
    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:0.165 green:0.333 blue:0.215 alpha:0.480].CGColor);
    CGRect leftRect = CGRectMake(0,
                                 0,
                                 self.leftHandle.origin.x,
                                 self.leftHandle.size.height);
    
    float rightHandleRightBorder = self.rightHandle.origin.x + self.rightHandle.size.width;
    CGRect rightRect = CGRectMake(rightHandleRightBorder,
                                  0,
                                  self.frame.size.width - rightHandleRightBorder,
                                  self.rightHandle.size.height);
    
    CGContextFillRect(contextRef, leftRect);
    CGContextFillRect(contextRef, rightRect);
    
}

@end
