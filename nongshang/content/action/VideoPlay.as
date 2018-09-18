package action{
	import flash.display.Sprite;
	import flash.events.*;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
	
	//常用的播放器
	public class VideoPlay extends Sprite{
		private var topSprite:Sprite = null;
		private var contentSprite:Sprite = null;
		private var isLoading:Boolean = true;
		private var loadingMc:LoadingMC = null;
		private var loadingMask:Sprite = null;
		
		private var videoURL:String = "video/EP52.mp4";
		private var video:Video = null;
		private var widthV:Number = 0;
		private var heightV:Number = 0;
		
		private var connection:NetConnection = null;
		private var stream:NetStream = null;
		//播放进度
		private var duration:Number = 0;
		private var currentTime:Number =0;
		//每30帧去改变时间
		private var playCount:int =0;
		public function VideoPlay(videoURL:String,width:Number,height:Number){
			super();
			this.videoURL = videoURL;
			this.width = width;
			this.height = height;
			init();
		}
		//播放或暂停true为播放，false为停止
		public function playOrPause(value:Boolean):void{
			if(value){
				stream.seek(currentTime);
				stream.resume();

			}else{
				currentTime = stream.time;
				stream.pause();
				
			}
		}
		//加载新的视频 
		public function loadingVideo(url:String):void{
			videoURL = url;
			stream.play(videoURL);
			currentTime=0;
			playCount=0;
		}
		//拖动更改播放进度
		public function changePlayProgress(ratio:Number):void{
			currentTime = ratio*duration;
			stream.seek(currentTime);
		}
		override public function set width(value:Number):void{
			widthV = value;
			if(video){
				video.width = value;
			}
			if(loadingMc){
				loadingMc.x = (widthV -loadingMc.width)*0.5;
			}
			if(loadingMask){
				loadingMask.width = value;
			}
		}
		
		 override public function set height(value:Number):void{
			 heightV = value;
			 if(video){
				 video.height = value;
			 }
			 if(loadingMc){
				 loadingMc.y =(heightV - loadingMc.height)*0.5;
			 }
			 if(loadingMask){
				 loadingMask.height = value;
			 }
			
		}
		private function init():void{
			contentSprite = new Sprite();
			this.addChild(contentSprite);
			
			topSprite = new Sprite();
			this.addChild(topSprite);
			
			loadingMask = new Sprite();
			loadingMask.graphics.beginFill(0x999999,0.5);
			loadingMask.graphics.drawRect(0,0,widthV,heightV);
			loadingMask.graphics.endFill();
			topSprite.addChild(loadingMask);
			loadingMc = new LoadingMC();
			topSprite.addChild(loadingMc);
			loadingMc.x = (widthV -loadingMc.width)*0.5;
			loadingMc.y =(heightV - loadingMc.height)*0.5;
			
			loadVideo();
		}
		
		private function loadVideo():void{
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			connection.connect(null);
			
		}
		

        private function netStatusHandler(event:NetStatusEvent):void {
			trace(event.info.code);
            switch (event.info.code) {
                case "NetConnection.Connect.Success":
                    connectStream();
					
                    break;
                case "NetStream.Play.StreamNotFound":
                    //trace("Unable to locate video: " + videoURL);
                    break;
				case "NetStream.Play.Stop":
					playOver();
					break;
            }
        }

        private function connectStream():void {
			topSprite.visible = false;
            stream = new NetStream(connection);
            stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			var customClient:Object = new Object();
			customClient.onMetaData = onMetaData;
			stream.client = customClient;
            video= new Video();
            video.attachNetStream(stream);
            stream.play(videoURL);
            contentSprite.addChild(video);
			
			this.addEventListener(Event.ENTER_FRAME,onEnterFrameHandler);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            //trace("securityErrorHandler: " + event);
        }
        
        private function asyncErrorHandler(event:AsyncErrorEvent):void {
            // ignore AsyncErrorEvent events.
        }
		private function onMetaData(data:Object):void { 
			duration = data.duration; 
			var event:MyVideoPlayEvent = new MyVideoPlayEvent(MyVideoPlayEvent.TOTAL_TIME_EVENT);
			event.totalTime = duration;
			this.dispatchEvent(event);

		} 
		private function onEnterFrameHandler(e:Event):void{
			playCount++;
			checkLoad();
			if(playCount%20==0){
				changePlayTime();
			}
		}
		private function playOver():void{
			trace("playOver");
			var evt:MyVideoPlayEvent = new MyVideoPlayEvent(MyVideoPlayEvent.PLAY_OVER);
			this.dispatchEvent(evt);
		}
		private function changePlayTime():void{
			var event:MyVideoPlayEvent = new MyVideoPlayEvent(MyVideoPlayEvent.CHANGE_BAR_TIME);
			event.currentTime = stream.time;
			this.dispatchEvent(event);
		}
		//根据加载状态，判断是否处于加载状态
		private function checkLoad():void{
			if(Math.round((stream.bytesLoaded/stream.bytesTotal)*100)<30)
			{
				if(isLoading==true)
				{
					topSprite.visible=true;
					stream.pause(); 
				    isLoading=false;
				}
	 
			}else{
				 if(isLoading==false)
				 {
					topSprite.visible=false;
					stream.resume(); 
				    isLoading=true;
				}
             }
		}
	}
}

class CustomClient {
    public function onMetaData(info:Object):void {
        trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
    }
    public function onCuePoint(info:Object):void {
        trace("cuepoint: time=" + info.time + " name=" + info.name + " type=" + info.type);
    }
}