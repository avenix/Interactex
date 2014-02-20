/*
THImagePickerController.m
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

#import "THImagePickerController.h"
#import <AssetsLibrary/ALAssetRepresentation.h>

float const kImagePickerPadding = 5;
CGSize const kImagePickerImageSize = {60,60};

@implementation THImagePickerController

-(id) init{
    self = [super init];
    if(self){
        
        _currentPos = CGPointMake(kImagePickerPadding,kImagePickerPadding);
        
        self.thumbnails = [[NSMutableArray alloc] init];
        self.imageAssets = [[NSMutableArray alloc] init];
        self.library = [[ALAssetsLibrary alloc] init];
        
        [self loadGui];
    }
    return self;
}

-(void) loadGui{
    CGRect frame = CGRectMake(0, 0, 300, 300);
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor grayColor];
    
    CGRect imagesContainerFrame = CGRectMake(10, 10, 280, 200);
    self.imagesContainer = [[UIScrollView alloc] initWithFrame:imagesContainerFrame];
    self.imagesContainer.backgroundColor = [UIColor lightGrayColor];
    self.imagesContainer.contentSize = imagesContainerFrame.size;
    [self.view addSubview:self.imagesContainer];
    
    CGRect imageViewFrame = CGRectMake(20, 233, 60, 60);
    self.currentImageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    self.currentImageView.layer.borderWidth = 1.0f;
    self.currentImageView.layer.cornerRadius = 3.0f;
    self.currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.currentImageView];
    
    CGRect buttonFrame = CGRectMake(214, 233, 60, 60);
    self.okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.okButton.frame = buttonFrame;
    [self.okButton addTarget:self action:@selector(okButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [self.okButton setTitle:@"OK" forState:UIControlStateNormal];
    [self.view addSubview:self.okButton];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.center = self.imagesContainer.center;
    [self.view addSubview:_activityIndicator];
    
    [self viewDidLoad];
}

-(void) okButtonTapped:(UIButton *)sender {
    
    ALAssetRepresentation * representation = [self.selectedAsset defaultRepresentation];
    NSString * name = [representation filename];
    UIImage * image = [UIImage imageWithCGImage:[representation fullResolutionImage]];
    [self.delegate imagePicker:self didSelectImage:image imageName:name];
}

-(void) buttonTapped:(UIButton*) button{
    self.currentImageView.image = [self.thumbnails objectAtIndex:button.tag];
    self.selectedAsset = [self.imageAssets objectAtIndex:button.tag];
}

-(void) addPhotForAsset:(ALAsset *)asset {
    
    UIImage * image = [UIImage imageWithCGImage:[asset thumbnail]];
    [self.thumbnails addObject:image];
    [self.imageAssets addObject:asset];
    [self layoutImage:image];
}

-(void) loadImages {
    
    [_activityIndicator startAnimating];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)          {

             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                 if (alAsset) {
                     
                     [self addPhotForAsset:alAsset];
                     
                 } else {
                     [_activityIndicator stopAnimating];
                 }
             }];
         }
                             failureBlock: ^(NSError *error) {
                                 NSLog(@"No groups");
                             }];
    }
}

-(void) layoutImage:(UIImage*) image{
    
    CGRect frame = CGRectMake(_currentPos.x, _currentPos.y, kImagePickerImageSize.width, kImagePickerImageSize.height);
    UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
    imageView.image = image;
    imageView.frame = frame;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = self.imageAssets.count-1;
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
    
    [self.imagesContainer addSubview:button];
    [self.imagesContainer addSubview:imageView];
    
    _currentPos.x += frame.size.width + kImagePickerPadding;
    if(_currentPos.x + kImagePickerImageSize.width >= self.imagesContainer.frame.size.width){
        _currentPos.x = kImagePickerPadding;
        _currentPos.y += frame.size.height + kImagePickerPadding;
    }
    
    self.imagesContainer.contentSize = CGSizeMake(self.imagesContainer.contentSize.width, _currentPos.y - 10);
}


#pragma mark - View lifecycle

//-(void) present
-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadImages];
    self.contentSizeForViewInPopover = self.view.frame.size;
}

-(void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
}

@end
