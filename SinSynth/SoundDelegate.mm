//
//  SoundDelegate.m
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SoundDelegate.h"
#import <MacRuby/MacRuby.h>
#include <math.h>

@implementation SoundDelegate

-(id)init{
	self = [super init];
	if (self != nil){
		synth_ = new Synth();
	}
	return self;
}

-(void)midiReceived:(const MIDIPacketList *)packetList{
	NSLog(@"SoundDelegate now received MIDI Event");
	
	MIDIPacket *packet = (MIDIPacket *)&(packetList->packet[0]);
	for (int i = 0 ; i < packetList->numPackets; i++){
		Byte mes = packet->data[0] & 0xF0;
		Byte ch = packet->data[0] & 0x0F;
		
        if ((mes == 0x90) && (packet->data[2] != 0)) {
            NSLog(@"note on number = %2.2x / velocity = %2.2x / channel = %2.2x",
                  packet->data[1], packet->data[2], ch);
			
			Byte noteNumber = packet->data[1];
			Byte velocity = packet->data[2];
			if (velocity > 0){
				synth_->noteOn(noteNumber, velocity);
			}else{
				synth_->noteOff(noteNumber);
			}
			
        } else if (mes == 0x80 || mes == 0x90) {
            NSLog(@"note off number = %2.2x / velocity = %2.2x / channel = %2.2x", 
                  packet->data[1], packet->data[2], ch);
			Byte noteNumber = packet->data[1];
			
			synth_->noteOff(noteNumber);
        } else if (mes == 0xB0) {
            NSLog(@"cc number = %2.2x / data = %2.2x / channel = %2.2x", 
                  packet->data[1], packet->data[2], ch);
        } else {
            NSLog(@"etc");
        }
		
		packet = MIDIPacketNext(packet);
	}	
	
}

-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
{
	//NSLog(@"SoundDelegate now buffer required");
	for (UInt32 i = 0 ; i < sampleNum ; i++){
		float val = synth_->gen();
		SInt16 sint16val = val * SHRT_MAX;
		
		pLeft[i] = sint16val;
		pRight[i] = sint16val;
	}
	synth_->removeEndNotes();
}

@end
