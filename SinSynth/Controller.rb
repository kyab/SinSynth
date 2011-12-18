#
#  Controller.rb
#  SinSynth
#
#  Created by 吉岡 紘二 on 11/12/17.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

#require "math"

SAMPLING_RATE = 44100

class SinWaveGenerator
	def initialize(freq, gain)
		@frame = 0
		@freq = freq
		@gain = gain
		NSLog("freq = #{@freq}, gain = #{@gain}")
	end
	
	def self.create(freq, gain)
		return self.new(freq, gain)
	end 
	
	def gen()
		current_sec = 1.0 * @frame /SAMPLING_RATE 
		omega = 1.0 / @freq
		val = Math::sin(2 * Math::PI * omega * current_sec)
		@frame += 1
		val
	end
	
	def end?
		@frame/44100.0 > 3.0
	end
end


class SinSynth
	attr_accessor :sounds
	def addNewSound(sound)
		
	end
	
	def generateSound(bufferToSupplied)
		
		bufferToSupplied.each do |sample|
			@generators.each do 
				sample += @generators.gen()
			end
		end
		
		@generators.delete_if do |gen|
			gen.end?
		end
		
	end
	
end

class Controller
	
	def initialize
		
	end
	
	def awakeFromNib
		
	end
	
	def initMIDI(sender)
		@midiServer = MIDIServer.new
		@midiServer.delegate = self
		@midiServer.start
		sender.enabled = false
		
	end
	
	def initSoundDelegate(sender)
		@soundDelegate = SoundDelegate.new
		@soundDelegate.synth = SinSynth.new
		@midiServer.delegate = @soundDelegate
		@audioEngine.delegate = @soundDelegate	
		
	end
	
	def initAudioEngine(sender)
		@audioEngine = AudioOutputEngine.new
		@audioEngine.initCoreAudio
	end
	
	def startAudioEngine(sender)
		@audioEngine.start
	end
	
	def stopAudioEngine(sender)
		@audioEngine.stop
	end
	
	def midiReceived(packet)
		NSLog("delegate received")
	end
	
end
