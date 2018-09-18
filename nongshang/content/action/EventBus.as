package action{
	import flash.events.EventDispatcher;

	public class EventBus extends EventDispatcher{
		private static var _instance:EventBus;
		
		
		public function EventBus(code:$){
			
		}
		
		public static function getInstance():EventBus{
			return _instance||new EventBus(new $());
		}
	}
}
class ${

}