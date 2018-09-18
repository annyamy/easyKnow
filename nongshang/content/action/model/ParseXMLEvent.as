package action.model{
	import flash.events.Event;

	public class ParseXMLEvent extends Event{
		//数据解析完成
		public static const PARSE_COMPLETE:String = "parseComplete";
	
		public function ParseXMLEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}