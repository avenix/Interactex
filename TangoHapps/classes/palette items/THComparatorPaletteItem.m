//
//  THConditionPaletteItem.m
//  TangoHapps
//
//  Created by Juan Haladjian on 9/15/12.
//  Copyright (c) 2012 TUM. All rights reserved.
//

#import "THComparatorPaletteItem.h"
#import "THComparisonConditionEditable.h"

@implementation THComparatorPaletteItem

- (void)dropAt:(CGPoint)location {
    THComparisonConditionEditable * condition = [[THComparisonConditionEditable alloc] init];
    condition.position = location;
    
    THCustomProject * project = (THCustomProject*) [TFDirector sharedDirector].currentProject;
    [project addCondition:condition];
}

@end