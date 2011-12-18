//
//  SoundDelegate.h
//  SinSynth
//
//  Created by 吉岡 紘二 on 11/12/17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreMIDI/CoreMIDI.h>
#include <vector>
#include <math.h>

#include <map>
static const int SAMPLING_RATE = 44100;

class DownRamp{
public:
	DownRamp(float speed){		//sec
		speed_ = speed;
		frame_ = 0;
	}
	
	float gen(){
		float val = 1.0 - (1 / speed_) * frame_/SAMPLING_RATE;
		frame_++;
		if (val < 0.0){
			return 0;
		}else{
			return val;
		}
	}
	
private:
	int frame_;
	float speed_;
};

class SinWaveGenerator{
public:
	SinWaveGenerator(int freq, float gain) : ramp_(0.2){
		freq_ = freq;
		gain_ = gain;
		frame_ = 0;
		
		isOff_ = false;
		isEnd_ = false;
	}
	
	float gen(){

		float current_sec = 1.0 * frame_ / SAMPLING_RATE;
		float omega = 2 * M_PI * freq_;
		float val =gain_* cos( omega * current_sec);
		
		
		if (isOff_){
			float rampval = ramp_.gen();
			val *= rampval;
			if (rampval < 0.001){
				//NSLog(@"notes end");
				isEnd_ = true;
			}
		}
		
		frame_++;
		return val;
	}
	
	void off(){
		//note was offed
		isOff_ = true;
	}
	
	bool isOff(){
		return isOff_;
	}
	
	bool isEnd(){
		//is end over?
		return isEnd_;
	}
	
private:
	int frame_;
	int freq_;
	float gain_;
	
	bool isEnd_;
	
	bool isOff_;
	DownRamp ramp_;
};

class Synth{
private:
	std::multimap<Byte, SinWaveGenerator*> notes_;	//notes and sins pair
	
	typedef std::multimap<Byte,SinWaveGenerator *>::iterator ite_type;
	
public:
	Synth(){}
	~Synth(){}

	virtual float gen(){
		float val = 0.0f;
		
		for (ite_type ite = notes_.begin(); ite != notes_.end(); ++ite){
			val += (*ite).second->gen();
		}
		
		return val;
	}
	
	void noteOn(Byte noteNumber, Byte velocity){
		const float base = 440.0f;
		const float keisuu = 1.0594630943593f;
		float freq = base * pow(keisuu,noteNumber - 60);
		
		SinWaveGenerator *sin = new SinWaveGenerator(freq, 0.1);
		notes_.insert(std::make_pair(noteNumber, sin)); 
		
		NSLog(@"notes count = %lu", notes_.size());
		
	}
	
	void noteOff(Byte noteNumber){

		//同じnoteNumberを持つノートのうち、まだNoteOffされていなくて、かつ一番古いものから
		//offしていく。
		std::pair< ite_type, ite_type> rangePair = notes_.equal_range(noteNumber);
		for (ite_type ite = rangePair.first; ite != rangePair.second; ++ite){ 
			SinWaveGenerator *sin = (*ite).second;
			if (!sin->isOff()){
				sin->off();
			}
		}
		
		NSLog(@"notes count = %lu", notes_.size());	
	}
	
	void removeEndNotes(){
		
		for (ite_type it = notes_.begin(); it != notes_.end();){
			SinWaveGenerator *sin = (*it).second;
			if (sin->isEnd()){
				NSLog(@"detects dead notes.");
				delete sin;
				notes_.erase(it++);
				
			}else{
				++it;
			}
		}
	}
	

};

@interface SoundDelegate : NSObject{
	Synth *synth_;
	
}

//MIDIServer delegation
-(void)midiReceived:(const MIDIPacketList *)packetList;

//AudioOutputEngine delegation
-(void)audioEngineBufferRequired:(UInt32)sampleNum left:(SInt16 *)pLeft right:(SInt16 *)pRight;

@end
