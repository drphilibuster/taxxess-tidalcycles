/*
This is an example startup file.
If you want to modify it, best copy it elsewhere to keep the git repository clean.

You can then load it by calling
"path/to/my/superdirt_startup.scd".load
from the supercollider startup file

The supercollider startup file is to be found in
Platform.userAppSupportDir +/+ "startup.scd",
or via the menu File > Open startup file
*/

// TEST IF HAVING TROUBLE
// (
// s.options.numBuffers = 1024 * 256;
// s.options.memSize = 8192 * 32;
// s.options.maxNodes = 1024 * 32;

// s.options.numOutputBusChannels = 2;
// s.options.numInputBusChannels = 2;

// s.boot();
// );

(
s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 40; // increase this if you get "alloc failed" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"

	// For system default
	// s.options.numOutputBusChannels = 2;
	// s.options.numInputBusChannels = 2;

	// For general purpose
	s.options.numOutputBusChannels = 16;
	s.options.numInputBusChannels  = 2;
	s.options.device = "BlackHole 16ch";

	// For simultaneously using inputs from MOTU
	// s.options.numOutputBusChannels = 34;
	// s.options.numInputBusChannels = 34;
	// s.options.device = "SuperColliderMOTUAggregate";
	// boot the server and start SuperDirt

	s.waitForBoot {
		~dirt.stop; // stop any old ones, avoid duplicate dirt (if it is nil, this won't do anything)

		~dirt = SuperDirt(2, s); // 2x channels per orbit (stereo pairs)
		// ~dirt = SuperDirt(4, s); // 8x channels per orbit (multichannel surround)

		~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");

		s.sync; // optionally: wait for samples to be read

		// ~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0
		~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12, 14]); // 8x stereo pairs / orbits
		// ~dirt.start(57120, [0, 4, 8, 12, 16]); // 8x 4-way pairs / orbits
		// ~dirt.start(57120, [0, 0, 0, 0, 0, 0, 0, 0]); // 8x 4 channel outputs / orbits (multichannel surround)

		// Debug print OSC messages
		// s.dumpOSC(1);

		SuperDirt.default = ~dirt; // make this instance available in sclang (optional)

		// optional, needed for convenient access from sclang:
		(
			~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
			~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
			~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
			~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
		);

		(
			MIDIClient.init;
			~midiOut = MIDIOut.newByName("IAC Driver", "Bus 1"); // substitute your own device here
			~dirt.soundLibrary.addMIDI(\dawtest, ~midiOut);
			~midiOut.latency = 0;
		);

		// directly below here, in your own copy of this file, you could add further code that you want to call on startup

	};

	s.latency = 0.3; // increase this if you get "late" messages

};
);
