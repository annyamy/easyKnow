package action
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.events.ProgressEvent;
	import flash.display.Bitmap;
    import flash.net.URLRequest;
    import flash.net.NetConnection;
    import flash.net.NetStream;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.display.StageDisplayState;
	import action.model.ParseXMLModel;
	import action.model.ParseXMLEvent;
	import action.model.VideoObj;
	import action.view.LessonEvent;
	import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;	
	import action.model.LessonObj;
	import action.model.LessonItemObj;
	import action.view.TipView;
	import flash.net.URLLoader;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;

	public class main extends MovieClip
	{
		private var imgLoader:Loader = null;
		private var imgBitmap:Bitmap = null;
		private var smallW:SmallWindow = null;
		private var smallContainer:Sprite = null;
		private var smallMask:SmallMask = null;
		private var mainW:MainWindow = null;
		private var mainContainer:Sprite = null;
		private var bigMask:BigMask = null;
		
		
		private var controlMC:ControlMoveClip=null;
		private var playBtn:PlayBtn = null;
		private var preBtn:PreBtn = null;
		private var nextBtn:NextBtn = null;
		
		private var progressMC:ProgressBar= null;
		private var  currentTimeTF:TextField = null;
		private var currentTotalTimeTF:TextField = null;
		private var totalTimeTF:TextField = null;
		
		private var tipView:TipView = null;
		
		private var currentTime:Number=0;
		private var totalTime:Number=0;
		
		//是否正在播放
		private var isPlay:Boolean = false;
		private var imgURL:String ="img/defaultImg02.png";
		private var titleURL:String = "img/titleImg.png";
		private var videoURL:String ="video/EP52.mp4";
		private var testSwfURl:String = "test.swf";
		//主屏是否是视频
		private var isVideo:Boolean =false;
		
		
		//加载视频
		private var videoPlay:VideoPlay=null;
		private var playIndex:int=0;
		private var playList:Array =[];
		private var lessonList:Array =[];
		
		//课程列表
		private var lessonView:LessonView=null;
		//接受到全部数据后再解析
		private var receivedIndex:int=0;
		
		private var reCallCount:int=0;
		//测试面板
		private var testView:MovieClip = null;
		//课程完成百分比
		private var learnRatio:int=0;
		//是否正在考试
		private var isTesting:Boolean = false;
		//正在学习的子目录
		private var currentItem:LessonItemObj = null;
		public function main()
		{
			super();
			stage.addEventListener(MouseEvent.RIGHT_CLICK,function(e:MouseEvent):void{});	
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.quality = "HIGH";
			//init();
			initJS();
		}
		//考试完成后，判断是否学习完成
		public function sonData(value:Number):void{
			if(value>ParseXMLModel.getInstance().score){
				ParseXMLModel.getInstance().score = value;
				this.lessonView.updataScore(value);
				onCheckComplete();
				if(ExternalInterface.available){
					ExternalInterface.call("setLocation",value.toString()+"#"+ParseXMLModel.getInstance().score);
				}
			} 

		}
		private function initJS():void{
			if (ExternalInterface.available) 
			{
			  try {
                    ExternalInterface.addCallback("sendLocationToActionScript", receivedFromJavaScript);
		            ExternalInterface.addCallback("sendSuspendToActionScript", receivedProgressFromJavaScript);
					//ExternalInterface.addCallback("sendScoreToActionScript",receivedScoreFromJS);
		            ExternalInterface.call("getLocation");
		            ExternalInterface.call("getSuspend");                   
					//ExternalInterface.call("getScore");
                } catch (error:SecurityError) {
                  //output.appendText("A SecurityError occurred: " + error.message + "\n");
					reCallCount++;
					if(reCallCount>3){
						init();
					}else{
						initJS();
					}
                } catch (error:Error) 
				{
                    //output.appendText("An Error occurred: " + error.message + "\n");
					reCallCount++;
					if(reCallCount>3){
						init();
					}else{
						initJS();
					}
                }
			}else 
			{
               trace("External interface is not available for this container.");
			   init();
				//receivedFromJavaScript("1,0#6");
				//receivedProgressFromJavaScript("1,1,1,0,0,0,0,0,0");
            }
		}
		//课程学习进度
		private function receivedFromJavaScript(value:String=null):void{
			receivedIndex++;
			if(!value){
				value="0,0:0"
			}
			ParseXMLModel.getInstance().lastLessonId= value.split("#")[0];
			ParseXMLModel.getInstance().score = parseInt(value.split("#")[1]);
			if(receivedIndex>=2){
				if(ParseXMLModel.getInstance().lastLessonId &&
					ParseXMLModel.getInstance().initLearnStatus.length>0)
				{
					showTip();
				}else{
					init();
				}
				
			}
		}
		
		//子课程的学习状态
		private function receivedProgressFromJavaScript(value:String=null):void{
			receivedIndex++;
			if(value && value.split(",").length>1){
				ParseXMLModel.getInstance().initLearnStatus = value.split(",");
				var progress:Array = value.split(",");
				var count:int=0;
				for(var i:int=0;i<progress.length;i++){
					count+= parseInt(progress[i]);
				}
				this.learnRatio = Math.floor(count/progress.length*100);
			}
			if(receivedIndex>=2){
				if(ParseXMLModel.getInstance().lastLessonId &&
					ParseXMLModel.getInstance().initLearnStatus.length>0)
				{
					showTip();
				}else{
					init();
				}
			}
		}
		
		private function receivedScoreFromJS(value:String):void{
			receivedIndex++;
			if(value){
				ParseXMLModel.getInstance().score = Number(value);
			}
			if(receivedIndex>=3){
				
				if(ParseXMLModel.getInstance().lastLessonId &&
					ParseXMLModel.getInstance().initLearnStatus.length>0)
				{
					showTip();
				}else{
					init();
				}
			}
		}
		//打开提示面板，选择是否读取进度
		private function showTip():void{
			tipView = new TipView();

			this.addEventListener(LessonEvent.CLOSE_TIP_VIEW,onCloseTipHandler);
			this.addChild(tipView);
			
		}
		
		private function onCloseTipHandler(e:LessonEvent):void{
			tipView.clear();
			this.removeChild(tipView);
			this.addEventListener(LessonEvent.CLOSE_TIP_VIEW,onCloseTipHandler);
			var isRead:Boolean = e.isRead;
			if(!isRead){
				ParseXMLModel.getInstance().lastLessonId="0,0"
			//	ParseXMLModel.getInstance().initLearnStatus = [0,0,0,0,0,0,0,0,0];
			}
			init();
		}
		
		private function init():void{
			initListener();
			initModel();
			initView();
		}
		private function initModel():void{
			ParseXMLModel.getInstance().addEventListener(ParseXMLEvent.PARSE_COMPLETE,onParseCompleteHandler);
			ParseXMLModel.getInstance().loadXml();
		}
		//数据解析完成后，加载图片和视频(此处有坑，parseXmlModel事件监听，要放在事件抛出之后)
		private function onParseCompleteHandler(e:ParseXMLEvent):void{
			playIndex=ParseXMLModel.getInstance().lastVideoIndex;
			playList = ParseXMLModel.getInstance().getVideoList();
			var videoObj:VideoObj = playList[playIndex];
			lessonList = ParseXMLModel.getInstance().getLessonList();
			ParseXMLModel.getInstance().currentLessonItemObj = (lessonList[parseInt(videoObj.titleId)] as LessonObj).lessonList[parseInt(videoObj.lessonId.split(",")[1])];
			imgURL = videoObj.imgUrl;
			videoURL = videoObj.url;
			loadImg();
			loadVideo();
			updateUI();
			initList();
			controlMC.totalTime.text =ParseXMLModel.getInstance().total;
		}
		
		private function initView():void{
			initControlView();
			initWindowView();
			lessonView = this.list;
		}
		//数据解析好后，初始化课程列表
		private function initList():void{
			lessonList = ParseXMLModel.getInstance().getLessonList();
			lessonView.setData(lessonList);
		}
		
		private function initWindowView():void{
			smallW = this.smallWindow;
			smallContainer = new Sprite();
			smallW.addChild(smallContainer);
			
			mainW = this.mainWindow;
			mainContainer = new Sprite();
			mainW.addChild(mainContainer);
			//loadImg();
			//loadVideo();
			imgLoader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			
			var titleLoader:Loader = new Loader();
            titleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, titleCompleteHandler);
			titleLoader.load(new URLRequest(titleURL));
		}
		
		private function loadImg():void{

			imgLoader.load(new URLRequest(imgURL));
		}
		private function progressHandler(e:ProgressEvent):void{
			

		}
		private function titleCompleteHandler(e:Event):void{
			var bitmap:Bitmap = Bitmap(e.target.loader.content);
			bitmap.smoothing = true;
			bitmap.x =1000-bitmap.width;
			bitmap.y = 13;
			this.addChild(bitmap);
		}
		
		private function completeHandler(e:Event):void{
            imgBitmap = Bitmap(imgLoader.content);
			imgBitmap.smoothing = true;
			if(isVideo){
				while(smallContainer.numChildren>0){
					smallContainer.removeChildAt(0);
				}
				imgBitmap.width = smallW.width;
				imgBitmap.height = smallW.height;
				
				smallContainer.addChild(imgBitmap);		
			}else{
				while(mainContainer.numChildren>0){
					mainContainer.removeChildAt(0);
				}
				imgBitmap.width = mainW.width;
				imgBitmap.height = mainW.height;

				mainContainer.addChild(imgBitmap);
			}
			
		}
		
		private function loadVideo():void{
			
			videoPlay = new VideoPlay(videoURL,smallW.width,smallW.height);
			videoPlay.addEventListener(MyVideoPlayEvent.TOTAL_TIME_EVENT,onTotalTimeEvent);
			videoPlay.addEventListener(MyVideoPlayEvent.CHANGE_BAR_TIME,onChangeBarTime);
			videoPlay.addEventListener(MyVideoPlayEvent.PLAY_OVER,onPlayOverHandler);
			if(!isVideo){
				videoPlay.width = smallW.width;
				videoPlay.height = smallW.height;
				while(smallContainer.numChildren>0){
					smallContainer.removeChildAt(0);
				}				
				smallContainer.addChild(videoPlay);			
			}else{
				videoPlay.width = mainW.width;
				videoPlay.height = mainW.height;
				
				while(mainContainer.numChildren>0){
					mainContainer.removeChildAt(0);
				}

				mainContainer.addChild(videoPlay);
			}
		}
		
		private function onTotalTimeEvent(e:MyVideoPlayEvent):void{
			totalTime = e.totalTime*1000;
			currentTotalTimeTF.text=convertTime(totalTime);
			startProgressBar();
			isPlay = true;
			playBtn.gotoAndStop(2);
			
			currentTime = 0;
			currentTimeTF.text = convertTime(currentTime);
			progressMC.changeRatio(currentTime/totalTime);
		}
		
		private function onChangeBarTime(e:MyVideoPlayEvent):void{
			currentTime = e.currentTime*1000;
			currentTimeTF.text = convertTime(currentTime);
			progressMC.changeRatio(currentTime/totalTime);
		}
		
		private function startProgressBar():void{
			
		}
		
		//当前视频播放完毕,加载下一个,课程列表选中状态也随之改变,
		private function onPlayOverHandler(e:MyVideoPlayEvent=null):void{
			maskStatus(playIndex);
			if(playIndex<playList.length-1){
				playIndex++;
				changeLessonContent(playIndex);
			}else{
				onOpenTestViewHandler();
			}
		}
		//每播放完一个视频，记录学习进度
		private function maskStatus(index:int):void{
			var videoObj:VideoObj = playList[index];
			if(videoObj){
				var titleObj:LessonObj =null;
				var itemObj:LessonItemObj = null;
				var titleLength:int = lessonList.length;
				var learnStuts:Array=[];
				var learnedCount:int=0;
				for(var i:int=0;i<titleLength;i++){
					titleObj = lessonList[i];
					var isTitleLearn:Boolean = true;
					for(var j:int=0;j<titleObj.lessonList.length;j++){
						itemObj = titleObj.lessonList[j];
						var result:int=0;
						if(itemObj.isLearn){
							 result= itemObj.isLearn?1:0;
							learnedCount+=result;
							learnStuts.push(result);
							continue;
						}
						if(itemObj.lessonId == videoObj.lessonId){
							if(itemObj.url.length==1){
								if(itemObj.videoIndex == index){
									itemObj.isLearn = true;
								}else{
									itemObj.isLearn = false;
								}
							}else{
								if(itemObj.videoIndex+itemObj.url.length-1==index){
									itemObj.isLearn = true;
								}else{
									itemObj.isLearn = false;
								}
							}
						}
						if(!itemObj.isLearn){
							isTitleLearn= false;
						}
						result= itemObj.isLearn?1:0;
							learnedCount+=result;
						learnStuts.push(result);
					}
					if(titleObj.isTest){
						if(ParseXMLModel.getInstance().score>=80){
							titleObj.isLearn = true;
						}else{
							titleObj.isLearn = false;
						}
					}else{
						titleObj.isLearn = isTitleLearn;	
					}
					
				}
				lessonView.updata(lessonList);
				learnRatio = Math.floor(learnedCount/learnStuts.length*100);
				saveProgressData(learnStuts,learnRatio);
			}
		}
		private function initControlView():void{
			controlMC = this.controlBar;
			playBtn = controlMC.playBtn;
			playBtn.buttonMode= true;
			
			preBtn = controlMC.preBtn;
			preBtn.buttonMode = true;
			
			nextBtn = controlMC.nextBtn;
			nextBtn.buttonMode = true;
			
			progressMC = controlMC.progress;
			currentTimeTF = controlMC.currentTime;
			currentTimeTF.text = convertTime(currentTime);
			currentTotalTimeTF = controlMC.currentTotalTime;
			currentTotalTimeTF.text=convertTime(totalTime);
			totalTimeTF = controlMC.totalTime;
			totalTimeTF.text =ParseXMLModel.getInstance().total;
		
			updateUI();
			
			initControlListner();
		}
		
		private function updateUI():void{
			if(preBtn){
				if(playIndex<=0){
					preBtn.mouseEnabled = false;
					preBtn.gotoAndStop(2);
				}else{
					preBtn.mouseEnabled  = true;
					preBtn.gotoAndStop(1);
				}
			}
			
			if(nextBtn){
				if(playIndex>=playList.length-1){
					trace("nextBtn is dis");
					nextBtn.mouseEnabled = false;
					nextBtn.gotoAndStop(2);
				}else{
					nextBtn.mouseEnabled = true;
					nextBtn.gotoAndStop(1);
				}
			}
			controlMC.mouseEnabled=true;
			controlMC.mouseChildren =true;
		}
		
		private function initListener():void{
			this.addEventListener(LessonEvent.CHANGE_VIDEO,onChangeVideoHandler);
			this.addEventListener(LessonEvent.OPEN_TEST_VIEW,onOpenTestViewHandler);
		}
		
		private function initControlListner():void{
			progressMC.addEventListener(ChangeTimeEvent.CHANGE_TIME,changeTimeHandler);
			
			
			playBtn.addEventListener(MouseEvent.CLICK,onPlayClickHandler);
			preBtn.addEventListener(MouseEvent.CLICK,onPreClickHandler);
			nextBtn.addEventListener(MouseEvent.CLICK,onNextClickHandler);
		}
		
		//通过拖动改变播放进度
		private function changeTimeHandler(e:ChangeTimeEvent):void{
			var ratio:Number = e.ratio;
			this.currentTime = ratio*this.totalTime;
			currentTimeTF.text = convertTime(currentTime);
			if(videoPlay){
				videoPlay.changePlayProgress(ratio);
			}
		}
		
		private function onChangeScreenMouseOver(e:MouseEvent):void{
			controlMC.tip1.visible = true;
		}
		
		private function onChangeScreenMouseOut(e:MouseEvent):void{
			controlMC.tip1.visible = false;
		}
		
		private function onChangeScreenClick(e:MouseEvent):void{
			trace("______onchangeScreenClick:"+isVideo);
			while(smallContainer.numChildren>0){
				smallContainer.removeChildAt(0);
			}
			while(mainContainer.numChildren>0){
				mainContainer.removeChildAt(0);
			}
			if(isVideo){	
				if(imgBitmap){
					imgBitmap.width = mainW.width;
					imgBitmap.height = mainW.height;
					mainContainer.addChild(imgBitmap);
				}
				if(videoPlay){
					videoPlay.width = smallW.width;
					videoPlay.height = smallW.height;
					smallContainer.addChild(videoPlay);
				}								
				isVideo = false;
			}else{				
				if(imgBitmap){
					imgBitmap.width = smallW.width;
					imgBitmap.height = smallW.height;
					smallContainer.addChild(imgBitmap);
				}
				if(videoPlay){
					videoPlay.width = mainW.width;
					videoPlay.height = mainW.height;
					mainContainer.addChild(videoPlay);
				}
				isVideo = true;
			}
			
		}
		
		private function onFullScreenMouseOver(e:MouseEvent):void{
			controlMC.tip2.visible = true;
		}
		
		private function onFullScreenMouseOut(e:MouseEvent):void{
			controlMC.tip2.visible = false;
		}
		//
		private function onFullScreenClick(e:MouseEvent):void{
			stage.displayState=StageDisplayState.FULL_SCREEN;
			var ratio:Number = stage.width/stage.height;
			var videoRatio:Number = videoPlay.width/videoPlay.height
			if(ratio<=videoRatio){
				videoPlay.width = stage.width;
				videoPlay.height =  videoPlay.width/videoRatio;
			}else{
				videoPlay.height = stage.height;
				videoPlay.width = videoPlay.height*videoRatio;
			}
			videoPlay.addEventListener(MouseEvent.CLICK,onEscFullScreen);
			stage.addEventListener(KeyboardEvent.KEY_UP,onKeyUpHandler);
			this.addChild(videoPlay);

		}
		
		private function onEscFullScreen(e:MouseEvent=null):void{
			stage.displayState=StageDisplayState.NORMAL;
			videoPlay.removeEventListener(MouseEvent.CLICK,onEscFullScreen);
			stage.removeEventListener(KeyboardEvent.KEY_UP,onKeyUpHandler);
			if(!isVideo){
				videoPlay.width = smallW.width;
				videoPlay.height = smallW.height;
				while(smallContainer.numChildren>0){
					smallContainer.removeChildAt(0);
				}				
				smallContainer.addChild(videoPlay);			
			}else{
				videoPlay.width = mainW.width;
				videoPlay.height = mainW.height;
				while(mainContainer.numChildren>0){
					mainContainer.removeChildAt(0);
				}
				mainContainer.addChild(videoPlay);
			}
		}
		private function onKeyUpHandler(evt:KeyboardEvent):void{
			if(evt.keyCode ==27){
				onEscFullScreen();
			}
		}
		
		//点击开始播放按钮
		private function onPlayClickHandler(e:MouseEvent=null):void{
			if(isPlay){
				playBtn.gotoAndStop(1);
				isPlay =false;
			}else{
				playBtn.gotoAndStop(2);
				isPlay =true;
			}
			videoPlay.playOrPause(isPlay);
		}
		//改变视频，课件，课程内容
		private function changeLessonContent(index:int):void{
			var videoObj:VideoObj = playList[index];
			if(isVideo){
				videoPlay.width = mainW.width;
				videoPlay.height = mainW.height;				
				while(mainContainer.numChildren>0){
					mainContainer.removeChildAt(0);
				}
				mainContainer.addChild(videoPlay);
			}
			if(videoObj){
				imgURL = videoObj.imgUrl;
				videoURL = videoObj.url;
				loadImg();
				videoPlay.loadingVideo(videoURL);
				updateUI();
				lessonView.changeLesson(videoObj);
				saveLoaction(videoObj.lessonId);
				ParseXMLModel.getInstance().currentLessonItemObj = (lessonList[parseInt(videoObj.titleId)] as LessonObj).lessonList[parseInt(videoObj.lessonId.split(",")[1])];

			}
			
		}
		
		private function onPreClickHandler(e:MouseEvent):void{
			if(preBtn.mouseEnabled){
				playIndex--;
				changeLessonContent(playIndex);
				
			}
		}
		
		private function onNextClickHandler(e:MouseEvent):void{
			if(nextBtn.mouseEnabled){
				playIndex++;
				changeLessonContent(playIndex);
			}
		}
		//点击课程子对象，切换播放内容
		private function onChangeVideoHandler(e:LessonEvent):void{
			videoPlay.addEventListener(MyVideoPlayEvent.TOTAL_TIME_EVENT,onTotalTimeEvent);
			videoPlay.addEventListener(MyVideoPlayEvent.CHANGE_BAR_TIME,onChangeBarTime);
			videoPlay.addEventListener(MyVideoPlayEvent.PLAY_OVER,onPlayOverHandler);
			var index:int = e.videoIndex;
			playIndex = index;
			if(playIndex<=playList.length){
				changeLessonContent(playIndex);
			}
		}
		//把时间毫秒换成字符串
		private function convertTime(value:Number):String{
			var hour:int = value/(1000*60*60);
			value = value%(1000*60*60)
			var minutes:int = value/(60*1000);
			value=value%60000;
			var second:int =value/1000;
			if(hour>0){
				return formatTime(hour)+":"+formatTime(minutes)+":"+formatTime(second);
			}else{
				return formatTime(minutes)+":"+formatTime(second);
			}
		}
		
		private function formatTime(value:int):String{
			if(value<10){
				return "0"+value;
			}else{
				return value+"";
			}
		}
		//保存学习进度,若之前有考试，则学完就可以算通过
		private function saveProgressData(value:Array,ratio:Number):void{
			trace("学习程度："+ratio.toString());
			trace("学习进度:"+value.toString());
			onCheckComplete();
			if(ExternalInterface.available){
				ExternalInterface.call("setprogressdata", ratio.toString());
				ExternalInterface.call("setSuspenddata", value.toString());	
			}
			
		}
		
		//保存上次学习的位置
		private function saveLoaction(value:String):void{
			trace("学习位置:"+value);
			if(ExternalInterface.available){
				ExternalInterface.call("setLocation",value.toString()+"#"+ParseXMLModel.getInstance().score);
			}
		}
		
		//打开测试面板
		private function onOpenTestViewHandler(e:LessonEvent=null):void{
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE,onTestLoaded);
			loader.contentLoaderInfo.addEventListener (ProgressEvent.PROGRESS, onTestProgressHandler);
			loader.load(new URLRequest(testSwfURl));
		}
		
		private function onTestLoaded(e:Event):void{
			testView = e.target.content as MovieClip;
			while(mainContainer.numChildren>0){
				mainContainer.removeChildAt(0);
			}
			mainContainer.addChild(testView);
			controlMC.mouseEnabled=false;
			controlMC.mouseChildren =false;
			isPlay = true;
			onPlayClickHandler();
			videoPlay.removeEventListener(MyVideoPlayEvent.TOTAL_TIME_EVENT,onTotalTimeEvent);
			videoPlay.removeEventListener(MyVideoPlayEvent.CHANGE_BAR_TIME,onChangeBarTime);
			videoPlay.removeEventListener(MyVideoPlayEvent.PLAY_OVER,onPlayOverHandler);
			testView.getDat(learnRatio,this,ParseXMLModel.getInstance().score);

		}
		
		private function onTestProgressHandler(e:ProgressEvent):void{
			
		}
		//判断是否完成学习 若完成则调js
		private function onCheckComplete():void{
			trace("score:"+ParseXMLModel.getInstance().score+"___"+"progress:"+this.learnRatio);
			if(ParseXMLModel.getInstance().score>=80 && this.learnRatio>=50){
				if(ExternalInterface.available){
					ExternalInterface.call("SetComplete");
				}
			}
		}
					
	}
}
