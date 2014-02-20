/*
THProjectViewController.m
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

#import "THProjectViewController.h"
#import "THProjectViewController.h"
#import "THTabbarViewController.h"
#import "THSimulator.h"
#import "THEditor.h"
#import "THiPhoneEditableObject.h"
#import "THProjectProxy.h"
#import "THDirector.h"
#import "THProject.h"
#import "TFHelper.h"

@implementation THProjectViewController

float const kPalettePullY = 364;
float const kToolsTabMargin = 5;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    CCDirector * ccDirector = [CCDirector sharedDirector];
    
    ccDirector.delegate = self;
    
    [self addChildViewController:ccDirector];
    [self.view addSubview:ccDirector.view];
    [self.view sendSubviewToBack:ccDirector.view];
    [ccDirector didMoveToParentViewController:self];
    
    [THDirector sharedDirector].projectController = self;
    
    [self loadTools];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    _tabController = [[THTabbarViewController alloc] initWithNibName:@"THTabbar" bundle:nil];
    
    [self.view addSubview:_tabController.view];
    
    
    // Observe some notifications so we can properly instruct the director.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationSignificantTimeChange:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
    
    _state = kAppStateEditor;
    
    [self showTabBar];
    
    [self addEditionButtons];
    [self updateEditingButtonsTint];
    
    [self reloadContent];
    [self startWithEditor];
    
    [self addPalettePull];
    [self updatePalettePullVisibility];
    
    THProject * project = [THDirector sharedDirector].currentProject;
    self.navigationItem.title = project.name;
    self.title = project.name;
    
    _currentProjectName = [THDirector sharedDirector].currentProject.name;
}

-(void) viewWillDisappear:(BOOL)animated {
    
    [self saveCurrentProjectAndPalette];
    
    //[[THDirector sharedDirector].serverController stopServer];
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
    
    
    [self.currentLayer prepareToDie];
    [[THDirector sharedDirector].currentProject prepareToDie];
    
    [_currentLayer removeFromParentAndCleanup:YES];
    
    _currentLayer = nil;
    _currentScene = nil;
    
    [THDirector sharedDirector].currentProject = nil;
    [THDirector sharedDirector].currentProxy = nil;   
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[CCDirector sharedDirector] setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[CCDirector sharedDirector] purgeCachedData];
}

#pragma mark - Saving and restoring projects

-(void) saveCurrentProjectAndPalette{
    
    THDirector * director = [THDirector sharedDirector];
    if(!director.currentProject.isEmpty){
        [self saveCurrentProject];
    }
    [self.tabController.paletteController save];
}

-(void) saveCurrentProject{
    THDirector * director = [THDirector sharedDirector];
    THProject * currentProject = director.currentProject;
    
    //_projectName = [THDirector sharedDirector].currentProject.name;
    
    UIImage * image = [TFHelper screenshot];
    
    if(![THProject doesProjectExistWithName:currentProject.name]){ // if it is a new project
        
        THProjectProxy * proxy = [THProjectProxy proxyWithName:director.currentProject.name];
        proxy.image = image;
        if(![director.projectProxies containsObject:proxy]){
            [director.projectProxies addObject:proxy];
            [director saveProjectProxies];
        }
    } else { //if it already existed, its name may have changed
        director.currentProxy.name = director.currentProject.name;
        director.currentProxy.image = image;
    }
    
    [director.currentProject save];
    
    //[self storeImageForCurrentProject:image];
}

-(void) restoreCurrentProject{
    
    THDirector * director = [THDirector sharedDirector];
    
    [director.currentProject prepareToDie];
    
    if(_currentProjectName != nil){
        director.currentProject = [THProject projectSavedWithName:_currentProjectName];
    }
}

#pragma mark - Notification handlers

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [[CCDirector sharedDirector] resume];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [[CCDirector sharedDirector] stopAnimation];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [[CCDirector sharedDirector] startAnimation];
}


- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(NSNotification *)notification
{
    [[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

#pragma mark - PalettePull

-(void) addPalettePullGestureRecognizer{
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moved:)];
    self.panRecognizer.delegate = self;
    self.panRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.panRecognizer];
}

-(void) removePalettePullRecognizer{
    [self.view removeGestureRecognizer:self.panRecognizer];
    self.panRecognizer = nil;
}

-(void) updatePalettePullVisibility{
    self.palettePullImageView.hidden = self.state;
}

-(void) addPalettePull{
    UIImage * image = [UIImage imageNamed:@"palettePull"];
    self.palettePullImageView = [[UIImageView alloc] initWithImage:image];
    
    CGRect paletteFrame = self.tabController.view.frame;
    self.palettePullImageView.frame = CGRectMake(paletteFrame.origin.x + paletteFrame.size.width, kPalettePullY, image.size.width, image.size.height);
    
    [self.view addSubview:self.palettePullImageView];
    
    [self addPalettePullGestureRecognizer];
}

-(void) moved:(UIPanGestureRecognizer*) sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        
        CGPoint location = [sender locationInView:self.view];
        if(CGRectContainsPoint(self.palettePullImageView.frame,location)){
            self.movingTabBar = YES;
            
            THEditor * editor = (THEditor*) self.currentLayer;
            editor.shouldRecognizePanGestures = NO;
            
        } else {
            self.movingTabBar = NO;
        }
        
    } else if(sender.state == UIGestureRecognizerStateChanged){
        if(self.movingTabBar){
            
            CGPoint translation = [sender translationInView:self.view];
            
            //set palette frame
            CGRect paletteFrame = self.tabController.view.frame;
            paletteFrame.origin.x = paletteFrame.origin.x + translation.x;
            if(paletteFrame.origin.x > 0){
                paletteFrame.origin.x = 0;
            }
            self.tabController.view.frame = paletteFrame;
            
            //set 
            CGRect imageViewFrame = self.palettePullImageView.frame;
            imageViewFrame.origin.x = paletteFrame.origin.x + paletteFrame.size.width;
            if(imageViewFrame.origin.x < 0){
                imageViewFrame.origin.x = 0;
            }
            self.palettePullImageView.frame = imageViewFrame;
            
            [sender setTranslation:CGPointMake(0, 0) inView:self.view];
        }
    } else {
        self.movingTabBar = NO;
        
        THEditor * editor = (THEditor*) self.currentLayer;
        editor.shouldRecognizePanGestures = YES;
    }
}

#pragma mark - Methods

-(void)hideTabBar
{
    _tabController.hidden = YES;
}

-(void)showTabBar
{
    _tabController.hidden = NO;
}
/*
-(void)hideTools
{
    _toolsController.hidden = YES;
}

-(void)showTools
{
    _toolsController.hidden = NO;
}
*/

