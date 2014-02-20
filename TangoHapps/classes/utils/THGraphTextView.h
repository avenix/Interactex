//
//  THGraphTextView.h
//  TangoHapps
//
//  Created by Juan Haladjian on 11/02/14.
//  Copyright (c) 2014 Technische Universität München. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THGraphTextView : UIView

@property (nonatomic) float maxAxisY;
@property (nonatomic) float minAxisY;

- (id)initWithFrame:(CGRect)frame maxAxisY:(float) maxAxisY minAxisY:(float) minAxisY ;

@end