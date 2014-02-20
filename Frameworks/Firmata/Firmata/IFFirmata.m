/*
IFFirmata.m
IFFirmata

Created by Juan Haladjian on 08/09/2013.

IFFirmata is a library used to control an Arduino board based on the Firmata protocol: www.firmata.org
 
www.interactex.org
 
 Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
 
 Contacts:
 juan.haladjian@cs.tum.edu
 katharina.bredies@udk-berlin.de
 opensource@telekom.de
 
 
 It has been created with funding from EIT ICT, as part of the activity "Connected Textiles".
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "IFFirmata.h"
#import "IFFirmataCommunicationModule.h"

#define START_SYSEX             0xF0
#define END_SYSEX               0xF7
#define PIN_MODE_QUERY          0x72
#define PIN_MODE_RESPONSE       0x73
#define PIN_STATE_QUERY         0x6D
#define PIN_STATE_RESPONSE      0x6E
#define CAPABILITY_QUERY        0x6B
#define CAPABILITY_RESPONSE     0x6C
#define ANALOG_MAPPING_QUERY    0x69
#define ANALOG_MAPPING_RESPONSE 0x6A
#define REPORT_FIRMWARE         0x79
#define I2C_CONFIG              0x78
#define I2C_REQUEST             0x76
#define I2C_REPLY               0x77
#define I2C_READ_CONTINUOUSLY   0b00010000
#define I2C_WRITE               0b00000000
#define I2C_READ                0b00001000
#define I2C_STOP_READING        0b00011000
#define SYSTEM_RESET            0xFF

@implementation IFFirmata

-(void) reset{
    parseCommandLength = 0;
    parseCount = 0;
    
    for (int i = 0; i < IFParseBufSize; i++) {
        parseBuf[i] = 0;
    }
    
    waitingForFirmware = NO;
}

#pragma mark - Send Messages

-(void) sendFirmwareRequest{
    
    waitingForFirmware = YES;
    
    uint8_t buf[3];
    buf[0] = START_SYSEX;
    buf[1] = REPORT_FIRMWARE;
    buf[2] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:3];
    //[self.bleService sendData:buf count:3];
}

-(void) sendAnalogMappingRequest{
    NSInteger len = 0;
    
    uint8_t buf[3];
    
    buf[len++] = START_SYSEX;
    buf[len++] = ANALOG_MAPPING_QUERY;
    buf[len++] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:3];
}

-(void) sendCapabilitiesRequest{
    
    NSInteger len = 0;
    uint8_t buf[3];
    
    buf[len++] = START_SYSEX;
    buf[len++] = CAPABILITY_QUERY;
    buf[len++] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:3];
}

-(void) sendReportRequestsForDigitalPins{
    
    NSInteger len = 0;
    uint8_t buf[6];
    
    for (int i=0; i<3; i++) {
        buf[len++] = 0xD0 | i;
        buf[len++] = 1;
    }
    
    [self.communicationModule sendData:buf count:3];
}

-(void) sendPinQueryForPinNumbers:(NSInteger*) pinNumbers length:(NSInteger) length{
    
    uint8_t buf[length * 4];
    NSInteger bufLength = 0;
    
    for (int i = 0; i < length; i++) {
        
        buf[bufLength++] = START_SYSEX;
        buf[bufLength++] = PIN_STATE_QUERY;
        buf[bufLength++] = pinNumbers[i];
        buf[bufLength++] = END_SYSEX;
        
    }
    
    [self.communicationModule sendData:buf count:bufLength];
//    [self.bleService sendData:buf count:bufLength];
}

-(void) sendPinModeRequestForPin:(NSInteger) pinNumber{
    
    uint8_t buf[4];
    buf[0] = START_SYSEX;
    buf[1] = PIN_STATE_QUERY;
    buf[2] = pinNumber;
    buf[3] = END_SYSEX;
    
    
    [self.communicationModule sendData:buf count:4];
//    [self.bleService sendData:buf count:4];
}

-(void) sendResetRequest{
    
    uint8_t msg = SYSTEM_RESET;
    
    [self.communicationModule sendData:&msg count:1];
//    [self.bleService sendData:&msg count:1];
}

-(void) sendPinModeForPin:(NSInteger) pin mode:(IFPinMode) mode {
    
	if (pin >= 0 && pin < 128){
        
		uint8_t buf[3];
        
		buf[0] = 0xF4;
		buf[1] = pin;
		buf[2] = mode;
        
        [self.communicationModule sendData:buf count:3];
        //[self.bleService sendData:buf count:3];
    }
}

-(void) sendDigitalOutputForPort:(NSInteger) port value:(NSInteger) value{
    
    uint8_t buf[3];
    buf[0] = 0x90 | port;
    buf[1] = value & 0x7F;
    buf[2] = (value >> 7) & 0x7F;
    
    [self.communicationModule sendData:buf count:3];
}

-(void) sendDigitalOutputForPin:(NSInteger) pin value:(NSInteger) value{
    
}

-(void) sendAnalogOutputForPin:(NSInteger) pin value:(NSInteger) value{
    
	if (pin <= 15 && value <= 16383) {
		uint8_t buf[3];
		buf[0] = 0xE0 | pin;
		buf[1] = value & 0x7F;
		buf[2] = (value >> 7) & 0x7F;
        
        
        [self.communicationModule sendData:buf count:3];
//        [self.bleService sendData:buf count:3];
        
	}
    
    //no extended analog support yet
    /*else {
     uint8_t buf[9];
     int len=4;
     buf[0] = START_SYSEX;
     buf[1] = 0x6F;
     buf[2] = pin.number;
     buf[3] = pin.value & 0x7F;
     if (pin.value > 0x00000080) buf[len++] = (pin.value >> 7) & 0x7F;
     if (pin.value > 0x00004000) buf[len++] = (pin.value >> 14) & 0x7F;
     if (pin.value > 0x00200000) buf[len++] = (pin.value >> 21) & 0x7F;
     if (pin.value > 0x10000000) buf[len++] = (pin.value >> 28) & 0x7F;
     buf[len++] = 0xF7;
     
     [self.bleService sendData:buf count:9];
     }*/
}

