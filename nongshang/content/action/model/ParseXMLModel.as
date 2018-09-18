package action.model{
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.Event;
    import flash.events.*;
	import action.model.ParseXMLEvent;
	import action.EventBus;
	
	public class ParseXMLModel extends EventDispatcher{
		private static  var _instance:ParseXMLModel;
		public static const LESSON_URL:String ="xml/lessonXml.xml";
		private var _xml:XML = null;
		private var lessonList:Array = null;
		private var videoList:Array = null;
		private var imgList:Array = null;
		//配置中的学习总时间
		public var total:String="0";
		//上次学习进度
		public var initLearnStatus:Array =[];
		//最后学习的子课程 id
		public var  lastLessonId:String = "0,0";
		//最后一视频index
		public var lastVideoIndex:int=0;
		//考试成绩
		public var score:int=0;
		//当前正在显示的子课程 
		public var currentLessonItemObj:LessonItemObj = null;
		public function ParseXMLModel($:A){
			super();
		}
		
		public static  function getInstance():ParseXMLModel{
			if(!_instance){
				_instance = new ParseXMLModel(new A());
			}
			return _instance;
		}

		
		public function loadXml():void{
			var request:URLRequest = new URLRequest(LESSON_URL);
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.load(request);
			xmlLoader.addEventListener(Event.COMPLETE,onXmlLoaded);
			xmlLoader.addEventListener(ProgressEvent.PROGRESS, onXmlProgressHandler);
		}
		
		public function getLessonList():Array{
			return lessonList;
		}
		public function getVideoList():Array{
			return videoList;
		}
		
		private function onXmlLoaded(e:Event):void{
			_xml = new XML(e.target.data);			
			lessonList=[];
			videoList =[];
			imgList = [];
			var lessonItemIndex:int=0;
			total = _xml.info.@total_time.toString();
			trace("totalTime:"+total);
			for(var i:int=0;i<_xml.lesson1.length();i++){				
				var lessonObj:LessonObj = new LessonObj();
				lessonObj.lessonId = ""+i;
				lessonObj.title = _xml.lesson1[i].@title;
				var isLearned:Boolean = true;
				var isOpened:Boolean = false;
				for(var j:int=0;j<_xml.lesson1[i].lesson2.length();j++){
					var lessonItemObj:LessonItemObj  =new LessonItemObj();
					lessonItemObj.lessonId =lessonObj.lessonId+","+j;
					lessonItemObj.title = _xml.lesson1[i].lesson2[j].@title.toString();
					var url:String = _xml.lesson1[i].lesson2[j].@url.toString();
					var urlArray:Array = url.split(",");
					lessonItemObj.url = parseUrl(urlArray,lessonObj.lessonId,lessonItemObj);
					if(initLearnStatus.length>0){
						lessonItemObj.isLearn = initLearnStatus[lessonItemIndex]==1?true:false;
					}else{
						lessonItemObj.isLearn = false;
					}
					if(lessonItemObj.lessonId==lastLessonId){
						lessonItemObj.isOpen = true;
						lastVideoIndex = lessonItemObj.videoIndex;
						isOpened = true;
					}else{
						lessonItemObj.isOpen = false;
					}
					lessonObj.lessonList.push(lessonItemObj); 
					lessonItemIndex++;
					if(!lessonItemObj.isLearn){
						isLearned = false;
					}
				}
				lessonObj.isLearn = isLearned;
				lessonObj.isOpen = isOpened;
				trace("lessonObjid:"+lessonObj.lessonId +"__isOpen:"+lessonObj.isOpen);
				lessonList.push(lessonObj);
				
			}
			addTestButton();
			var evt:ParseXMLEvent = new ParseXMLEvent(ParseXMLEvent.PARSE_COMPLETE);
			this.dispatchEvent(evt);
		}
		//增加测试按钮
		private function addTestButton():void{
			var testObj:LessonObj = new LessonObj();
			testObj.title = "测试";
			testObj.isOpen = false;
			testObj.lessonId = lessonList.length+"";
			testObj.isTest = true;
			if(this.score>=80){
				testObj.isLearn = true;
			}else{
				testObj.isLearn =  false;
			}
			lessonList.push(testObj);
		}
		
		private function parseUrl(value:Array,lessonId:String,lessonItem:LessonItemObj):Array{
			var newArr:Array = new Array();
			var url:String="";
			var obj:VideoObj = null;
			lessonItem.videoIndex = videoList.length;
			for(var i:int=0;i<value.length;i++){
				url = "video/"+value[i]+".mp4";
				newArr.push(url);
				obj = new VideoObj();
				obj.id = lessonId+","+lessonItem.lessonId;
				obj.titleId = lessonId;
				obj.lessonId = lessonItem.lessonId;
				obj.url = url;
				obj.imgUrl = "img/"+value[i]+".jpg";
				videoList.push(obj);
			}
			return value;
		}
		private function parseImgUrl(value:Array,lesssonId:String):Array{
			var newArr:Array = new Array();
			var url:String="";
			for(var i:int=0;i<value.length;i++){
				url = "img/"+value[i]+".jpg";
				newArr.push(url);
			}
			return newArr;
		}
		private function onXmlProgressHandler(e:Event):void{
			
		}
	}
}

class A{
	public function A(){
		
	}
}