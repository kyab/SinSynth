//
//  SoundDelegate.h
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreMIDI/CoreMIDI.h>

static const int SAMPLING_RATE = 44100;

class SinWaveGenerator{
public:
	SinWaveGenerator(int freq, float gain){
		freq_ = freq;
		gain_ = gain;
		frame_ = 0;
	}
	
	float gen(){
		float current_sec = 1.0 * frame_ / SAMPLING_RATE;
		float omega = 2 * M_PI * freq_;
		float val =gain_* cos( omega * current_sec);
		frame_++;
		
		return val;
	}
	
private:
	int frame_;
	int freq_;
	float gain_;
	
};

@interface SoundDelegate : NSObject{
	id synth_;
	SinWaveGenerator *sinGenerator_;
	
}

@property (retain) id synth;

//MIDIServer delegation
-(void)midiReceived:(const MIDIPacketList *)packetList;

//AudioOutputEngine delegation
-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;

@end