-(void) sendReportRequestForAnalogPin:(NSInteger) pin reports:(BOOL) reports{
    
    uint8_t buf[2];
    buf[0] = 0xC0 | pin;
    buf[1] = reports;
    
    [self.communicationModule sendData:buf count:2];
    //[self.communicationModule sendData:buf count:2];
}


-(void) sendI2CStartReadingAddress:(NSInteger) address reg:(NSInteger) reg size:(NSInteger) size{
    
    [self checkStartI2C];
    
    uint8_t buf[9];
    buf[0] = START_SYSEX;
    buf[1] = I2C_REQUEST;
    buf[2] = address;//compass address = 24
    buf[3] = I2C_READ_CONTINUOUSLY;
    buf[4] = reg;//compass register = 40
    buf[5] = 1;
    buf[6] = size;//6 bytes to read
    buf[7] = 0;
    buf[8] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:9];
    //[self.communicationModule sendData:buf count:9];
}

-(void) sendI2CStopReadingAddress:(NSInteger) address{
    
    uint8_t buf[5];
    buf[0] = START_SYSEX;
    buf[1] = I2C_REQUEST;
    buf[2] = address;
    buf[3] = I2C_STOP_READING;
    buf[4] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:5];
    //[self.communicationModule sendData:buf count:5];
}

-(void) sendI2CWriteToAddress:(NSInteger) address reg:(NSInteger) reg bytes:(uint8_t*) bytes numBytes:(NSInteger) numBytes{
    
    [self checkStartI2C];
    
    uint8_t buf[7 + numBytes];
    NSInteger bufCount = 0;
    buf[bufCount++] = START_SYSEX;
    buf[bufCount++] = I2C_REQUEST;
    buf[bufCount++] = address;//compass address = 24
    buf[bufCount++] = I2C_WRITE;
    buf[bufCount++] = reg;//compass register = 40
    buf[bufCount++] = 0;
    memcpy(buf + bufCount, bytes, numBytes);
    bufCount += numBytes;
    buf[bufCount++] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:bufCount];
    //[self.communicationModule sendData:buf count:9];
}

-(void) checkStartI2C{
    
    if(!self.startedI2C){
        _startedI2C = YES;
        [self sendI2CConfigMessage];
    }
}

-(void) sendI2CConfigMessage{
    
    uint8_t buf[5];
    buf[0] = START_SYSEX;
    buf[1] = I2C_CONFIG;
    buf[2] = 0;
    buf[3] = 0;
    buf[4] = END_SYSEX;
    
    [self.communicationModule sendData:buf count:5];
    //[self.communicationModule sendData:buf count:5];
}

#pragma mark - Receive Messages

