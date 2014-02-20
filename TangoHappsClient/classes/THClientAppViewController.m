/*
THClientAppViewController.m
Interactex Client

Created by Juan Haladjian on 10/07/2013.

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

#import "THClientAppViewController.h"
#import "THSimulableWorldController.h"
#import "THClientProject.h"

#import "THView.h"
#import "THiPhone.h"
#import "THClientProjectProxy.h"

#import "THLilyPad.h"
#import "THBoardPin.h"
#import "THPinValue.h"
#import "THElementPin.h"
#import "THCompassLSM303.h"
#import "THI2CComponent.h"
#import "THI2CRegister.h"

#import "THLabel.h"
#import "THBLECommunicationModule.h"
#import "THJennic.h"
#import "IFFirmata.h"
#import "THI2CMessage.h"

float const kScanningTimeout = 3.0f;
float const kConnectingTimeout = 7.0f;

@implementation THClientAppViewController
/*
-(void) pushLilypadStateToAllVirtualClients{
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    NSArray * lilypins = project.lilypad.pins;
    NSMutableArray * pins = [NSMutableArray array];
    
    for (THBoardPin * pin in lilypins) {
        if(pin.mode == kPinModeDigitalOutput && pin.hasChanged){
            THPinValue * pinValue = [[THPinValue alloc] init];
            pinValue.type = pin.type;
            pinValue.value = pin.currentValue;
            pinValue.number = pin.number;
 
            //dont send if value is reserved for protocol (change protocol in future)
            [pins addObject:pinValue];
            pin.hasChanged = NO;
            
            NSLog(@"iPad sending %d %d",pin.number,pin.currentValue);
        }
    }
    
    [_transferAgent queueAction:kTransferActionPinState withObject:pins];
}*/

/*
-(void) pushLilypadStateToRealClient{
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    NSArray * lilypins = project.lilypad.pins;
    
    for (THBoardPin * pin in lilypins) {
        if((pin.mode == kPinModeDigitalOutput || pin.mode == kPinModePWM || pin.mode == kPinModeBuzzer) && pin.hasChanged){
            NSLog(@"ble sending %d %d",pin.number,pin.currentValue);
            
            //if(pin.currentValue != kMsgPinValueStarted && pin.currentValue != kMsgPinModeStarted){
                [_bleService outputPin:pin.number value:pin.currentValue];
            //}
            pin.hasChanged = NO;
        }
    }
}
*/

-(NSString*) title{
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    return project.name;
}

-(void) loadUIObjects{
        
    THiPhone * iPhone = self.currentProject.iPhone;
    
    CGSize size = iPhone.currentView.view.frame.size;
    
    self.view = iPhone.currentView.view;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    THIPhoneType type = screenHeight < 500;
    CGFloat viewHeight = self.view.bounds.size.height;
    
    //CGFloat navigationBarOffset = screenHeight - viewHeight;
    
    for (THView * object in self.currentProject.iPhoneObjects) {

        if(!self.showingPreset){
/*
            NSLog(@"pos y: %f",object.position.y);
            NSLog(@"iphone pos y: %f",iPhone.position.y);*/
            
            float relx = (object.position.x - iPhone.position.x + size.width/2) / kiPhoneFrames[type].size.width;
            float rely = (object.position.y - iPhone.position.y + size.height/2) / kiPhoneFrames[type].size.height;
            
            CGPoint translatedPos = CGPointMake(relx * screenWidth ,rely * viewHeight);
            
            object.position = translatedPos;
        }
        
        [object addToView:self.view];
    }
}

-(void) stopActivityIndicator {
    
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1.0f;
    if(_activityIndicator != nil){
        [_activityIndicator removeFromSuperview];
        _activityIndicator = nil;
    }
}

-(void) startActivityIndicator {
    
    self.view.userInteractionEnabled = NO;
    
    self.view.alpha = 0.5f;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    _activityIndicator.center = self.view.center;
    [_activityIndicator startAnimating];
    
    [self.view addSubview:_activityIndicator];
}

-(void) viewDidLoad{
    
    [super viewDidLoad];
    
    [BLEDiscovery sharedInstance].discoveryDelegate = self;
    [BLEDiscovery sharedInstance].peripheralDelegate = self;
    
    self.firmataController = [[IFFirmata alloc] init];
    self.firmataController.delegate = self;
    
}

