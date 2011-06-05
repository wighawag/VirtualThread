package  
{
	import com.wighawag.concurrency.IRunnable;

	public class RunnableTest implements IRunnable 
	{
		
		private var _counter : int;
		private var _total:int;
		
		public function RunnableTest(total : int) 
		{
			_total = total;
			_counter = 0;
		}
		
		/* INTERFACE wighawag.concurrency.IRunnable */
		
		public function process():void 
		{
			_counter ++;
		}
		
		public function cleanup():void 
		{
			_counter = 0;
		}
		
		public function isComplete():Boolean 
		{
			return (_counter == _total);
		}
		
		public function getTotal():int 
		{
			return _total;
		}
		
		public function getProgress():int 
		{
			return _counter;
		}
		
	}

}