-(void) handleMessage{
    
	uint8_t cmd = (parseBuf[0] & START_SYSEX);
    
	if (cmd == 0xE0 && parseCount == 3) {
        
        int channel = (parseBuf[0] & 0x0F);
        int value = parseBuf[1] | (parseBuf[2] << 7);
        
        if([self.delegate respondsToSelector:@selector(firmataController:didReceiveAnalogMessageOnChannel:value:)]){
            [self.delegate firmataController:self didReceiveAnalogMessageOnChannel:channel value:value];
        }
        
	} else if (cmd == 0x90 && parseCount == 3) {
        
        int portNum = (parseBuf[0] & 0x0F);
        int portVal = parseBuf[1] | (parseBuf[2] << 7);
        int port = portNum * 8;
        
        if([self.delegate respondsToSelector:@selector(firmataController:didReceiveDigitalMessageForPort:value:)]){ 
            [self.delegate firmataController:self didReceiveDigitalMessageForPort:port value:portVal];
        }
        
	} else if (parseBuf[0] == START_SYSEX && parseBuf[parseCount-1] == END_SYSEX) {
        
		if (parseBuf[1] == REPORT_FIRMWARE) {
            
            char name[140];
            int len=0;
            for (int i = 4; i < parseCommandLength-2; i += 2) {
                name[len++] = (parseBuf[i] & 0x7F)
                | ((parseBuf[i+1] & 0x7F) << 7);
            }
            name[len++] = '-';
            name[len++] = parseBuf[2] + '0';
            name[len++] = '.';
            name[len++] = parseBuf[3] + '0';
            name[len++] = 0;
            self.firmwareName = [NSString stringWithUTF8String:name];
            
            if([self.delegate respondsToSelector:@selector(firmataController:didReceiveFirmwareName:)]){
                [self.delegate firmataController:self didReceiveFirmwareName:self.firmwareName];
            }
            
		} else if (parseBuf[1] == CAPABILITY_RESPONSE) {
            
            if([self.delegate respondsToSelector:@selector(firmataController:didReceiveCapabilityResponse:length:)]){
                [self.delegate firmataController:self didReceiveCapabilityResponse:parseBuf length:parseCommandLength];
            }
            
		} else if (parseBuf[1] == ANALOG_MAPPING_RESPONSE) {
            
            if([self.delegate respondsToSelector:@selector(firmataController:didReceiveAnalogMappingResponse:length:)]){
                [self.delegate firmataController:self didReceiveAnalogMappingResponse:parseBuf length:parseCommandLength];
            }
            
		} else if (parseBuf[1] == PIN_STATE_RESPONSE && parseCount >= 6) {
            
            if([self.delegate respondsToSelector:@selector(firmataController:didReceivePinStateResponse:length:)]){
                [self.delegate firmataController:self didReceivePinStateResponse:parseBuf length:parseCommandLength];
            }
            
		} else if(parseBuf[1] == I2C_REPLY){
            
            if([self.delegate respondsToSelector:@selector(firmataController:didReceiveI2CReply:length:)]){
                [self.delegate firmataController:self didReceiveI2CReply:parseBuf length:parseCommandLength];
            }
        }
	}
}

-(void) cleanAddedBytes:(uint8_t *)buffer lenght:(NSInteger*)originalLength{
    
    int length = *originalLength;
    
    //remove all END_SYSEX messages at the end of the buffer
    for (int i = 15; i >= 0; i--) {
        if(buffer[i] != END_SYSEX){
            break;
        }
        length --;
    }
    
    //check if we had started a sysex somewhere
    for (int i = 0; i < length; i++) {
        if(buffer[i] == START_SYSEX){
            startedSysex = YES;
        } else if (buffer[i] == END_SYSEX ){
            startedSysex = NO;
        }
    }
    
    //restore the wrongly removed sysex at the end
    if(length < *originalLength && startedSysex){
        buffer[length++] = END_SYSEX;
        startedSysex = NO;
    }
    *originalLength = length;
}

-(void) didReceiveData:(uint8_t *)buffer lenght:(NSInteger)originalLength{
    
    printf("before:\n");
    for (int i = 0 ; i < originalLength; i++) {
        int value = buffer[i];
        printf("%d ",value);
    }
    printf("\n");
    
    UInt16 k = buffer[14];
    k<<=8;
    k = k | buffer[15];
    
    
    printf("endnr: %i\n",k);
    
    if(self.communicationModule.usesFillBytes){
        [self cleanAddedBytes:buffer lenght:&originalLength];
    }
    
    NSInteger length = originalLength;
    
    printf("receiving:\n");
    for (int i = 0 ; i < length; i++) {
        int value = buffer[i];
        printf("%d ",value);
    }
    printf("\n");
    
    for (int i = 0 ; i < length; i++) {
        uint8_t value = buffer[i];
        
		uint8_t msn = value & START_SYSEX;
		if (msn == 0xE0 || msn == 0x90 || value == 0xF9) {//digital / analog pin, or protocol version
			parseCommandLength = 3;
			parseCount = 0;
		} else if (msn == 0xC0 || msn == 0xD0) {
			parseCommandLength = 2;
			parseCount = 0;
		} else if (value == START_SYSEX) {
			parseCount = 0;
			parseCommandLength = sizeof(parseBuf);
		} else if (value == END_SYSEX) {
			parseCommandLength = parseCount + 1;
		} else if (value & 0x80) {
			parseCommandLength = 1;
			parseCount = 0;
		}
		if (parseCount < (int)sizeof(parseBuf)) {
			parseBuf[parseCount++] = value;
		}
		if (parseCount == parseCommandLength) {
			[self handleMessage];
			parseCount = 0;
            parseCommandLength = 0;
		}
	}
}

@end
