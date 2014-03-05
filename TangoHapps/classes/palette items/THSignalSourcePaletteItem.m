//
//  THSignalSourcePaletteItem.m
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import "THSignalSourcePaletteItem.h"
#import "THSignalSourceEditable.h"

@implementation THSignalSourcePaletteItem

- (void)dropAt:(CGPoint)location
{
    THSignalSourceEditable *editableSignalSource = [[THSignalSourceEditable alloc] init];
    editableSignalSource.position = location;
    
    THProject *project = [THDirector sharedDirector].currentProject;
    
    [project addValue:editableSignalSource];
}

@end
