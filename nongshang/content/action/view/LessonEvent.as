package action.view{
	import flash.events.Event;

	public class LessonEvent extends Event{
		//改变播放的视频
		public static const CHANGE_VIDEO:String = "changeVideo";
		//点击标题
		public static const TITLE_CLICK:String = "titleClick";
		//关闭提示面板
		public static const CLOSE_TIP_VIEW:String = "closeTipView";
		//打开测试面板
		public static const OPEN_TEST_VIEW:String = "openTestView";
		
		private var _isRead:Boolean = false;
		
		private var _videoIndex:int =0;
		
		
		public function LessonEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false){
				super(type,bubbles,cancelable);
		}
		
		public function set videoIndex(value:int):void{
			_videoIndex = value;
		}
		
		public function get videoIndex():int{
			return _videoIndex;
		}
		
		public function set isRead(value:Boolean):void{
			this._isRead = value;
		}
		
		public function get isRead():Boolean{
			return this._isRead;
		}
	}
}