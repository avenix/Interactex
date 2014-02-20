//
//  THSoundPaletteItem.m
//  TangoHapps
//
//  Created by Juan Haladjian on 4/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "THPureDataPaletteItem.h"
#import "THProject.h"
#import "THPureDataEditable.h"

@implementation THPureDataPaletteItem

- (void)dropAt:(CGPoint)location {
    THPureDataEditable * puredata = [[THPureDataEditable alloc] init];
    puredata.position = location;
    
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    [project addAction:puredata];
}

@end