#pragma mark - Simulation

//XXX check
-(void) startWithEditor{
    
    THEditor * editor = [THEditor node];
    editor.dragDelegate = self.tabController.paletteController;
    _currentLayer = editor;
    [_currentLayer willAppear];
    CCScene * scene = [CCScene node];

    [scene addChild:_currentLayer];
    
    if([CCDirector sharedDirector].runningScene){
        [[CCDirector sharedDirector] replaceScene:scene];
    } else {
        [[CCDirector sharedDirector] runWithScene:scene];
    }
    
    _tabController.paletteController.delegate = editor;
    _state = kAppStateEditor;
    
    [self updateEditingButtonsTint];
}

-(void) switchToLayer:(TFLayer*) layer{
    [_currentLayer willDisappear];
    _currentLayer = layer;
    [_currentLayer willAppear];
    
    CCScene * scene = [CCScene node];
    [scene addChild:_currentLayer];
    
    [[CCDirector sharedDirector] replaceScene:scene];
}

-(void) startSimulation {
    if(_state == kAppStateEditor){

        _state = kAppStateSimulator;
        
        [self saveCurrentProject];
        
        THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
        THSimulator * simulator = [THSimulator node];
        
        [self switchToLayer:simulator];
        
        lastEditorZoomableLayerPosition = editor.zoomableLayer.position;
        lastEditorZoom = editor.zoomLevel;
        
        simulator.zoomLevel = editor.zoomLevel;
        simulator.zoomableLayer.position = editor.zoomableLayer.position;
        
        [self hideTabBar];
        
        [self addSimulationButtons];
        
        THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
        project.iPhone.visible = YES;

        [self updatePalettePullVisibility];
        [self addPalettePullGestureRecognizer];
        [self updatePinsModeItemTint];
    }
}

