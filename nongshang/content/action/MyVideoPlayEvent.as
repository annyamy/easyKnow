package action{
	import flash.events.Event;

	public class MyVideoPlayEvent extends Event{
		//设置总的播放时间
		public static const TOTAL_TIME_EVENT:String = "total_time_event";
		//改变播放进度条
		public static const CHANGE_BAR_TIME:String = "changeBarTime";
		
		//改变视频播进度
		public static const CHANGE_PLAY_TIME:String = "changePlayTime";
		//视频播放完毕
		public static const PLAY_OVER:String ="playOver";
		
		private var  _currentTime:Number =0;
		
		private var _totalTime:Number =0;
		
		public function MyVideoPlayEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		public function set currentTime(value:Number):void{
			this._currentTime = value;
		}
		
		public function get currentTime():Number{
			return this._currentTime;
		}
		
		public function set totalTime(value:Number):void{
			this._totalTime = value;
		}
		
		public function get totalTime():Number{
			return this._totalTime;
		}
	}
}