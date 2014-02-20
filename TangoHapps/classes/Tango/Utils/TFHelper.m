/*
TFHelper.m
Interactex Designer

Created by Juan Haladjian on 05/10/2013.

Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".

Interactex is built using the Tango framework developed by TU Munich.

In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.). 
www.cocos2d-iphone.org
github.com/gabriel/gh-unit

Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
www.firmata.org

All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
www.frizting.org

Martijn ten Bhömer from TU Eindhoven contributed PureData support. Contact: m.t.bhomer@tue.nl.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "TFHelper.h"
#import "TFConnectionLine.h"
#import "TFEditableObject.h"
#import "THWire.h"
#import "THElementPinEditable.h"
#import "THBoardPinEditable.h"

@implementation TFHelper

+(CGPoint) tabToEditorCoordinates:(CGPoint) position{
    CGRect screen = [[UIScreen mainScreen] bounds]; 
    position.y = screen.size.width - position.y;
    return position;
}

+(void)Dec2bin:(unsigned short)dec bin:(bool*) res {
    for (int i=0; i<16; i++) {
        res[i] = 0;
    }
    
    int i=15;
    while(dec >1){
        bool bin = dec % 2;
        res[i--]=bin;
        dec /= 2;
    }
    res[i] = dec;
}

+(unsigned short) Bin2Dec:(bool[]) bits{
    unsigned short res = 0;
    for (int i=0;i<16;i++) {
        res <<= 1;
        res |= bits[15-i];
    }
    return res;
}

+(void) saveImageToFile:(UIImage*) image file:(NSString*) filePath{
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

+(void) drawRect:(CGRect) rect{

    ccDrawSolidRect(rect.origin, ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height)), ccc4f(1, 0, 0, 1));
}

+(void) drawEmptyRect:(CGRect) rect{
    
    ccDrawSolidRect(rect.origin, ccpAdd(rect.origin,ccp(rect.size.width,rect.size.height)), ccc4f(1, 0, 0, 1));
}

+(void) drawLines:(NSArray *) connections{
    
    for (TFConnectionLine * line in connections) {
        if(line.obj1.visible && line.obj2.visible){
            [line draw];
        }
    }
    
    [TFHelper restoreDrawingState];
}

+(void) drawWires:(NSArray *) wires{
    
    for (THWire * wire in wires) {
        if(wire.obj1.visible && wire.obj2.visible){
            [wire draw];
        }
    }
    
    [TFHelper restoreDrawingState];
}

+(void) restoreDrawingState {

    glLineWidth(1.0f);
    ccDrawColor4B(255,255,255,255);
}

+(UILabel*) navBarTitleLabelNamed:(NSString*) name{
    
    UILabel * label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.frame = CGRectMake(0, 5, 300, 35);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = name;
    label.textColor = [UIColor colorWithRed:0.43 green:0.47 blue:0.5 alpha:1];
    label.font = [UIFont systemFontOfSize:20];
    label.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    return label;
}

+(CGPoint) ConvertToCocos2d:(CGPoint) point{
    
    return ccp(point.x, -point.y);
}

+(CGPoint) ConvertToCocos2dView:(CGPoint) point{
    
    float diff = 768 - [CCDirector sharedDirector].view.frame.size.height;
    return ccp(point.x, 768 - point.y - diff);
}

+(CGPoint) ConvertFromCocosToUI:(CGPoint) point{
    
    return ccp(point.x, 768 - point.y);
}

+(BOOL) canConvertParam:(TFDataType) type1 toType:(TFDataType) type2{
    return (type1 == kDataTypeAny || type2 == kDataTypeAny || type1 == type2 || (type1 == kDataTypeFloat && type2 == kDataTypeInteger) || (type2 == kDataTypeFloat && type1 == kDataTypeInteger));
    
}

#pragma mark - Screenshot

CGImageRef UIGetScreenImage(void);

+(UIImage*) takeScreenshot
{
    CGImageRef screen = UIGetScreenImage();
    UIImage * image = [UIImage imageWithCGImage:screen];
    CGImageRelease(screen);
    return image;
}


+(UIImage*) screenshot{
    UIImage *image = [self takeScreenshot];
    CGFloat navigationBarHeight = 44;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width - navigationBarHeight;
    CGFloat screenHeight = screenRect.size.height;

    
    UIGraphicsBeginImageContext(CGSizeMake(screenHeight, screenWidth));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == UIInterfaceOrientationLandscapeLeft){
        
        CGContextRotateCTM (context, M_PI/2);
        [image drawInRect:CGRectMake(-navigationBarHeight, -screenHeight, screenWidth + navigationBarHeight, screenHeight)];
        
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        CGContextRotateCTM (context, -M_PI/2);
        [image drawInRect:CGRectMake(-screenWidth, 0, screenWidth + navigationBarHeight,screenHeight)];
    }
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - Animations


@end
