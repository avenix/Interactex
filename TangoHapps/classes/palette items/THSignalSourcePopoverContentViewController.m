//
//  THSignalSourcePopoverContentViewController.m
//  TangoHapps
//
//  Created by Michael Conrads on 05/03/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourcePopoverContentViewController.h"
#import "THSignalSourcePopoverContentView.h"
#import "THSignalSource.h"
#import "THGraphView.h"

@interface THSignalSourcePopoverContentViewController ()
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (nonatomic, strong, readwrite) THSignalSourceEditable *signalSourceEditable;
@property (nonatomic, strong, readwrite) NSArray *currentData;
@property (nonatomic, assign, readwrite) float graphSize;
@end

@implementation THSignalSourcePopoverContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
         signalSourceEditable:(THSignalSourceEditable *)signalSourceEditable
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self)
    {
        self.signalSourceEditable = signalSourceEditable;
        
    }
    return self;
}

- (void)viewDidLoad
{
//    self.view.backgroundColor = [UIColor colorWithWhite:0.333 alpha:1.000];
    
    
    THGraphView *graphView = [[THGraphView alloc] initWithFrame:self.view.frame maxAxisY:200 minAxisY:0];
    [self.view addSubview:graphView];
    
    
    THSignalSource *signalSource = (THSignalSource *)self.signalSourceEditable.simulableObject;
    NSArray *data = signalSource.data;
    
    __block float largest = 0;
    
    [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if([obj floatValue] > largest)
        {
            largest = [obj floatValue];
        }
        
    }];
    
    
    
    //TODO: this assumes the number of samples is smaller than the monitor with, so it does a linear interpolation
    //TODO: maybe switch to splines...
    
    NSMutableArray *normalizedArray = [NSMutableArray arrayWithCapacity:data.count];
    
    for (NSString *oneDataString in data)
    {
        float normalizedValue = [oneDataString floatValue]/largest;
        float h = graphView.frame.size.height *0.9;
        
        [normalizedArray addObject:@(graphView.frame.size.height - normalizedValue * h)];
    }
    //288
    float wLeft = 42.0;
    float spaceForDisplaying = graphView.frame.size.width - 2*wLeft;
    self.graphSize = spaceForDisplaying;
    float f = (float)spaceForDisplaying/(float)normalizedArray.count;
    
    for (int i = 0; i < normalizedArray.count -1 ; i++)
    {
        float left = [normalizedArray[i] floatValue];
        float right = [normalizedArray[i+1] floatValue];
        
        float dY = right - left;
        float dSegY = dY/f;
        
        
        //[graphView addX:left];

        float acc = left;
        for (int k = 0; k < f;  k++)
        {
            acc = left + k * dSegY;
            [graphView addX:acc];
        }
    }
    [graphView addX:[[normalizedArray lastObject] floatValue]];
    
//    for (int i = 0; i < 163 -wLeft; i++)
//    {
//        [graphView addX:90];
//    }
    [graphView start];
    
    
    THSignalSourcePopoverContentView *contentView = [[THSignalSourcePopoverContentView alloc] initWithFrame:self.view.frame signalData:data];
    [self.view addSubview:contentView];

    
    self.okButton.backgroundColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    [self.view bringSubviewToFront:self.okButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movedBar:) name:@"movedBar" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"movedBar" object:nil];
}


- (void)movedBar:(NSNotification *)notification
{
    float left = [notification.userInfo[@"left"] floatValue];
    float right = [notification.userInfo[@"right"] floatValue];
    
    float wLeft = 42.0;
    if(left > wLeft)
    {
        float l = left - wLeft;
        
        float leftpercent =  l/self.graphSize;
//        NSLog(@"%f",percent);
    }
    
    if(right < wLeft + self.graphSize)
    {
        
        float rightPercent = (right - wLeft)/self.graphSize;
        
        NSLog(@"%f",rightPercent);
    }
}

- (IBAction)okButtonPressed:(id)sender {
}

- (CGSize)contentSizeForViewInPopover
{
    return self.view.frame.size;
}
@end
