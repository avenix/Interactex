//
//  THValueProperties.h
//  TangoHapps
//
//  Created by Juan Haladjian on 11/17/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "TFEditableObjectProperties.h"

@interface THValueProperties : TFEditableObjectProperties

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
- (IBAction)editingFinished:(id)sender;
@end