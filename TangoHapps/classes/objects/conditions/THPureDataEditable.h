//
//  THPureDataEditable.h
//  TangoHapps
//
//  Created by Juan Haladjian on 4/23/13.
//  Copyright (c) 2013 Technische Universität München. All rights reserved.
//

#import "THActionEditable.h"

@interface THPureDataEditable : THActionEditable

@property (nonatomic, readonly) BOOL on;
@property (nonatomic) NSInteger variable1;
@property (nonatomic) NSInteger variable2;

- (void)turnOn;
- (void)turnOff;

@end
