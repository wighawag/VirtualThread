package 
{
	import com.wighawag.concurrency.ThreadProcessor;
	import com.wighawag.concurrency.VirtualThread;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;


	public class Main extends Sprite 
	{
		private var _threadProcessor : ThreadProcessor;
		
		private var _testThread : VirtualThread;
		private var _threadStartTime : int;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			_threadProcessor = new ThreadProcessor(stage, 0.99);
			
			var value : int = 300000;
			
			var startTime : int = getTimer();
			var counter : int = 0;
			while ( counter < value)
			{
				counter++;
			}
			trace("time : " + (getTimer() - startTime));
			
			_testThread = _threadProcessor.createThread(new RunnableTest(value), true);
			_testThread.completed.addOnce(onThreadCompleted);
			_threadStartTime = getTimer();
			_testThread.start();
			
		}
		
		private function onThreadCompleted():void 
		{
			trace("done time : " + (getTimer() - _threadStartTime));
			trace(_testThread.statisitcs);
		}
		
	}
	
}