-(void) endSimulation {
    if(_state == kAppStateSimulator){
        
        _state = kAppStateEditor;
        
        [self restoreCurrentProject];
        
        THEditor * editor = [THEditor node];
        
        editor.dragDelegate = self.tabController.paletteController;
        [self switchToLayer:editor];
        
        editor.zoomableLayer.position = lastEditorZoomableLayerPosition;
        editor.zoomLevel = lastEditorZoom;
        
        [self updateEditingButtonsTint];
        
        _tabController.paletteController.delegate = editor;
        
        [self showTabBar];
        [self addEditionButtons];
        [self updatePalettePullVisibility];
        [self removePalettePullRecognizer];
        [self updateHideIphoneButtonTint];
    }
}

- (void)toggleAppState {
    if(_state == kAppStateEditor){
        [self startSimulation];
    } else{
        [self endSimulation];
    }
}

#pragma mark - View Lifecycle

-(void) reloadContent{
    [self.tabController.paletteController reloadPalettes];
}

-(void) addBarButtonWithImageName:(NSString*) imageName{
    
    //UIImage * image = [UIImage imageNamed:@"play.png"];
}

#pragma mark - Gesture Recognizer

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

#pragma mark - Tools

-(UIBarButtonItem*) createDivider{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 44)];
    label.backgroundColor = [UIColor blackColor];
    return [[UIBarButtonItem alloc] initWithCustomView:label];
}

-(UIBarButtonItem*) createEmptyItem{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 44)];
    label.backgroundColor = [UIColor clearColor];
    return [[UIBarButtonItem alloc] initWithCustomView:label];
}

-(UIBarButtonItem*) createItemWithImageName:(NSString*) imageName action:(SEL) selector{
    
    UIImage * connectButtonImage = [UIImage imageNamed:imageName];
    return [[UIBarButtonItem alloc] initWithImage:connectButtonImage style:UIBarButtonItemStylePlain target:self action:selector];
}

-(void) loadTools{
    
    self.divider = [self createDivider];
    self.divider2 = [self createDivider];
    self.emptyItem1 = [self createEmptyItem];
    self.emptyItem2 = [self createEmptyItem];
    
    self.connectButton = [self createItemWithImageName:@"connect.png" action:@selector(connectPressed:)];
    self.duplicateButton = [self createItemWithImageName:@"duplicate.png" action:@selector(duplicatePressed:)];
    self.removeButton = [self createItemWithImageName:@"delete.png" action:@selector(removePressed:)];
    self.pushButton = [self createItemWithImageName:@"push.png" action:@selector(pushPressed:)];
    self.lilypadButton = [self createItemWithImageName:@"lilypadmode.png" action:@selector(lilypadPressed:)];
    self.pinsModeButton = [self createItemWithImageName:@"pinsmode.png" action:@selector(pinsModePressed:)];
    self.hideiPhoneButton = [self createItemWithImageName:@"hideiphone.png" action:@selector(hideiPhonePressed:)];
    
    self.playButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                       target:self
                       action:@selector(startSimulation)];
    
    self.stopButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                       target:self
                       action:@selector(endSimulation)];
    
    self.editingTools = [NSArray arrayWithObjects:self.playButton, self.pushButton, self.divider2, self.hideiPhoneButton, self.lilypadButton, self.divider, self.removeButton, self.duplicateButton, self.connectButton, nil];
    
    self.simulatingTools = [NSArray arrayWithObjects:self.stopButton, self.emptyItem1, self.pinsModeButton, nil];
    
    self.lilypadTools = [NSArray arrayWithObjects:self.playButton, self.pushButton, self.divider2, self.emptyItem2, self.lilypadButton, self.divider, self.removeButton, self.duplicateButton, self.connectButton, nil];
    
    self.highlightedItemTintColor = nil;
    self.hideiPhoneButton.tintColor = self.highlightedItemTintColor;
    self.unselectedTintColor = [UIColor grayColor];
    
    id c = [NSNotificationCenter defaultCenter];
    [c addObserver:self selector:@selector(handleEditableObjectAdded:) name:kNotificationObjectAdded object:nil];
    
}

-(void) addEditionButtons{
    
    self.navigationItem.rightBarButtonItems = self.editingTools;
}

-(void) addLilypadButtons{
    
    self.navigationItem.rightBarButtonItems = self.lilypadTools;
}

-(void) addSimulationButtons{
    
    self.navigationItem.rightBarButtonItems = self.simulatingTools;
}

-(void) handleEditableObjectAdded:(NSNotification*) notification{
    TFEditableObject * object = notification.object;
    
    if([object isKindOfClass:[THiPhoneEditableObject class]]){
        
        [self updateHideIphoneButtonTint];
    }
}

