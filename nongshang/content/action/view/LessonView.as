package action.view{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import action.model.LessonObj;
	import fl.controls.ScrollPolicy;
	import action.model.VideoObj;
	import flash.utils.Dictionary;
	import flash.events.MouseEvent;

	public class LessonView extends MovieClip{
		private var container:Sprite = null;
		private var scrollView:ScrollPane = null;
		
		private var list:Array = null;
		//视图对象
		private var itemList:Array = null;
		private var maskSprite:Sprite = null;
		private var currentVideo:VideoObj = null;
		
		private var testItem:LessonTitleView = null;
		public function LessonView(){
			super();
			init();
		}
		
		public function setData(value:Array):void{
			list = value;
			initView();
		}
		
		public function updataScore(score:Number):void{
			var testButton:LessonTitleView = itemList[itemList.length-1];
			var testObj:LessonObj = list[list.length-1];
			if(score>=80){
				testObj.isLearn = true;
			}else{
				testObj.isLearn = false;
			}
			testButton.updata(testObj);
			
		}
		//切换对象
		public function changeLesson(videoObj:VideoObj):void{
			currentVideo = videoObj;
			var title:LessonTitleView =null;
			var offsetY:Number = 0;
			for(var i:int=0;i<itemList.length;i++){
				title = itemList[i];
				title.openList(currentVideo);
				if(title.data.lessonId == videoObj.titleId){
					title.data.isOpen = true;
					title.select(true);
				}else{
					title.select(false);
				}
				title.y = offsetY;
				offsetY +=title.height;
			}
			//testItem.y = offsetY;
			//offsetY+=testItem.height;
			scrollView.update();
		}
		//学习进度改变后，更改课程列表，有些课程可以算完成。
		public function updata(value:Array):void{
			list = value;
			var title:LessonTitleView =null;
			var offsetY:Number = 0;
			for(var i:int=0;i<itemList.length;i++){
				title = itemList[i];
				title.updata(list[i]);
			}
		}

		private function init():void{
			scrollView = this.scrollPanel;
			scrollView.horizontalScrollPolicy = ScrollPolicy.OFF;
			container = new Sprite();
			this.addChild(container);
			
			scrollView.source = container;
			
			maskSprite = new Sprite();
			maskSprite.graphics.beginFill(0xff0000,1);
			maskSprite.graphics.drawRoundRect(0,1,scrollView.width,scrollView.height-2,24);
			maskSprite.graphics.endFill();
			this.addChild(maskSprite);
			scrollView.mask = maskSprite;
		}
		
		private function initView():void{
			itemList = [];
			var tempObj:LessonObj=null;
			var titleItem:LessonTitleView=null;
			var offsetY:Number = 0;
			for(var i:int=0;i<list.length;i++){
				tempObj = list[i];
				titleItem = new LessonTitleView();
				titleItem.data = tempObj;
				titleItem.y = offsetY;
				offsetY+= titleItem.height;				
				container.addChild(titleItem);
				itemList.push(titleItem);
				titleItem.titleView.addEventListener(MouseEvent.CLICK,onTitleItemClick);
			}
			/*testItem = new LessonTitleView();
			testItem.titleView.titleTF.text="测试";
			testItem.addEventListener(MouseEvent.CLICK,onStartTestClick);
			container.addChild(testItem);
			testItem.y =offsetY;
			offsetY+=testItem.height;*/
			container.height = offsetY;
			scrollView.update();
		}
		//点击标题后，展开或收起主标题
		private function onTitleItemClick(e:MouseEvent):void{
			var title:LessonTitleView =null;
			var target:LessonTitleView = e.currentTarget.parent as LessonTitleView;
			var offsetY:Number = 0;
			for(var i:int=0;i<itemList.length;i++){
				title = itemList[i];
				if(title == target){
					if(title.data.isOpen){
						title.select(false);
						title.data.isOpen = false;
					}else{
						title.select(true);
						title.data.isOpen = true;
					}

				}
				title.openList();
				title.y = offsetY;
				offsetY +=title.height;
			}
			//testItem.y =offsetY;
			//offsetY+=testItem.height;
			scrollView.update();
			if(target.data.isTest){
				onStartTestClick();
			}
		}
		
		private function onStartTestClick():void{
			var evt:LessonEvent = new LessonEvent(LessonEvent.OPEN_TEST_VIEW);
			this.dispatchEvent(evt);
		}
		
	}
}