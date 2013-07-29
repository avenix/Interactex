
#import "THProjectViewController.h"
#import "THProjectViewController.h"
#import "THEditorToolsViewController.h"
#import "THEditorToolsDataSource.h"
#import "TFTabbarViewController.h"
#import "TFSimulator.h"

@implementation THProjectViewController

#pragma mark - Initialization

- (id)init{
    self = [super init];
    if(self){
        CGRect rect = CGRectMake(0, 0, 1024, 768);
        self.view = [[UIView alloc] initWithFrame:rect];
        
        [self initCocos2d];

        _tabController = [[TFTabbarViewController alloc] initWithNibName:@"TFTabbar" bundle:nil];
        _toolsController = [[THEditorToolsViewController alloc] initWithNibName:@"TFEditorToolsViewController" bundle:nil];
        _barButtonItems = [NSMutableArray array];
        
        _playButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                       target:self
                       action:@selector(startSimulation)];
        
        _stopButton = [[UIBarButtonItem alloc]
                       initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                       target:self
                       action:@selector(endSimulation)];
        
        
        [self.view addSubview:_tabController.view];
        
        [self addTools];
        [self addPlayButton];
        [self addTapRecognizer];
        
        [self viewDidLoad];
        
    }
    return self;
}

-(void) load{
    
    [self initCocos2d];
}

#pragma mark - Title

-(void) addTapRecognizer{

    UITapGestureRecognizer *tapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
	[tapRecognizer setNumberOfTapsRequired:1];
    tapRecognizer.cancelsTouchesInView = NO;
	[self.view addGestureRecognizer:tapRecognizer];
}

-(void) tapped{
    if(self.editingSceneName){
        [_titleTextField resignFirstResponder];
    }
}

-(NSString*) title{
    TFProject * project = [TFDirector sharedDirector].currentProject;
    return project.name;
}

-(void) removeTitleLabel{
    self.navigationItem.titleView = nil;
}

-(void) addTitleLabel{
    TFProject * project = [TFDirector sharedDirector].currentProject;
    if(!_titleLabel){
        _titleLabel = [TFHelper navBarTitleLabelNamed:project.name];
        _titleLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startEditingSceneName)];
        [_titleLabel addGestureRecognizer:tapRecognizer];
        
    } else {
        _titleLabel.text = project.name;
    }
    self.navigationItem.titleView = _titleLabel;
}

-(void) addTitleTextField{
    if(!_titleTextField){
        _titleTextField =  [[UITextField alloc] init];
        _titleTextField.frame = _titleLabel.frame;
        _titleTextField.font = _titleLabel.font;
        _titleTextField.textAlignment = _titleLabel.textAlignment;
        _titleTextField.textColor = _titleLabel.textColor;
        _titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _titleTextField.layer.borderWidth = 1.0f;
        _titleTextField.layer.borderColor = [UIColor grayColor].CGColor;
        _titleTextField.delegate = self;
    }
    
    TFProject * project = [TFDirector sharedDirector].currentProject;
    _titleTextField.text = project.name;
    self.navigationItem.titleView = _titleTextField;
    [_titleTextField becomeFirstResponder];
}

-(BOOL) keyboardHidden{
    if(self.editingSceneName){
        [self stopEditingSceneName];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_titleTextField resignFirstResponder];
    return NO;
}

-(void) stopEditingSceneName{
    [[THDirector sharedDirector] renameCurrentProjectToName:_titleTextField.text];
    
    [self addTitleLabel];
    _editingSceneName = NO;
}

