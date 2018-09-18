package ac 
{
	import flash.display.MovieClip;
	import com.greensock.*;
	import com.greensock.easing.*;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.*;
    import flash.events.*;
	import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
	import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import flash.geom.Rectangle;
	import flash.external.ExternalInterface;
	import flash.system.fscommand;
	import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.sampler.Sample;
	
	
	public class  testAction extends MovieClip
	{
		private var myXML:XML;
		private var xmlLoader:URLLoader = new URLLoader();                                  	//加载XML
		private var optionNum:int=0;
		private var totalArr:Array=new Array();
		private var index:int=0;
		//正确答案序号
		private var rightNum:String="";
		//正确答案的个数
		private var rightINT:int=0;
		//题型记录
		private var tixing:String;
		//随机生成数组
		private var arr:Array=new Array();
		
		
		public function testAction()
		{
			premc.pre_btn.addEventListener(MouseEvent.MOUSE_DOWN,pre_btnClick);
			premc.pre_btn.buttonMode=true;
			endpage.visible=false;
			loadXML("xml/Exam.xml");
		}
		
		private function pre_btnClick(e:MouseEvent):void
		{
			
			premc.visible=false;
		}
		
		private function loadXML(Url:String):void
		{
			var request:URLRequest =new URLRequest(Url); 
			xmlLoader.load(request);
			xmlLoader.addEventListener (Event.COMPLETE,onLoaded);
			xmlLoader.addEventListener (ProgressEvent.PROGRESS, progressHandler);	
		}
		
		private function onLoaded(e:Event):void
		{
			myXML = new XML(e.target.data);
			//trace(myXML.chapter[0].node[0].@timu);
			
			//建立选项
			
			submit_btn.addEventListener(MouseEvent.MOUSE_DOWN,submit_btnDown)
			submit_btn.buttonMode=true;
			var ss:int=myXML.chapter[0].node.length();
			
			var i:int;
			while(arr.length<10)
			{
				i=Math.random()*ss;
				if(arr.indexOf(i)==-1)arr.push(i);
			}
			//trace(arr);
			
			setOptions();
			
		}
		private function progressHandler(e:ProgressEvent):void
		{
			
		}
		
	    function setOptions()
		{
			
			Num_txt.text="第"+" "+(index+1)+" "+"题"
			rightNum=myXML.chapter[0].node[index].@thisAnswer;
			
			tixing=myXML.chapter[0].node[arr[index]].@tixing;
			test_Title.text=myXML.chapter[0].node[arr[index]].@timu;
			var cheStr:String=myXML.chapter[0].node[arr[index]].@content;
			
			var choArr=cheStr.split("#");
			for(var k:int=0;k<choArr.length;k++)
			{
				var choose_Btn:cho_btn=new cho_btn();
				choose_Btn.mouseChildren = false;
				choose_Btn.txt.text=choArr[k];
				
				choose_Btn.name=String(k);
				choose_Btn.x = 0;
				choose_Btn.y = 0 + 40 * k;
				cho_loadMc.addChild(choose_Btn);
				choose_Btn.addEventListener(MouseEvent.MOUSE_DOWN,choose_BtnDown)
				choose_Btn.buttonMode=true;
			
			}
			
		}
		
		private function choose_BtnDown(e:MouseEvent):void
		{
			if(tixing=="1"||tixing=="3")
			{
				resetBtnFun();
			
			}else if(tixing=="2")
			{
				
				
			}
			e.target.tipMc.gotoAndStop(2);
			/*if(e.target.name==rightNum)
			{
				
				rightINT+=1;
			}*/
		}
		
		private function resetBtnFun():void
		{
			var choseNum :int = cho_loadMc.numChildren;
			for (var k1:int = 0; k1 < choseNum; k1++ )
			{
				var myMovieClip:MovieClip = cho_loadMc.getChildAt(k1) as MovieClip;
				myMovieClip.tipMc.gotoAndStop(1);
			}
			
		}
		
		private function submit_btnDown(e:MouseEvent):void
		{
		
			var choseNum1 :int = cho_loadMc.numChildren;
			var answerStr="";
			var btnDownBoo=false;
			for (var k2:int = 0; k2 < choseNum1; k2++ )
			{
				var myClip:MovieClip = cho_loadMc.getChildAt(k2) as MovieClip;
				if(myClip.tipMc.currentFrame==2)
				{
					answerStr+=myClip.name;
					btnDownBoo=true;
				}
			}
			
			if(answerStr==myXML.chapter[0].node[arr[index]].@thisAnswer)
			{
				rightINT+=1;
			
			}
			//trace("正确的个数："+rightINT);
			if(btnDownBoo==true)
			{
				var popNum:int = cho_loadMc.numChildren;
				for (var kb = 0; kb < popNum; kb++)
				{		 
				   cho_loadMc.removeChildAt(0);	 
				}
				index+=1;
				if(index<=9)
				{
				    setOptions();
				}else
				{
					
					endpage.visible=true;
					endpage.score.text=rightINT*10+"分。";
					fscommand("SCORE", String(rightINT*10));
					if(rightINT>=8)
					{
						endpage.ssMc.gotoAndStop(1);
					}else
					{
						endpage.ssMc.gotoAndStop(2);
						
					}
				}
			}
		}
	}
}