package action.view{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import action.MyConst;
	public class TipView extends Sprite{
			
		private var bg:TipViewBg = null; 
		private var maskSprite:Sprite = null;
		//默认不读进度
		private var isRead:Boolean = false;
		public function TipView(){
			super();
			init();
		}
		public function clear():void{
			
			bg.sureBtn.removeEventListener(MouseEvent.CLICK,onSureBtnClick);
			bg.cancelBtn.removeEventListener(MouseEvent.CLICK,onCancelBtnClick);
			bg.closeBtn.removeEventListener(MouseEvent.CLICK,onCloseBtnClick);
			this.removeChild(bg);
			this.removeChild(maskSprite);
			bg = null;
			maskSprite = null;
		}
		
		private function init():void{
			maskSprite = new Sprite();
			maskSprite.graphics.beginFill(0x000,0.5);
			maskSprite.graphics.drawRect(0,0,MyConst.stageWidth,MyConst.stageHeight);
			maskSprite.graphics.endFill();
			this.addChild(maskSprite);
			bg = new TipViewBg();
			this.addChild(bg);
			bg.x = 400;
			bg.y = (MyConst.stageHeight - bg.height)*0.5;
			bg.sureBtn.addEventListener(MouseEvent.CLICK,onSureBtnClick);
			bg.cancelBtn.addEventListener(MouseEvent.CLICK,onCancelBtnClick);
			bg.closeBtn.addEventListener(MouseEvent.CLICK,onCloseBtnClick);
		}
		
		private function onSureBtnClick(e:MouseEvent):void{
			isRead = true;
			onCloseBtnClick();
		}
		
		private function onCancelBtnClick(e:MouseEvent):void{
			isRead = false;
			onCloseBtnClick();

		}
		
		private function onCloseBtnClick(e:MouseEvent=null):void{
			var evt:LessonEvent = new LessonEvent(LessonEvent.CLOSE_TIP_VIEW);
			evt.isRead = this.isRead;
			this.dispatchEvent(evt);
		}
	}
}