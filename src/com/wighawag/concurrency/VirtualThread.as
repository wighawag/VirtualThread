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
   
   (Originally called GreenThread)
   Modified by Wighawag (www.wighawag.com) 2011
 */ 
package com.wighawag.concurrency 
{
	import com.wighawag.concurrency.ThreadStatistics;
	import flash.errors.ScriptTimeoutError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;
	import org.osflash.signals.Signal;

	public class VirtualThread 
	{
		private var _threadProcessor : ThreadProcessor;
		private var _runnable : IRunnable;
		
		private var _maximum : Number = NaN;
		private var _progress : Number = NaN;
		private var _debug : Boolean;
		private var _statistics : ThreadStatistics;
		
		public var timedOut : Signal = new Signal();
		public var completed : Signal = new Signal();
		public var errorOccured : Signal = new Signal(Error);
		public var progressed : Signal = new Signal(Number);
		
		
		public function VirtualThread(threadProcessor : ThreadProcessor, runnable : IRunnable, debug : Boolean = true ) {
			this._threadProcessor = threadProcessor;
			this._runnable = runnable;
			this._debug = debug;
		}
		
		public final function start() : void {
			_threadProcessor.start( this );
			if( debug ) {
				_statistics = new ThreadStatistics();
			}
		}

		public final function stop() : void {
			_threadProcessor.remove( this );
			_runnable.cleanup();
		}
		
		public function get debug() : Boolean {
			return _debug;
		}
		
		public function set debug( value : Boolean ) : void {
			_debug = value;
		}
		
		public function get statisitcs() : ThreadStatistics {
			return _statistics;
		}
			
		internal final function execute( processAllocation : Number ) : Boolean {
			if ( debug ) statisitcs.startCycle();
			var processStart:int = getTimer();
			var complete : Boolean = false;
			try {
				
				while ( getTimer() - processStart < processAllocation && !complete ) {
					if ( debug ) statisitcs.addInnerCycle();
					_runnable.process();
					complete = _runnable.isComplete();
				} 	
			}
			catch( error:ScriptTimeoutError ) {
				if( debug ) statisitcs.recordTimeout();
				timedOut.dispatch();
			} 
			catch (e:Error) {
				errorOccured.dispatch(e);
			}
			
			progressed.dispatch(_runnable.getProgress() / _runnable.getTotal());
			if (complete) {
				completed.dispatch();
				stop(); 
			}			
				
			//record post process time
			if ( debug ) statisitcs.endCycle( processAllocation );
			
			return !complete;
		}	
	}

}