//editing
-(void) unselectAllEditingButtons{
    self.connectButton.tintColor = self.unselectedTintColor;
    self.duplicateButton.tintColor = self.unselectedTintColor;
    self.removeButton.tintColor = self.unselectedTintColor;
    self.hideiPhoneButton.tintColor = self.unselectedTintColor;
    self.lilypadButton.tintColor = self.unselectedTintColor;
}

-(void) updateEditingButtonsTint{
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    
    [self unselectAllEditingButtons];
    
    if(editor.state == kEditorStateConnect){
        self.connectButton.tintColor = self.highlightedItemTintColor;
    } else if(editor.state == kEditorStateDuplicate){
        self.duplicateButton.tintColor = self.highlightedItemTintColor;
    } else if(editor.state == kEditorStateDelete){
        self.removeButton.tintColor = self.highlightedItemTintColor;
    }
    
    [self updatePushButtonState];
    [self updateHideIphoneButtonTint];
    [self updateLilypadTint];
}

-(void) updatePushButtonState{
    THDirector * director = [THDirector sharedDirector];
    self.pushButton.enabled = (director.serverController.peers.count > 0);
}


-(void) updateHideIphoneButtonTint{
    
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    self.hideiPhoneButton.tintColor = (project.iPhone.visible ? self.highlightedItemTintColor : self.unselectedTintColor);
}

-(void) updateLilypadTint{
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    self.lilypadButton.tintColor = (editor.isLilypadMode ? self.highlightedItemTintColor : self.unselectedTintColor);
}

//simulation
-(void) updatePinsModeItemTint{
    
    THSimulator * simulator = (THSimulator*) [THDirector sharedDirector].currentLayer;
    self.pinsModeButton.tintColor = (simulator.state == kSimulatorStatePins ? self.highlightedItemTintColor : self.unselectedTintColor);
}

-(void) checkSwitchToState:(TFEditorState) state{
    THProjectViewController * projectController = [THDirector sharedDirector].projectController;
    if(projectController.state == kAppStateEditor){
        THEditor * editor = (THEditor*) projectController.currentLayer;
        if(editor.state == state){
            editor.state = kEditorStateNormal;
        } else {
            editor.state = state;
        }
        [self updateEditingButtonsTint];
    }
}

//actions
- (void)connectPressed:(id)sender {
    [self checkSwitchToState:kEditorStateConnect];
}

- (void)duplicatePressed:(id)sender {
    
    [self checkSwitchToState:kEditorStateDuplicate];
}

- (void)removePressed:(id)sender {
    [self checkSwitchToState:kEditorStateDelete];
}
/*
-(void) setHidden:(BOOL)hidden{
    if(!hidden){
        [self unselectAllButtons];
    }
    self.view.hidden = hidden;
}

-(BOOL) hidden{
    return self.view.hidden;
}*/

- (void) lilypadPressed:(id)sender {
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    if(editor.isLilypadMode){
        [editor stopLilypadMode];
        
        [self checkSwitchToState:kEditorStateNormal];
        [self addEditionButtons];
        
    } else {
        [editor startLilypadMode];
        [self addLilypadButtons];
    }
    
    [self updateLilypadTint];
}

- (void) pinsModePressed:(id)sender {
    THSimulator * simulator = (THSimulator*) [THDirector sharedDirector].currentLayer;
    
    if(simulator.state == kSimulatorStateNormal){
        [simulator addPinsController];
    } else {
        [simulator removePinsController];
    }
    
    [self updatePinsModeItemTint];
}

- (void) pushPressed:(id)sender {
    THServerController * serverController = [THDirector sharedDirector].serverController;
    if(serverController.serverIsRunning){
        THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
        [serverController pushProjectToAllClients:project];
    }
}

- (void) hideiPhonePressed:(id)sender {
    
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    project.iPhone.visible = !project.iPhone.visible;
    [self updateHideIphoneButtonTint];
    
    THEditor * editor = (THEditor*) [THDirector sharedDirector].currentLayer;
    [editor handleIphoneVisibilityChangedTo:project.iPhone.visible ];
}


-(NSString*) description{
    return @"ProjectController";
}

-(void) dealloc{
    if ([@"YES" isEqualToString: [[[NSProcessInfo processInfo] environment] objectForKey:@"printUIDeallocs"]]) {
        NSLog(@"deallocing %@",self);
    }
}

@end
