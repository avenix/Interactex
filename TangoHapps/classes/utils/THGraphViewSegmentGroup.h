//
//  THGraphViewSegmentGroup.h
//  TangoHapps
//
//  Created by Juan Haladjian on 12/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THGraphViewSegment;

@interface THGraphViewSegmentGroup : UIView

@property (nonatomic, strong) NSMutableArray *segments;

@property (nonatomic, unsafe_unretained) THGraphViewSegment * currentSegment;

@property (nonatomic, strong) UIColor * color;


-(id) initWithFrame:(CGRect)frame color:(UIColor*) color;
- (void)addValue:(float)value;

@end