-(void) viewWillAppear:(BOOL)animated{
    
    self.currentProject = [THSimulableWorldController sharedInstance].currentProject;
    
    if(self.currentProject){
        
        if([BLEDiscovery sharedInstance].foundPeripherals.count == 0){
            [self updateStartButtonToScan];
        } else {
            [self updateStartButtonToStart];
        }
        
        [self setTitle:self.currentProject.name];
        
        [self loadUIObjects];
        [self addPinObservers];
        
        //[self updateStartButton];
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    /*
    if(!self.showingPreset){
        UIImage * image = [THUtils screenshot];
        THClientProjectProxy * proxy = [THSimulableWorldController sharedInstance].currentProjectProxy;
        proxy.image = image;
    }*/
    
    [self removePinObservers];
    [self disconnectFromBle];
}

-(void) viewDidDisappear:(BOOL)animated{
    
    [THSimulableWorldController sharedInstance].currentProjectProxy = nil;
    [THSimulableWorldController sharedInstance].currentProject = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark Pins Observing

-(void) addPinObservers{
    
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    
    for (THBoardPin * pin in project.currentBoard.pins) {
        [pin addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(void) removePinObservers{
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    
    for (THBoardPin * pin in project.currentBoard.pins) {
        [pin removeObserver:self forKeyPath:@"value"];
    }
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"value"]){
        
        THBoardPin * pin = object;
                
        if(pin.mode == kPinModeDigitalOutput){
            
            [self sendDigitalOutputForPin:pin];
            
        } else if(pin.mode == kPinModePWM){
            
            [self sendAnalogOutputForPin:pin];
        }
    }
}

#pragma mark Methods

-(void) scanningTimedOut{
    [scanningTimer invalidate];
    scanningTimer = nil;
    [self updateStartButtonToScan];
}

-(void) startScanningDevices{
    
    [self updateStartButtonToScanning];
    [[BLEDiscovery sharedInstance] startScanningForSupportedUUIDs];
    scanningTimer = [NSTimer scheduledTimerWithTimeInterval:kScanningTimeout target:self selector:@selector(scanningTimedOut) userInfo:nil repeats:NO];
}

#pragma mark Ble Interaction

-(void) connectToBle{
    if([BLEDiscovery sharedInstance].foundPeripherals.count > 0){
        CBPeripheral * peripheral = [[BLEDiscovery sharedInstance].foundPeripherals objectAtIndex:0];
        [[BLEDiscovery sharedInstance] connectPeripheral:peripheral];
        isConnecting = YES;
        
        NSTimeInterval interval = kConnectingTimeout;
        connectingTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(connectingTimedOut) userInfo:nil repeats:NO];
    }
}

-(void) connectingTimedOut{
    
    [connectingTimer invalidate];
    connectingTimer = nil;
    
    NSLog(@"stopping connection");
    isConnecting = NO;
    
    if([BLEDiscovery sharedInstance].currentPeripheral){
        [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
    }
    
    shouldScan = YES;
    [self updateStartButtonToScan];
}

-(void) disconnectFromBle{
    
    if([BLEDiscovery sharedInstance].currentPeripheral){
        [[BLEDiscovery sharedInstance].connectedService stop];
        [[BLEDiscovery sharedInstance] disconnectCurrentPeripheral];
    }
}

#pragma mark LeDiscoveryDelegate

- (void) discoveryDidRefresh {
    //[self updateModeButton];
    
    if([BLEDiscovery sharedInstance].foundPeripherals == 0){
        [self updateStartButtonToScan];
    }
}

- (void) peripheralDiscovered:(CBPeripheral*) peripheral {
    NSLog(@"peripheral discovered");
    
    [scanningTimer invalidate];
    scanningTimer = nil;
    
    [self updateStartButtonToStart];
    
    //[self updateStartButton];
    
    //[[LeDiscovery sharedInstance] connectPeripheral:peripheral];
}

- (void) discoveryStatePoweredOff {
    //[self updateStartButton];
    
    NSLog(@"Powered Off");
}


#pragma mark BleServiceProtocol

-(void) updateStartButtonToScan{
    
    self.startButton.tintColor = nil;
    self.startButton.title = @"Scan";
    self.startButton.enabled = YES;
}

-(void) updateStartButtonToScanning{
    
    self.startButton.tintColor = nil;
    self.startButton.title = @"Scanning";
    self.startButton.enabled = NO;
}

-(void) updateStartButtonToStarting{
    
    self.startButton.tintColor = nil;
    self.startButton.title = @"Starting";
    self.startButton.enabled = NO;
}

-(void) updateStartButtonToStop{
    
    self.startButton.tintColor = [UIColor redColor];
    self.startButton.title = @"Stop";
    self.startButton.enabled = YES;
}

-(void) updateStartButtonToStart{
    
    self.startButton.tintColor = nil;
    self.startButton.title = @"Start";
    self.startButton.enabled = YES;
}

-(void) bleServiceDidConnect:(BLEService*) service{
    NSLog(@"connected");
    service.delegate = self;
    service.shouldUseCRC = NO;
    service.shouldUseTurnBasedCommunication = NO;
}

-(void) bleServiceDidDisconnect:(BLEService*) service{
    NSLog(@"disconnected");
    
    //[self startScanningDevices];
    
    [connectingTimer invalidate];
    connectingTimer = nil;
    
    service.delegate = nil;
    service.dataDelegate = nil;
    
    if(isConnecting){
        
        if([BLEDiscovery sharedInstance].foundPeripherals.count > 0){
            NSLog(@"reconnecting");
            [self connectToBle];
        } else {
            [self updateStartButtonToScan];
        }
    } else{
        if([BLEDiscovery sharedInstance].foundPeripherals.count == 0){
            [self updateStartButtonToScan];
        } else {
            [self updateStartButtonToStart];
        }
    }
}

-(void) bleServiceIsReady:(BLEService*) service{
    NSLog(@"is ready");
    
    [self updateStartButtonToStop];
    
    [connectingTimer invalidate];
    connectingTimer = nil;
    
    isConnecting = NO;
    
    THBLECommunicationModule * bleCommunicationModule = [[THBLECommunicationModule alloc] init];
    bleCommunicationModule.bleService = service;
    bleCommunicationModule.firmataController = self.firmataController;
    
    service.dataDelegate = bleCommunicationModule;
    
    self.firmataController.communicationModule = bleCommunicationModule;
    
    self.isRunningProject = YES;
    
    [self.currentProject startSimulating];
    [self.firmataController sendFirmwareRequest];
}

-(void) bleServiceDidReset {
    //_bleService = nil;
}

#pragma mark Sending

-(NSMutableArray*) digitalPinsForBoard:(THBoard*) board{
    NSMutableArray * array = [NSMutableArray array];
    for (THBoardPin * pin in board.pins) {
        if(pin.type == kPintypeDigital){
            [array addObject:pin];
        }
    }
    return array;
}

-(void) sendDigitalOutputForPin:(THBoardPin*) pin{
    
    THBoard * board = [self.currentProject.boards objectAtIndex:0];
    NSMutableArray * digitalPins = [self digitalPinsForBoard:board];
    
    THBoardPin * firstPin = [digitalPins objectAtIndex:0];
    NSInteger firstPinIdx = firstPin.number;
    
    int port = pin.number / 8;
    int value = 0;
    for (int i=0; i < 8; i++) {
        int pinIdx = port * 8 + i - firstPinIdx;

        if(pinIdx >= (int)digitalPins.count){
            break;
        }
        if(pinIdx >= 0){
            THBoardPin * pin = [digitalPins objectAtIndex:pinIdx];
            if (pin.mode == IFPinModeInput || pin.mode == IFPinModeOutput) {
                if (pin.value) {
                    value |= (1<<i);
                }
            }
        }
    }
    
    [self.firmataController sendDigitalOutputForPort:port value:value];
    
}
/*
-(void) sendDigitalOutputForPin:(THBoardPin*) pin{

    [self.firmataController sendDigitalOutputForPin:pin.number value:pin.value];
}*/

-(void) sendAnalogOutputForPin:(THBoardPin*) pin{
    [self.firmataController sendAnalogOutputForPin:pin.number value:pin.value];
}

-(void) sendPinModes{
    
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    
    for (THBoardPin * pin in project.currentBoard.pins) {
        
        if(pin.type == kPintypeDigital && pin.mode != kPinModeUndefined && pin.attachedElementPins.count > 0){
            
            [self.firmataController sendPinModeForPin:pin.number mode:pin.mode];
        }
    }
}

//let the accelerometer send over gmp
-(void) sendI2CRequests{
    
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    
    for (id<THI2CProtocol> component in project.currentBoard.i2cComponents) {

        NSMutableArray * i2cMessages = [component startI2CMessages];
        
        for (THI2CMessage * i2cMessage in i2cMessages) {
            
            switch (i2cMessage.type) {
                    
                case kI2CComponentMessageTypeWrite:

                    [self.firmataController sendI2CWriteToAddress:component.i2cComponent.address reg:i2cMessage.reg bytes:(uint8_t*)i2cMessage.bytes.bytes numBytes:i2cMessage.bytes.length];
                    break;
                    
                case kI2CComponentMessageTypeStartReading:
                    
                    [self.firmataController sendI2CStartReadingAddress:component.i2cComponent.address reg:i2cMessage.reg size:i2cMessage.readSize];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

-(void) sendInputRequests{
    
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    
    for (THBoardPin * pin in project.currentBoard.pins) {
        
        if(pin.attachedElementPins.count > 0){
            
            if(pin.mode == kPinModeDigitalInput && pin.attachedElementPins.count > 0){
                
                [self.firmataController sendReportRequestsForDigitalPins];
                
            } else if(pin.mode == kPinModeAnalogInput && pin.attachedElementPins.count > 0){
                
                [self.firmataController sendReportRequestForAnalogPin:pin.number reports:YES];
            }
        }
    }
}

#pragma mark - GMP Message Handles

-(void) firmataController:(IFFirmata*) firmataController didReceiveFirmwareName:(NSString*) name{
    
    //if([name isEqualToString:kFirmataFirmwareName]){
        [self.firmataController sendResetRequest];
        
        [self sendPinModes];
        [self sendInputRequests];
        [self sendI2CRequests];
    //}
}

-(void) firmataController:(IFFirmata*) firmataController didReceivePinStateResponseForPin:(NSInteger) pin mode:(IFPinMode) mode{
    
    NSLog(@"received mode %d %d",pin,mode);
}

-(void) firmataController:(IFFirmata*) firmataController didReceiveDigitalMessageForPort:(NSInteger) port value:(NSInteger) value{
    
    THBoard * board = [self.currentProject.boards objectAtIndex:0];
    NSMutableArray * digitalPins = [self digitalPinsForBoard:board];
    
    THBoardPin * firstPin = [digitalPins objectAtIndex:0];
    
    int mask = 1;
    int pinNumber = port * 8;
    for (mask <<= firstPin.number; pinNumber < digitalPins.count; mask <<= 1, pinNumber++) {
        int pinIdx = pinNumber - firstPin.number;
        if(pinIdx > 0){
            THBoardPin * pinObj = [digitalPins objectAtIndex:pinIdx];
            if (pinObj.mode == IFPinModeInput) {
                uint32_t val = (value & mask) ? 1 : 0;
                if (pinObj.value != val) {
                    [pinObj removeObserver:self forKeyPath:@"value"];
                    pinObj.value = val;
                    [pinObj addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
                }
            }
        }
    }
}

-(void) firmataController:(IFFirmata *)firmataController didReceiveAnalogMessageOnChannel:(NSInteger)channel value:(NSInteger)value{
    
    NSLog(@"analog msg for pin: %d %d",channel,value);
    
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    THBoardPin * pinObj = [project.currentBoard analogPinWithNumber:channel];//TODO do the mapping channel - pin
    
    [pinObj removeObserver:self forKeyPath:@"value"];
    pinObj.value = value;
    [pinObj addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
}

-(void) firmataController:(IFFirmata*) firmataController didReceiveI2CReply:(uint8_t*) buffer length:(NSInteger) length{
    
    uint8_t address = buffer[2] + (buffer[3] << 7);
    NSInteger registerNumber = buffer[4] + 128;
    
    THClientProject * project = [THSimulableWorldController sharedInstance].currentProject;
    
    if(!self.firmataController.startedI2C){
        
        NSLog(@"reporting but i2c did not start");
        [self.firmataController sendI2CStopReadingAddress:address];
        
    } else {
        
        id<THI2CProtocol> component = [project.currentBoard I2CComponentWithAddress:address];
        
        THI2CRegister * reg = [component.i2cComponent registerWithNumber:registerNumber];
        
        if(reg){
            
            
            [component setValuesFromBuffer:buffer+6 length:length-6];
            
            //NSData * data = [NSData dataWithBytes:values length:size];
            //reg.value = data;
        }
    }
}

#pragma mark UI Interaction

-(IBAction)startButtonTapped:(id)sender {
    
    if([BLEDiscovery sharedInstance].connectedService){
        
        [self.currentProject stopSimulating];
        //[self.firmataController sendResetRequest];
        
        [self disconnectFromBle];
        
    } else {
        
        if([BLEDiscovery sharedInstance].foundPeripherals.count == 0 || shouldScan){
            
            [self startScanningDevices];
            shouldScan = NO;
            
        } else {
            
            [self updateStartButtonToStarting];
            [self connectToBle];
        }
    }
}

@end
