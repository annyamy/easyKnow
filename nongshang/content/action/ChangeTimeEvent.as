package  action
{
	import flash.events.Event;

	public class ChangeTimeEvent extends Event{
		public static const CHANGE_TIME:String = "changeTime";	//  通过拖动改变播放进度
		
		private var _ratio:Number=0;
		
		public function ChangeTimeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function set ratio(value:Number):void{
			this._ratio = value;
		}
		
		public function get ratio():Number{
			return this._ratio;
		}
	}
}