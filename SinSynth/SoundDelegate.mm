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
@synthesize synth = synth_;

-(id)init{
	self = [super init];
	if (self != nil){
		sinGenerator_ = new SinWaveGenerator(440, 0.3f);
		/*id ruby = [[MacRuby sharedRuntime] evaluateString:@"SinWaveGenerator"];
		NSNumber *value1 = [NSNumber numberWithFloat:440.0];
		NSNumber *value2 = [NSNumber numberWithFloat:1];
		id generator = [ruby performRubySelector:@selector(new) withArguments:value1, value2, NULL];
		NSLog(@"%d",[generator gen]);*/
	
	}
	return self;
}

-(void)midiReceived:(const MIDIPacketList *)packetList{
	NSLog(@"SoundDelegate now received MIDI Event");
	
}

-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;
{
	//NSLog(@"SoundDelegate now buffer required");
	for (UInt32 i = 0 ; i < sampleNum ; i++){
		float val = sinGenerator_->gen();
		SInt16 sint16val = val * SHRT_MAX;
		
		pLeft[i] = sint16val;
		pRight[i] = sint16val;
		//NSLog(@"sin16val = %d",sint16val);
	}
	//for (UInt32 i = 0 ; i < sampleNum ; i++){
	//	pLeft[i] = pRight[i] = 0;
	//}
	
}

@end
