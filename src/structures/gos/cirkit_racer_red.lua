return {
	path="assets/images/cirkit_racer_red.png",
	sheetParams = { numFrames = 10, height = 48, sheetContentHeight = 48, sheetContentWidth = 480, width = 48 },
	sequences = {
		{ time=270, loopCount=0, name="default", frames={ 1,6,}, },
		{ time=270, loopCount=0, name="running", frames={ 1,6,}, },
		{ time=270, loopCount=0, name="up", frames={ 2,7,}, },
		{ time=270, loopCount=0, name="down", frames={ 3,8,}, },
		{ time=270, loopCount=0, name="finish", frames={ 4,9,}, },
		{ time=270, loopCount=0, name="crush", frames={ 5,}, },
		{ time=270, loopCount=0, name="jumping", frames={ 4,}, },
	},
	sounds = {
		jump='assets/sounds/jump.wav',
		idle='assets/sounds/idle.wav',
	},
}
