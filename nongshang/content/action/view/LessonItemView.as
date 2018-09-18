package action.view{
	import flash.display.Sprite;
	import action.model.LessonItemObj;
	
	public class LessonItemView extends Sprite{
		private var itemObj:LessonItemObj;
		private var view:LessonItemBg = null;

		public function LessonItemView(){
			view = new LessonItemBg();
			view.buttonMode = true;
			var lessonTF:Sprite = new LessonTF(view.titleTF);
			view.addChild(lessonTF);
			this.addChild(view);
		}
		public function  set data(value:LessonItemObj):void{
			if(value){
				itemObj = value;
				initView();
			}
		}
		
		public function get data():LessonItemObj{
			return itemObj;
		}
		
		//二级目录被选中。
		public function select(value):void{
			itemObj.isOpen = value;
			if(value){
				view.bg.gotoAndStop(2);
			}else{
				view.bg.gotoAndStop(1);
			}
		}
		public function updata(value:LessonItemObj):void{
			itemObj = value;
			if(itemObj.isLearn){
				view.icon.gotoAndStop(2);
			}else{
				view.icon.gotoAndStop(1);
			}
		}
		
		private function initView():void{
			view.titleTF.text = itemObj.title;
			view.titleTF.width = view.titleTF.textWidth+5;
			if(itemObj.isLearn){
				view.icon.gotoAndStop(2);
			}else{
				view.icon.gotoAndStop(1);
			}
			if(itemObj.isOpen){
				view.bg.gotoAndStop(2);
			}else{
				view.bg.gotoAndStop(1);
			}
		
		}
	}
}