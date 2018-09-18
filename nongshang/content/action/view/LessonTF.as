package action.view{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.MouseEvent;
    import action.gs.TweenLite;
	public class LessonTF extends Sprite{
		private var tf:TextField = null;
		private var maskSprite:Sprite = null;
		public function LessonTF(textField:TextField){
			this.tf = textField;
			this.x = tf.x;
			this.y = tf.y;
			tf.x=0;
			tf.y=0;
			this.addChild(tf);
			initView();
		}
		
		private function initView():void{
			maskSprite = new Sprite();
			tf.parent.addChild(maskSprite);
			
			maskSprite.graphics.beginFill(0xfff,0);
			maskSprite.graphics.drawRect(0,0,tf.width+5,tf.height);
			maskSprite.graphics.endFill();
			maskSprite.buttonMode = true;
			tf.mask = maskSprite;
			initListener();
		}
		
		private function initListener():void{
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverHandler);
		}
		
		private function onMouseOverHandler(e:MouseEvent):void{
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOutHandler);
			this.removeEventListener(MouseEvent.MOUSE_OVER,onMouseOverHandler);
			if(tf.textWidth>maskSprite.width){
               TweenLite.to(tf, 3, {x:maskSprite.width-tf.textWidth-5});
			}

		}
		
		private function onMouseOutHandler(e:MouseEvent):void{
			this.removeEventListener(MouseEvent.MOUSE_OUT,onMouseOutHandler);
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOverHandler);
			if(tf.textWidth>maskSprite.width){
               TweenLite.to(tf, 1.5, {x:0});
			}
		}
	}
}