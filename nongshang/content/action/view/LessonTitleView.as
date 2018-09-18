package action.view{
	import flash.display.Sprite;
	import action.model.LessonItemObj;
	import action.model.LessonObj;
	import action.model.VideoObj;
	import flash.utils.Dictionary;
	import flash.events.MouseEvent;
	import action.EventBus;
	public class LessonTitleView extends Sprite{
		private var titleObj:LessonObj = null;
		private var itemList:Array = null;
		private var itemViewList:Dictionary = null;
		
		private var view:LessonTitleBg = null;
		private var listContainer:Sprite = null;
		private var offsetY:Number =0;
		public function LessonTitleView(){
			view = new LessonTitleBg();
			view.buttonMode = true;
			var lessonTF:Sprite = new LessonTF(view.titleTF);
			view.addChild(lessonTF);
			this.addChild(view);
			listContainer = new Sprite();
			listContainer.y = view.height;
			this.addChild(listContainer);
		}
		public function set data(value:LessonObj):void{
			if(value){
				titleObj = value;
				initView();
			}
		}
		public function get data():LessonObj{
			return titleObj;
		}
		public function get titleView():LessonTitleBg{
			return view;
		}
		
		//打开子列表
		public function openList(videoObj:VideoObj=null):void{
			if(videoObj){
				listContainer.visible = true;
			    titleObj.isOpen = true;
				for(var key:String in itemViewList){
					if(key!=videoObj.lessonId){
						itemViewList[key].select(false);
					}else{
						itemViewList[key].select(true);
					}
				}
			}else{
				for each(var item:LessonItemView in itemViewList){
					if(item.data.isOpen){
						item.select(true);
					}else{
						item.select(false);
					}
					
				}
			}
			
			
		}
		//是否被选中打开。
		public function select(value:Boolean):void{
			titleObj.isOpen = value;
			if(titleObj.isOpen){
				listContainer.visible = true;
				listContainer.height = offsetY;
			}else{
				listContainer.visible = false;
				listContainer.height = 0;
			}
			if(titleObj.isOpen){
				view.bg.gotoAndStop(2);
			}else{
				view.bg.gotoAndStop(1);
			}

		}
		
		public function updata(data:LessonObj):void{
			titleObj = data;
			if(titleObj.isLearn){
				view.icon.gotoAndStop(2);
			}else{
				view.icon.gotoAndStop(1);
			}
			itemList = titleObj.lessonList;
			var tempItemObj:LessonItemView =null;
			if(itemList){
				for(var i:int=0;i<itemList.length;i++){
					var obj:LessonItemObj = itemList[i];
					tempItemObj = itemViewList[obj.lessonId];
					tempItemObj.updata(obj);
				}
			}

		}
		private function initView():void{
			view.titleTF.text = titleObj.title;		
			view.titleTF.width = view.titleTF.textWidth+5;
			if(titleObj.isLearn){
				view.icon.gotoAndStop(2);
			}else{
				view.icon.gotoAndStop(1);
			}
			if(titleObj.isOpen){
				view.bg.gotoAndStop(2);
			}else{
				view.bg.gotoAndStop(1);
			}
			if(titleObj.lessonList){
				initList();
			}
		}
		
		private function initList():void{
			itemList = titleObj.lessonList;
			itemViewList = new Dictionary();
			var tempItemObj:LessonItemView =null;			
			for(var i:int=0;i<itemList.length;i++){
				tempItemObj = new LessonItemView();
				tempItemObj.data = itemList[i];
				tempItemObj.y = offsetY;
				offsetY +=tempItemObj.height;
				listContainer.addChild(tempItemObj);
				itemViewList[itemList[i].lessonId] = tempItemObj;
				tempItemObj.addEventListener(MouseEvent.CLICK,onItemObjClickHandler);
			}
			if(titleObj.isOpen){
				listContainer.visible = true;
				listContainer.height = offsetY;
			}else{
				listContainer.visible = false;
				listContainer.height = 0;
			}
		}
		
		//点击课程后，加载对应视频，改变选中的课程 。
		private function onItemObjClickHandler(e:MouseEvent):void{
			var target:LessonItemView= e.currentTarget as LessonItemView;
			var evt:LessonEvent = new LessonEvent(LessonEvent.CHANGE_VIDEO);
			evt.videoIndex = target.data.videoIndex;
			this.dispatchEvent(evt);
		}
	}
}