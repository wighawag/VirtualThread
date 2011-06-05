## VirtualThread ##

A library to use run cod ein the background (trying to use any cpu resource available)

Code mainly taken from [greenthread](http://code.google.com/p/greenthreads/) with the IRunnable interface from [as3-commons concurrency](http://www.as3commons.org/as3-commons-concurrency/index.html).

The main change from greenthread is the use of As3-signals and the necesity to instantiate the ThreadProcessor. no more Singleton.
The need for ThreadProcessor in the first place is because to be able to use as much resource the code need to know the stage framerate.


### USAGE ###

look at Main.as and RunnableTest.as

#### COMPILE ####

need submodule : https://github.com/robertpenner/as3-signals.git

just execute :
	git submodule update


