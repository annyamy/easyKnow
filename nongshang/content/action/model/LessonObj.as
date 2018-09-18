package action.model{
	
	public class LessonObj{
		public function LessonObj(){
			
		}
		
		public var lessonId:String="";
		public var title:String="";
		public var lessonList:Array=[];
		//是否学完
		public var isLearn:Boolean = false;
		//是否默认展开
		public var isOpen:Boolean = false;
		//是否是考试按钮
		public var isTest:Boolean = false;
	}
}