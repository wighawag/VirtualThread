/**
   Copyright 2009 Charles E Hubbard

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   Modified by Wighawag (www.wighawag.com) 2011
 */ 
package com.wighawag.concurrency 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class ThreadProcessor 
	{
		private var _stage : Stage;
		private var _share : Number;
		private var _epsilon : Number;
		private var _threads : Vector.<VirtualThread>
		private var _inactiveThreads: Vector.<VirtualThread>;
		private var _errorTerm:int;
		private var _running : Boolean;
		
		
		public function ThreadProcessor(stage : Stage, share : Number = 0.99, epsilon : Number = 1) {	
			this._stage = stage;
			this.share = share;
			this._epsilon = epsilon;
			this._threads = new Vector.<VirtualThread>;
			this._running = false;
		}
		
		public function createThread( runnable : IRunnable, debug : Boolean = false ) : VirtualThread {
			return new VirtualThread(this, runnable, debug);
		}
		
		public function get share() : Number {
			return _share;
		}
		
		public function set share( percent : Number ) : void {
			if (share >= 1)
			{
				throw new ArgumentError("share need to be less than 1 and represent how much of the frame should be given to the thread processor");
			}
			_share = percent;
		}
		
		public function stopAll() : void {
			while (_threads.length > 0)
			{
				var thread : VirtualThread = _threads.pop();
				thread.stop();
			}
			
			if (_running)
			{
				_stage.removeEventListener( Event.ENTER_FRAME, process );
				_running = false
			}
		}
		
		internal function start( thread : VirtualThread) : void {
			var index : int = _threads.indexOf( thread );
			if ( index == -1 ) {
				_threads.push(thread);
			}
			else {
				trace("already in the active thread list!");
			}
			
			if (!_running)
			{
				_stage.addEventListener( Event.ENTER_FRAME, process);
				_running = true;
			}
		}
		
		internal function remove( thread : VirtualThread ) : void {
			var index : int = _threads.indexOf( thread );
			if ( index >= 0 ) {
				_threads.splice( index, 1 );
			}
			
			if( _threads.length == 0 ) {
				stopAll();
			}
		}
		
		private function process( event : Event ) : void {
			var timeAllocation : int = timerDelay * share + 1;
			timeAllocation = Math.max(timeAllocation, _epsilon * _threads.length); //espilon minimum per thread

			//if the error term is too large, skip a cycle
			if( _errorTerm > timeAllocation - 1 ) {
				_errorTerm = 0;
				return;
			}
						
			var cycleStart:int = getTimer();
			
			var cycleAllocation:int = timeAllocation - _errorTerm;
			var processAllocation:int = cycleAllocation / _threads.length;			
			
			//decrement for easy removal of processes from list
			for( var i:int = _threads.length - 1; i > -1; i-- ) {
				var thread:VirtualThread = _threads[ i ] as VirtualThread;
				if(!thread.execute( processAllocation ) ) {
					if( _threads.length > 0 ) {
						//open up more allocation to remaining processes
						processAllocation = cycleAllocation / _threads.length;
					} else {
						break;
					}
				}
			}
			
			//solve for cycle time
			var cycleTime:int = getTimer() - cycleStart;
			var delta:Number = cycleTime - timeAllocation;
			
			//update the error term
			_errorTerm = ( _errorTerm + delta ) >> 1;
		}

		private function get timerDelay() : Number {
			return 1000 / _stage.frameRate;
		}
	}

}