-(void) startEditingSceneName{
    [self addTitleTextField];
    _editingSceneName = YES;
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

-(void)hideTools
{
    _toolsController.hidden = YES;
}

-(void)showTools
{
    _toolsController.hidden = NO;
}

#pragma mark - Cocos2D

-(void) initCocos2d {
    if(!_cocos2dInit){
        if(![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
            [CCDirector setDirectorType:kCCDirectorTypeNSTimer];
        CCDirector * director = [CCDirector sharedDirector];
        [director setDeviceOrientation:kCCDeviceOrientationPortrait];
        [director setDisplayFPS:NO];
        [director setAnimationInterval:1.0/30];
        
        _glview = [EAGLView viewWithFrame:CGRectMake(0, 0, 1024, 768)
                              pixelFormat:kEAGLColorFormatRGB565
                              depthFormat:0 // GL_DEPTH_COMPONENT24_OES
                       preserveBackbuffer:NO
                               sharegroup:nil
                            multiSampling:NO
                          numberOfSamples:0];
        [director setOpenGLView:_glview];
        [_glview setMultipleTouchEnabled:YES];
        
        if(![director enableRetinaDisplay:YES] )
            CCLOG(@"Retina Display Not supported");
        _cocos2dInit = YES;
        
        [self.view addSubview:_glview];
        [self.view sendSubviewToBack:_glview];
    }
}

-(void) endCocos2d{
    
	CCDirector * director = [CCDirector sharedDirector];
    [director stopAnimation];
    [director end];
    [_glview removeFromSuperview];
    _glview = nil;
}

#pragma mark - Simulation

-(void) startWithEditor{
    TFEditor * editor = [[THDirector sharedDirector].projectDelegate customEditor];
    editor.dragDelegate = self.tabController.paletteController;
    _currentLayer = editor;
    [_currentLayer willAppear];
    CCScene * scene = [CCScene node];

    [scene addChild:_currentLayer];
    [[CCDirector sharedDirector] runWithScene:scene];
    
    _tabController.paletteController.delegate = editor;
    _state = kAppStateEditor;
}

-(void) switchToLayer:(TFLayer*) layer{
    [_currentLayer willDisappear];

    _currentLayer = layer;
    [_currentLayer willAppear];
    CCScene * scene = [CCScene node];
    [scene addChild:_currentLayer];
    
    if(![CCDirector sharedDirector].runningScene){
        [[CCDirector sharedDirector] runWithScene:scene];
    } else {
        [[CCDirector sharedDirector] replaceScene:scene];
    }
}

-(void) startSimulation {
    if(_state == kAppStateEditor){

        _state = kAppStateSimulator;
        
        [[THDirector sharedDirector] saveCurrentProject];
                
        TFSimulator * simulator = [[THDirector sharedDirector].projectDelegate customSimulator];
        [self switchToLayer:simulator];
        
        [self hideTabBar];
        [self hideTools];
        [self addSimulationButtons];
    }
}

-(void) endSimulation {
    if(_state == kAppStateSimulator){
        
        _state = kAppStateEditor;
        
        [[THDirector sharedDirector] restoreCurrentProject];
        
        TFEditor * editor = [[THDirector sharedDirector].projectDelegate customEditor];
        editor.dragDelegate = self.tabController.paletteController;
        [self switchToLayer:editor];
        
        _tabController.paletteController.delegate = editor;
        
        [self showTabBar];
        [self showTools];
        [self addEditionButtons];
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
    [self reloadBarButtonItems];
}

-(void) addBarButtonWithImageName:(NSString*) imageName{
    
    //UIImage * image = [UIImage imageNamed:@"play.png"];
}

-(void) reloadBarButtonItems{
    
    self.navigationItem.rightBarButtonItems = _barButtonItems;
}

-(void) addCustomBarButtons {
    
    if(_barButtonItems.count <= 1){
        
        THEditorToolsDataSource * dataSource = [THDirector sharedDirector].editorToolsDataSource;
        NSInteger count = [dataSource numberOfToolbarButtonsForState:self.state];
        for (int i = 0; i < count; i++) {
            UIBarButtonItem * item = [dataSource toolbarButtonAtIdx:i forState:self.state];
            [_barButtonItems addObject:item];
        }
    }
}

-(void) addTools{
    
    CGRect frame = _toolsController.view.frame;
    _toolsController.view.center = ccp(1024 - frame.size.width / 2.0f, 768 - frame.size.height / 2.0f);
    [self.view addSubview:_toolsController.view];
}

-(void) addPlayButton {

    [_barButtonItems insertObject:_playButton atIndex:0];

    self.navigationItem.rightBarButtonItems = _barButtonItems;
}

-(void) addStopButton {
    
    [_barButtonItems insertObject:_stopButton atIndex:0];
    
    self.navigationItem.rightBarButtonItems = _barButtonItems;
}

-(void) addEditionButtons{
    [_barButtonItems removeAllObjects];
    [_barButtonItems addObject:_playButton];
    [self addCustomBarButtons];
    [self reloadBarButtonItems];
}

-(void) addSimulationButtons{
    
    [_barButtonItems removeAllObjects];
    [_barButtonItems addObject:_stopButton];
    [self addCustomBarButtons];
    [self reloadBarButtonItems];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardHidden) name:UIKeyboardWillHideNotification object:nil];
    
    [self showTabBar];
    [self showTools];
    
    [self addEditionButtons];
    [self addTitleLabel];
    [self reloadContent];
    [self startWithEditor];
}

-(void) cleanUp{
    [_currentLayer prepareToDie];
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
    
    [[CCDirector sharedDirector] popScene];
    [[CCDirector sharedDirector] end];
    //[[CCDirector sharedDirector] stopAnimation];
    //[_currentLayer removeAllChildrenWithCleanup:YES];
    
    [_glview removeFromSuperview];
    _glview = nil;
    _currentLayer = nil;
    _currentScene = nil;
    _cocos2dInit = NO;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self cleanUp];
    [self.toolsController unselectAllButtons];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
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