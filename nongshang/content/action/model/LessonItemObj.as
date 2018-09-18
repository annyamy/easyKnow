package action.model{
	
	public class LessonItemObj{
		public function LessonItemObj(){
			
		}
		
		public var lessonId:String="";
		public var title:String="";
		public var url:Array=[];
		public var imgUrl:Array =[];
		public var isLearn:Boolean = false;
		public var isOpen:Boolean = false;
		//对应的视频存入顺序
		public var videoIndex:int=0;
	}
}