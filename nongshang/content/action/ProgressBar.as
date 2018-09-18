package  action
{
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import action.model.LessonItemObj;
	import action.model.ParseXMLModel;
	
	public class ProgressBar extends MovieClip {
		
		private var maxW:Number = 0;
		private var maskSprite:Sprite = null;
		private var ratio :Number =0;
		public function ProgressBar() {
			super();
			initView();
		}

		public function changeRatio(ratio:Number):void{
			if(ratio>=0 && ratio<=1){
				this.ratio = ratio;
				changeProgress(ratio);
			}
		}
		private function initView():void{
			this.buttonMode = true;
			maxW = this.progressBg.width;
			maskSprite = new Sprite();
			maskSprite.graphics.beginFill(0x000,1);
			maskSprite.graphics.drawRoundRect(0,this.progressBg.y,this.progressBg.width,this.progressBg.height,12);
			maskSprite.graphics.endFill();
			this.addChild(maskSprite);
			this.progressBg.mask =maskSprite;
			
			changeProgress(0.5);
			initListener();
		}
		
		private function changeProgress(ratio:Number):void{
			this.sliderBtn.x = ratio*maxW;
			maskSprite.width = this.sliderBtn.x ;
		}
		
		private function initListener():void{
			this.sliderBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSliderMouseDown);
			this.addEventListener(MouseEvent.CLICK,onBgClickHandler);
		}
		
		private function onSliderMouseDown(e:MouseEvent):void{
			this.sliderBtn.removeEventListener(MouseEvent.MOUSE_MOVE,onSliderMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUpHandler);
		}
		
		private function onMouseMoveHandler(e:MouseEvent):void{
			var item:LessonItemObj = ParseXMLModel.getInstance().currentLessonItemObj;
			if(item && item.isLearn){
				if(mouseX>=0 &&mouseX<=maxW){
					this.sliderBtn.x = mouseX;
					maskSprite.width = this.sliderBtn.x;
					ratio = this.sliderBtn.x/maxW;
					changeTime();
				}
			}
		}
		
		private function onMouseUpHandler(e:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseUpHandler);
			this.sliderBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSliderMouseDown);
		}
		
		private function onBgClickHandler(e:MouseEvent):void{
			var item:LessonItemObj = ParseXMLModel.getInstance().currentLessonItemObj;
			if(item && item.isLearn){
				if(mouseX>=0 &&mouseX<=maxW){
					this.sliderBtn.x = mouseX;
					maskSprite.width = this.sliderBtn.x;
					ratio = this.sliderBtn.x/maxW;
					changeTime();
				}
			}
		}
		
		private function changeTime():void{
			var changeEvent:ChangeTimeEvent = new ChangeTimeEvent(ChangeTimeEvent.CHANGE_TIME);
			changeEvent.ratio = this.ratio;
			this.dispatchEvent(changeEvent);
		}
	}
	
}
