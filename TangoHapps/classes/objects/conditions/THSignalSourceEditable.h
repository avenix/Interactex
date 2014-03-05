//
//  THSignalSourceEditable.h
//  TangoHapps
//
//  Created by Michael Conrads on 28/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "THProgrammingElementEditable.h"
@interface THSignalSourceEditable : THProgrammingElementEditable
@property (nonatomic, assign, readwrite) NSInteger currentOutputValue;
@property (nonatomic, assign, readwrite) float leftBorderPercentage;
@property (nonatomic, assign, readwrite) float rightBorderPercentage;
- (void)switchSourceFile:(NSString *)filename;
@end
