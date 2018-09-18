package Scripts
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
 	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.SimpleButton;
	import flash.text.TextField;
	
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;

	import fl.transitions.*;					//过渡效果
	import fl.transitions.easing.*;
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;

	import flash.external.ExternalInterface;	//as与js通信
	
	import flash.system.fscommand;
	import flash.system.System;
	import flash.system.Security;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author ...
	 */
	public class MetalInvest extends MovieClip
	{
		private static var LEVEL1:String="level1";
		private static var LEVEL2:String="level2";
		private static var LEVEL3:String="level3";
		
		private var loader_index:Loader;
		private var XMLloader:URLLoader;					
		private var xml:XML;				
		private var loader:Loader;							//加载swf
		private var mc:MovieClip=new MovieClip();			//用于加载swf课程的容器
		private var mc_swf:MovieClip=new MovieClip();		//用于控制的承载对象
		private var index_swf:int=-1;						//当前播放的swf的编号
		private var arr_list:Array = new Array();			//播放列表
		private var swf_totalFrames:int = 0;				//加载swf的总帧数
		

		//目录处理变量
		private var arr_menuc:Array=new Array();			//一级目录
		private var arr_menuj:Array=new Array();			//二级目录
		private var arr_menut:Array=new Array();			//三级目录
		private var menuc_height:Number=0;				
		private var menuj_height:Number=0;				
		private var menut_height:Number=0;				
		private var menu_x:Number=0;						//&&&&&&&&&&&&&&&&&&&&需要设置
		private var menu_y:Number=0;
		private var hkRect:Rectangle;						//目录滑块拖动范围
		private var isDown_hk:Boolean=false;				//目录滑块是否按下的标识
		private var hky:Number;								//目录滑块的y坐标值
		private var hky_tmp:Number;
		private var height_change:Number;					//目录展开时的总高度的改变值
		private var _count_child:int = 0;					//用来计内部子集的子集的个数
		private var hkRect_y:Number = 0;					//用于滚动条滑块的顶部有特殊效果的
		private var _isChangeSWF:Boolean = true;
		
		private var arr_childName:Array = new Array();		//要删除的一级子集的实例名数组
		private var arr_childName2:Array = new Array();		//要删除的二级子集的实例名数组
		private var arr_reading:Array = new Array();
		private var arr_readed:Array = new Array();
		//private var _isPlay_SWF:Boolean = true;				//用于目录出现和消失后，当前swf是否播放的标识
		private var arr_listIndex:Array = new Array();
		//平台交互
		private var nc:String = "";
		private var locationStr:String = "";
		private var _isMUlU:Boolean = true;
		
		
		//special
		//mulutiao_btn
		private var loading_width:Number = 150.05;
		/*....
		 * 对于indexj的解释：
		 * 舞台上的indexj----->>都是arr_menuj的真是的index
		 * 数组中存储的indexj都是父级目录以下的递增的index
		....*/
		
		public function MetalInvest()
		{
			addFrameScript(2, enterFrame3);	
			gotoAndStop(1);
			loadIndex();
			readXML();
			//上传平台 打开download() 和 fscommand()
			//download();
			//handleReceivedData("10#0000000000001100000000000000000000000000000");
		}
	//-----------------------------------平台交互---------------------------------------------------

		private function download():void
		{
			if (!ExternalInterface.available) 
			{
				trace("ExternalInterface:	not available");
				return;
			}
			try
			{
				if (xml!=null && xml.@type == "suspend")
				{
					ExternalInterface.addCallback("sendSuspendToActionScript", receivedFromJavaScript);
					ExternalInterface.call("getSuspend");
				}
				else
				{
					ExternalInterface.addCallback("sendLocationToActionScript", receivedFromJavaScript);
					ExternalInterface.call("getLocation");
				}
				
			} 
			catch(error:Error) 
			{
				trace("ExternalInterface出现错误：	",error.message);
			}
		}
		
		private function receivedFromJavaScript(str:String):void
		{
			handleReceivedData(str);				//------>>返回的数据是location  还是suspendstr
		}
		
		//处理从平台接收到数据
		private function  handleReceivedData(str:String):void
		{
			if (str == "" && str != null)
			{
				trace("location 为空！！！");
				return;
			}
			else
			{
				trace("ReceivedData :	", str);
				if (xml != null && xml.@type == "suspend")
				{
					str = str.substr(0, str.length - 3);
				}
				var arr_tmp:Array = str.split("#");
				index_swf = int(arr_tmp[0]);
				var str_tmp:String = arr_tmp[1];
				if (str_tmp != "")
				{
					for (var i:int = 0; i < str_tmp.length; i++)
					{
						if (str_tmp.substr(i, 1) == "1")
						{
							arr_listIndex.push(i);
						}
					}
				}
			}
			trace("平台接收数据解析为index:",index_swf + "*********", arr_listIndex.toString());
		}
		
		//提交到平台
		public function submitToPlatform():void
		{
			try
			{
				if (index_swf != -1)
				{
					var string:String=new String();
					string = index_swf + "#" + locationStr;		
					
					fscommand("LOCATION", string);
					fscommand("SUSPEND", (string+"jjjj"));
					trace("location:	",string);	
				}
				var suspend_str:String = arr_list[index_swf] + "#" + arr_readed.toString();
				
				var progress:Number = int(arr_readed.length / arr_list.length * 100);
				fscommand("PROGRESSDATA", progress.toString());
				trace("progress:	" + progress);
				if(progress==100)
				{
					fscommand("SETCOMPLETE");
					trace("readed	complete");
				}
			}
			catch (error:SecurityError) 
			{
                trace("ExternalInterface*****A SecurityError occurred: " + error.message + "\n");
            } 
			catch (error:Error) 
			{
                trace("ExternalInterface*****An Error occurred: " + error.message + "\n");
            }
		}

		//从平台接收数据
		/*private function handleReceivedSuspendData(str:String):void
		{
			if (str == "")		return ;
			var arr1:Array = str.split("#");
			index_swf = getPlayIndex(arr1[0]);
			if (arr1[1]!= "")
			{
				var arr2:Array = arr1[1].split(",");
				arr_readed = arr2;					
			}	
		}*/
		
		private function initLocationStr():void
		{
			if (arr_readed.length == 0)
			{
				var string1:String = "";
				for (var j:int = 0; j < arr_list.length; j++)
				{
					string1+="0"
				}
				locationStr = string1;
			}
			else
			{
				getLocationStr();
			}
		}
		
		private function getLocationStr():void
		{
			var string2:String = "";
			for (var i:int = 0; i < arr_list.length; i++)
			{
				if (getReadSWFIndex(arr_list[i]) == -1)
				{
					string2 += "0";
				}
				else
				{
					string2 += "1";
				}
			}
			locationStr = string2;
		}
		
		private function getReadSWFIndex(swfName:String):int
		{
			for(var i:int=0;i<arr_readed.length;i++)
			{
				if(arr_readed[i]==swfName)
				{
					return i;
				}
			}
			return -1;
		}
		
		private function pushIntoArrRead(arr_tmp:Array):void
		{
			if (index_swf == -1)
				return;
			for (var i:int = 0; i < arr_tmp.length; i++)
			{
				var index_tmp:int = int(arr_tmp[i]);
				arr_readed.push(arr_list[index_tmp]);
			}
			arr_readed.sort();
			trace("从平台上获取的数据--->arr_readed:	",arr_readed.toString());
		}
		
		//-----------------------------------加载的特殊的swf 的处理--------------------------
		private function specialProcess_changeSWF():void
		{
			if (arr_list[index_swf] == "c03s07p01" || arr_list[index_swf] == "c04s05p01")
			{
				if (mc_swf != null )
				{
					SoundMixer.stopAll();
				}
				if (mc_swf.hasEventListener(Event.ENTER_FRAME))
				{
					trace("has	Event.ENTER_FRAME",mc_swf.hasEventListener(Event.ENTER_FRAME));
					mc_swf.removeEventListener(Event.ENTER_FRAME,mc_swf.enterFrameHandler);
					trace("has	Event.ENTER_FRAME",mc_swf.hasEventListener(Event.ENTER_FRAME));
				}
			}
		}
		
		private function specialProcess_playStart():void
		{			
			if (arr_list[index_swf] != "c03s07p01" && arr_list[index_swf] != "c04s05p01" )
			{
				if (kzui_mc.jdd_mc.mouseEnabled )
				{
					kzui_mc.jdd_mc.mouseChildren = false;
					kzui_mc.jdd_mc.mouseEnabled = true;
					kzui_mc.jdd_mc.enabled = true;
					kzui_mc.jdd_mc.alpha = 1;
					kzui_mc.jdd_mc.buttonMode = true;
					//kzui_mc.jdd_mc.useHandCursor = true;
				}
				
				if (!kzui_mc.porp_mc.mouseEnabled)
				{
					kzui_mc.porp_mc.mouseChildren = true;
					kzui_mc.porp_mc.mouseEnabled = true;
					kzui_mc.porp_mc.enabled = true;
					kzui_mc.porp_mc.alpha = 1;
				}
				
			}
			
		}		
		
		private function specialProcess_playStart2():void
		{
			/*if (arr_list[index_swf] != "c03s07p01" )
			{
				btnPPSet(true);
				kzui_mc.jdd_mc.buttonMode = true;
				kzui_mc.jdd_mc.mouseEnabled = true;
				
			}*/
			
		}	
		
		private function specialProcess_framehandler():void
		{
			
			
			
			
		}
		
		private function zimuVisInit():void
		{
			if (mc_swf != null && mc_swf._mc != null)
			{
				mc_swf._mc.cacheAsBitmap = true;
				mc_swf._mc.visible = kzui_mc.zimu_mc.close_mc.visible;
			}
			
		}
		
		private function mouseWheelRemoveProcess():void
		{
			if (mulu_mc != null && mulu_mc.y > 70)
			{
				if (mulu_mc.gdt.hk.visible)
				{
					removeEventListener(MouseEvent.MOUSE_WHEEL, mulu_WheelHandler);
				}
			}
		}
		
		//缓冲动画的初始化===================>>修改	loadProgress_Handler
		private function bufferInit():void
		{
			loading_mc.visible = true;
			loading_mc._txt.text = "0%";
			loading_mc.bar_mc.width = 0;
		}
		
		
		private function stage_forUIName_ClickHandler(evt:MouseEvent):void
		{
			if (evt.target != null && evt.target.name != null)
				trace("stage_forUIName_ClickHandler------>	evt.target:	",evt.target,"	****evt.target.name:	", evt.target.name);
		}
		
		
		//------------------------------------------------------------------------------------------------
		
		//第三帧的帧代码--------------进入课程界面的初始化
		private function enterFrame3():void
		{
			kzui_mc.page_txt.text="0/0";			
	
			btnPPVisSet(true);
			kzui_mc.zimu_mc.open_mc.visible = false;
			kzui_mc.zimu_mc.close_mc.visible = true;
			
			//mulu_btn
			kzui_mc.mulu_btn.mouseEnabled = false;			
			kzui_mc.mulu_btn.alpha = 0.5;
			
			mulutiao_btn.mouseEnabled = false;
			
			//jdt
			kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.width * ( -1) + kzui_mc.jdd_mc.x;		//&&&&&&&&&&&&&&&&&&&&需要设置	
			//kzui_mc.jdzz_mc.width = kzui_mc.jdd_mc.width;
			kzui_mc.totalBar.alpha = 0;			//有遮罩的就不需要  这个是用于 长度
			
			bufferInit();
			stage_mc.mask = stagemask_mc;		//遮罩
			stage_mc.x = -5;
			stage_mc.y = -20;
			//stage_mc.addChild(mc);
			//mc.x = -5;
			//mc.y = -20;
			eventListener();
			setInteractEnabled(false);
			
			
			//kzui_mc.exit_btn.mouseEnabled = false;
			//kzui_mc.exit_btn.alpha = 0.5;
			//kzui_mc.exit_btn.addEventListener(MouseEvent.CLICK, btn_exit_ClickHandler);	//退出按钮
			//kzui_mc.help_btn.addEventListener(MouseEvent.CLICK, btn_help_ClickHandler);	//帮助按钮
			
			//rectRange_slider = new Rectangle(401.45, 478, kzui_mc.jdd_mc.width-kzui_mc.slider.width, 0);			//给一个不动对象的位置
			//slider.x = rectRange_slider.x;	
			//slider.y = rectRange_slider.y;
			
			
			//设置目录显示层级
			//setChildIndex(mulu_mc, getChildIndex(stage_mc));	
			
			//用于显示设备字体
			//mulu_mc.cacheAsBitmap = true;			
			
			//*********************test   加载的swf****************************************
			//stage.addEventListener(MouseEvent.CLICK,stage_forUIName_ClickHandler);
			mc_table.mouseChildren = false;
			mc_table.mouseEnabled = false;
			
		}
		
		//切换swf时的处理函数
		private function changeSWF_Handler():void
		{
			_isChangeSWF = true;
			specialProcess_changeSWF();
			if (mc_swf != null)
			{
				mc_swf.stop();
				if(mc_swf._mc!=null)
					mc_swf._mc.stop();	
			}
			if (loader != null)
			{
				if (stage_mc != null && stage_mc.contains(loader))
				{
					stage_mc.removeChild(loader);	
				}
				loader.unload();
				loader = null;
			}
			/*if (loader != null)
			{
				if (mc != null && mc.contains(loader))
				{
					mc.removeChild(loader);	
				}
				loader.unload();
				loader = null;
			}*/
			setInteractEnabled(false);
			//kzui_mc.mulu_btn.mouseEnabled = false;
			//kzui_mc.mulu_btn.alpha = 0.5;
			swf_totalFrames = 0;
			mc_swf = null;
			loading_mc.visible = false;
		}

		//帧的侦听事件
		private function onFrameHandler(evt:Event) 
		{	
			var time:Number;	//swf的时间显示---------->>倒计时
			if (mc_swf != null && mc_swf.currentFrame <= swf_totalFrames)
			{
				//zimuVisInit();			//--->>由于部分swf的第一帧没有字幕
				
				kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.width * mc_swf.currentFrame / swf_totalFrames + kzui_mc.jdd_mc.x - kzui_mc.jdzz_mc.width;
				time = int((swf_totalFrames - mc_swf.currentFrame) / 30);	//stage.frameRate
				/*
				 *视频滑块
				if (!isDown_slider)
				{
					//kzui_mc.jdzz_mc.width=kzui_mc.jdd_mc.width*mc_swf.currentFrame/swf_totalFrames;
					time=(swf_totalFrames-mc_swf.currentFrame)/stage.frameRate;
					slider.x=kzui_mc.jdd_mc.x+kzui_mc.jdzz_mc.width-slider.width/2;
				}
				else
				{
					kzui_mc.jdzz_mc.width=slider.x-kzui_mc.jdd_mc.x;
					time=Number((kzui_mc.jdd_mc.width+kzui_mc.jdd_mc.x-slider.x)/kzui_mc.jdd_mc.width*swf_totalFrames/stage.frameRate);
					mc_swf.gotoAndStop(getCurrentFrame());//视频跟随滑块拖动的跟动效果
				}
				*/
				//swf的时间显示
				kzui_mc.time_txt.text = String(100 + int(time / 60)).substr(1, 2) + ":" + String(100 + int(time % 60)).substr(1, 2);
				
				//播放结束
				if (mc_swf.currentFrame == swf_totalFrames && swf_totalFrames!=0)
				{
					mc_swf.stop();
					if(mc_swf._mc!=null)
						mc_swf._mc.stop();	
					if (getReadSWFIndex(arr_list[index_swf]) == -1)
					{
						addToReaded(arr_list[index_swf]);
						setMenuStatus(arr_readed);
					}
					
					kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.x;
					
				}
				
			}
			//trace("kzui_mc.jdzz_mc.x",kzui_mc.jdzz_mc.x);
			specialProcess_framehandler();
			
			//目录滚动条处理
			if(isDown_hk)
			{
				changexy(mulu_mc.gdt.hk.y-hky_tmp)
				hky_tmp = mulu_mc.gdt.hk.y;			// 记住前一帧的滑块的位置
			}
			
			//帧测试
			//frameTest.txt_frame.text = "当前动画帧数：	"+mc_swf.currentFrame.toString();		
		}
		
		//-----------------------------------片头处理---------------------------------------------------
		//加载片头
		private function loadIndex():void
		{
			loader_index = new Loader();
			loader_index.load(new URLRequest("swf/index.swf"));
			loader_index.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress_Handler);
			loader_index.contentLoaderInfo.addEventListener(Event.COMPLETE, indexLoadComplete);
			loader_index.contentLoaderInfo.addEventListener(Event.INIT, loadInit_Handler);
	
			loader_index.addEventListener(MouseEvent.CLICK, indexClickHandler);		//为swf通信提供通道***********
			
			trace("片头url:		","swf/index.swf");
		}		
		
		//片头加载完成的处理函数
		private function indexLoadComplete(evt:Event):void
		{
			addChild(loader_index);
			loading_mc.visible = false;
			var mc_tmp:MovieClip = evt.target.content as MovieClip;
			//var mc_tmp:MovieClip = loader_index.content as MovieClip;
			if (mc_tmp != null)
			{
				trace("片头加载完成!!!");
				mc_tmp.gotoAndPlay(1);
			}
			
		}
		
		
		//片头的交互事件
		private function indexClickHandler(evt:MouseEvent):void
		{
			
			trace("indexClickHandler:	", evt.target.name);
			if(evt.target.name=="startbtn")			//if(loader_index["content"].isEnter)
			{
				loader_index.removeEventListener(MouseEvent.CLICK, indexClickHandler);	
				
				var mc_tmp:MovieClip = loader_index.content as MovieClip;
				mc_tmp.stop();
				SoundMixer.stopAll();			//禁掉片头的声音
				removeChild(loader_index);
				loader_index.unload();
				loader_index.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress_Handler);
				loader_index.contentLoaderInfo.removeEventListener(Event.COMPLETE, indexLoadComplete);
				loader_index.contentLoaderInfo.removeEventListener(Event.INIT, loadInit_Handler);
				loader_index = null;

				bufferInit();					
				
				//enter frame3
				gotoAndStop(3);
				addEventListener(Event.ENTER_FRAME, onFrame3);
			}
		}
		
		//--------------------读取xml播放列表-----------------------------------------------------
		//从xml文件中读取视频列表
		private function readXML():void 
		{
			xml = new XML();  
			var urlStr:String = "xml/swf" + nc + ".xml";
        	var req:URLRequest = new URLRequest(urlStr); 
			XMLloader = new URLLoader();
			XMLloader.load(req);
			//XMLloader.addEventListener(ProgressEvent.PROGRESS, loadProgress_Handler);
        	XMLloader.addEventListener(Event.COMPLETE, xml_loadCompleted); 
			XMLloader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			trace("XML：	",urlStr);
		}  
		
		private function xml_loadCompleted(evt:Event):void 
		{ 
			if(XMLloader==null)
			{
        		trace("xml	数据装载失败."); 
				return;
			}
			trace("xml	数据装载完成.");
			xml = XML(XMLloader.data);				//强制类型转换
			
			//XMLloader.removeEventListener(ProgressEvent.PROGRESS, loadProgress_Handler);
        	XMLloader.removeEventListener(Event.COMPLETE, xml_loadCompleted); 
			XMLloader.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			XMLloader = null;
			
			trace("xml type:	", xml.@type);
			download();
		}
		
		private function onFrame3(evt:Event):void
		{
			//trace("test Frame3:	",mulu_mc, "========");
			if (mulu_mc != null)
			{
				trace("进入	Frame3	！！！");
				removeEventListener(Event.ENTER_FRAME, onFrame3);
				if (!_isMUlU)
				{
					xmlToArr1();
				}
				else
				{
					muluInit();
					xmlToArr();
					createMenuC();
					pushIntoArrRead(arr_listIndex);
					initLocationStr();
					
					//&&&&&&&&&&&&&&&&&原来放在playStart2中
					kzui_mc.mulu_btn.mouseEnabled = true;		
					kzui_mc.mulu_btn.alpha = 1.0;
					mulutiao_btn.mouseEnabled = true;
				}
				if (index_swf == -1)
				{
					index_swf = 0;
				}
				playStart();
				trace("开始播放课程。。。");
			}
		}
		
		//处理xml并存放参数进相应的数组
		private function xmlToArr1():void
		{
			var nodes:XMLList = xml.child("level1");
      		var len:Number = nodes.length();
			trace("xml length:	"+len.toString());
			for(var i:int=0;i<len;i++)
			{
				if(xml.child(i).@swf!="")
					addToSWFList(int(xml.child(i).@num), xml.child(i).@swf);
			}
		}
		
		private function getDelimiter(str:String):String
		{
			if (str == "")
				return "";
			else
				return ",";
			return "";
		}
		
		//处理xml并存放参数进相应的数组
		private function xmlToArr():void
		{
			
			//var nodes:XMLList = xml.child("level");
      		//var len1:Number = nodes.length();
			var len1:Number = xml.children().length();
			trace("xml length:	" + len1.toString());
			for(var i:int=0;i<len1;i++)
			{
				var xmlTmp1:XMLList = xml.child(i);
				var len2:int=int(xml.child(i).children().length());//var len2:int=int(xml.child(i).@count);////var len2:int = int(xml.child(i).child("level").length());
				var menuc_name:String = "";
				var menuc_child:String = "";
				if (xml.child(i).@swf != "")				
				{
					menuc_name = xml.child(i).@swf;
					menuc_child = addToSWFList(int(xml.child(i).@num), xml.child(i).@swf);
				}
				else
				{
					menuc_name = "menuc" + i;
					for(var j:int=0;j<len2;j++)
					{
						var menuj_name:String = "";
						var menuj_child:String = "";
						var xmlTmp2:XMLList = xml.child(i).child(j);
						var len3:int = int(xmlTmp2.children().length());
						
						if(xmlTmp2.@swf!="")
						{
							menuj_name =xmlTmp2.@swf;
							menuj_child = addToSWFList(int(xmlTmp2.@num), xmlTmp2.@swf);				
						}
						else
						{
							menuj_name = "menuj" + i + "_" + arr_menuj.length;
							for(var k:int=0;k<len3;k++)
							{	
								var menut_name:String = "";
								var menut_child:String = "";					
								var xmlTmp3:XMLList = xml.child(i).child(j).child(k);
								if (xmlTmp3.@swf != "")
								{
									menut_name = xmlTmp3.@swf;
									menut_child = addToSWFList(int(xmlTmp3.@num), xmlTmp3.@swf);
								}
								else
								{
									trace("存在四级目录！！！！！！！！！！！！！！");
								}
								arr_menut.push( { indexc:i, indexj:j , indext:k, label:xmlTmp3.@label, swf:xmlTmp3.@swf, count:xmlTmp3.children().length(), num:int(xmlTmp3.@num), menuName:menut_name, menuChild:menut_child } );
								menuj_child += getDelimiter(menuj_child) + menut_child;
							}
						}
						arr_menuj.push( { indexc:i, indexj:j, label:xmlTmp2.@label, swf:xmlTmp2.@swf, count:len3, num:int(xmlTmp2.@num), showchild:false, menuName:menuj_name, menuChild:menuj_child } );
						menuc_child += getDelimiter(menuc_child) + menuj_child;
					}
				}
				arr_menuc.push( { indexc:i, label:xml.child(i).@label, swf:xml.child(i).@swf, num:xml.child(i).@num, count:len2, showchild:false, menuName:menuc_name, menuChild:menuc_child } );
			}
			trace("------播放列表-------");
			for(var n:int=0;n<arr_list.length;n++)
			{
				trace("**"+arr_list[n]);
			}
			trace("----------------------");
		}

		//把swf添加到播放序列数组
		private function addToSWFList(num:int,str_swf:String):String
		{
			if (num == 0 )	return "";
			var childNameStr:String = "";
			if (num == 1)
			{
				childNameStr += str_swf;
				arr_list.push(str_swf);
			}
			else
			{
				for(var m:int=1;m<=num;m++)
				{
					if (m < 10)
					{
						arr_list.push(str_swf.substring(0,str_swf.length-1)+m);
					}
					else
					{
						arr_list.push(str_swf.substring(0,str_swf.length-2)+m);
					}
					childNameStr += getDelimiter(childNameStr) + arr_list[arr_list.length - 1];
				}
			}
			return childNameStr;
		}
		
		//----------------------------目录处理-----------------------------------------------
		//目录加载初始化
		private function muluInit():void
		{
			//mulu_mc.mask=mulumask_mc;						//目录外部遮罩
			mulu_mc.thismulu_mc.mask = mulu_mc.mask_mc;		//目录内部遮罩
			//mulu_mc.gdt.hk.x = mulu_mc.gdt._di.x;
			//mulu_mc.gdt.hk.y=mulu_mc.gdt._di.y;
			mulu_mc.gdt.hk.x = 0;
			mulu_mc.gdt.hk.y = 0.5;
			hkRect = new Rectangle(0, 0.5, 0, mulu_mc.gdt._di.height - mulu_mc.gdt.hk.height + 10);	//&&&&&&&&&&&需要设置
			//hkRect_y = hkRect.y;
			hkRect_y = 0;
			
			mulu_mc.gdt.hk.addEventListener(MouseEvent.MOUSE_DOWN,hk_mouseDownHandler);
			mulu_mc.gdt.hk.addEventListener(MouseEvent.MOUSE_UP, hk_mouseUpHandler);	
			mulu_mc.gdt.hk.buttonMode = true;
			
			//目录条目的高度自动获取
			var menu_tmp1:MenuC = new MenuC();
			menuc_height = menu_tmp1.height;
			menu_tmp1 = null;
			
			var menu_tmp2:MenuJ = new MenuJ();
			menuj_height = menu_tmp2.height;
			menu_tmp2 = null;
			
			var menu_tmp3:MenuT = new MenuT();
			menut_height = menu_tmp3.height;
			menu_tmp3 = null;
			
			//special
			mulu_mc.mulutiao_btn.addEventListener(MouseEvent.CLICK, btn_mulu_ClickHandler);
		}
		
		//Menu高亮显示的初始化
		private function initMenuLighted():void
		{
			for(var i:int=0;i<mulu_mc.thismulu_mc.numChildren;i++)
			{
				var menu0:MovieClip=mulu_mc.thismulu_mc.getChildAt(i) as MovieClip;
				menu0.gotoAndStop(1);
				if (getQualifiedClassName(menu0) == "MenuT")		//三级目录的颜色不一样
				{
					menu0.contentLabel.textColor = 0x5A5A5A;
				}
				else
				{
					menu0.contentLabel.textColor = 0x000000;
				}
			}
		}
		
		private function getMenuObj(index:int):MovieClip
		{
			var menuName:String = arr_list[index];
			menuName = menuName.substring(0, menuName.length - 2) + "01";	//"01"
			var obj:MovieClip = mulu_mc.thismulu_mc.getChildByName(menuName) as MovieClip;
			
			return obj;
		}
		
		//高亮显示当前播放目录条目-----------》播放展开并高亮显示
		private function highLighted(index:int,isCreate:Boolean):void
		{
			initMenuLighted();
			var menuName:String = arr_list[index];
			menuName = menuName.substring(0, menuName.length - 2) + "01";	//"01"
			var obj:MovieClip = mulu_mc.thismulu_mc.getChildByName(menuName) as MovieClip;
			if (obj == null)
			{
				if (isCreate)
				{
					createMenu(menuName);					//create menu MovieClip
					obj = mulu_mc.thismulu_mc.getChildByName(menuName) as MovieClip;
					if (obj != null)
					{
						obj.contentLabel.textColor = 0xFFFFFF;
						obj.gotoAndStop(2);
					}
				}
			}
			else
			{
				obj.contentLabel.textColor = 0xFFFFFF;
				obj.gotoAndStop(3);
			}
		}
		
		//播放条目的鼠标事件
		private function menu_mouseoverHandler(evt:MouseEvent):void
		{
			var menu:MovieClip = evt.currentTarget as MovieClip;
			menu.gotoAndStop(2);
		}
		
		private function menu_mouseoutHandler(evt:MouseEvent):void
		{
			var menu:MovieClip = evt.currentTarget as MovieClip;
			menu.gotoAndStop(1);	
			listRefresh(arr_readed);
		}
		
		//获取当前播放条目的Level层级
		private function getMenuLevel(str:String):String
		{
			var str_level:String = "";
			var index_tmp:int = -1;
			for (var k:int = 0; k < arr_menut.length; k++)		
			{
				if (str == arr_menut[k].swf)
				{
					index_tmp = k;
					str_level += LEVEL3 + arr_menut[k].indexc +"_" + arr_menut[k].indexj + "_" + arr_menut[k].indext;
					return str_level;
				}
			}
			for (var j:int = 0; j < arr_menuj.length; j++)		
			{
				if (str == arr_menuj[j].swf)
				{
					index_tmp = j;
					str_level += LEVEL2 + arr_menuj[j].indexc +"_" + arr_menuj[j].indexj;
					return str_level;
				}
			}
			for (var i:int = 0; i < arr_menuc.length; i++)		//还是在xml中搜索
			{
				if (str == arr_menuc[i].swf)
				{
					index_tmp = i;
					str_level += LEVEL1 + arr_menuc[i].indexc;
					return str_level;
				}
			}	
			return str_level;
		}
		
		//新建目录----》为播放展开
		private function createMenu(menuName:String):void
		{
			var arr_tmp:Array;
			var str_tmp:String = getMenuLevel(menuName);
			if (str_tmp == "")
				trace("找不到...menu...");
			else
			{
				if (str_tmp.substr(0, 6) == LEVEL1)
				{
					trace("!!!	一级目录不存在");		//--------》》这种情况不存在，一开始就创建所有的一级目录
				}
				else
				{
					if(str_tmp.substr(0,6) ==LEVEL2)
					{
						trace("!!!	二级目录不存在");
						arr_tmp = str_tmp.substring(6, str_tmp.length - 1).split("_");
						expandMenuC("menuc" + arr_tmp[0]);	
					}
					else
					{
						trace("!!!	三级目录不存在");
						arr_tmp = str_tmp.substring(6, str_tmp.length - 1).split("_");
						var realJindex:int = getRealJindex(arr_tmp[0], arr_tmp[1]);
						var obj:MovieClip = mulu_mc.thismulu_mc.getChildByName("menuj" + arr_tmp[0] + "_" + realJindex) as MovieClip;
						
						trace("三级的父级名称：		"+"menuj" + arr_tmp[0] + "_" + realJindex);
						if (obj == null)
						{
							expandMenuC("menuc" + arr_tmp[0]);
						}
						expandMenuJ("menuj" + arr_tmp[0]+"_"+realJindex);
					}
				}
			} 
		}
		
		//创建一级菜单
		private function createMenuC():void
		{
			for (var i:int = 0; i < arr_menuc.length; i++)
			{
				var menuc:MenuC=new MenuC();
				mulu_mc.thismulu_mc.addChild(menuc);
				menuc.x=menu_x;
				menuc.y=menu_y;
				menuc.gotoAndStop(1);
				menuc.lock_mc.gotoAndStop(1);								
				menuc.contentLabel.text = arr_menuc[i].label;
			
				menuc.buttonMode = true;
				menuc.mouseChildren = false;
				menuc.addEventListener(MouseEvent.CLICK, menuc_click);
				menuc.addEventListener(MouseEvent.MOUSE_OVER, menu_mouseoverHandler);
				menuc.addEventListener(MouseEvent.MOUSE_OUT,menu_mouseoutHandler);
				if (arr_menuc[i].swf == "")				
				{
					menuc.name = "menuc" + i;
				}
				else
				{
					menuc.name = arr_menuc[i].swf;
				}
				menu_y+=menuc_height;
			}
			setHkVis();
		}
		
		//创建二级菜单
		private function createMenuJ(indexc:int,y_target:Number):void
		{
			var childName:String = "";
			var countTmp:int = int(arr_menuc[indexc].count);
			for (var j:int = 0; j < arr_menuj.length; j++)		
			{
				if (countTmp == 0)
					break;
				if (indexc.toString() == arr_menuj[j].indexc)
				{
					//创建
					
					var str_menuj:String = arr_menuj[j].label;
					
					var menuj:MenuJ=new MenuJ();
					mulu_mc.thismulu_mc.addChild(menuj);
					menuj.x=menu_x;
					menuj.y = y_target+ menuj_height * (int(arr_menuc[indexc].count)-countTmp);
					menuj.gotoAndStop(1);
					menuj.lock_mc.gotoAndStop(1);
					menuj.contentLabel.text = str_menuj;
					
					menuj.mouseChildren = false;
					menuj.buttonMode = true;
					menuj.addEventListener(MouseEvent.CLICK, menuj_click);
					menuj.addEventListener(MouseEvent.MOUSE_OVER, menu_mouseoverHandler);
					menuj.addEventListener(MouseEvent.MOUSE_OUT,menu_mouseoutHandler);
					if (arr_menuj[j].swf == "")
					{
						trace( "menuj" + indexc + "_" + j);
						menuj.name = "menuj" + indexc + "_" + j;
					}
					else
						menuj.name = arr_menuj[j].swf;
					childName += menuj.name + ",";
					
					trace("Create二级目录****" + menuj.name);
					countTmp--;
				}
				
			}
			arr_childName[indexc] = childName.substr(0, childName.length - 1);
		}
		
		//创建三级菜单
		
		//index--->>indexj
		private function createMenuT(index:int,y_target:Number):void
		{
			var childName:String = "";
			var countTmp:int = int(arr_menuj[index].count);
			var indexc:int = int(arr_menuj[index].indexc);
			var indexj:int = int(arr_menuj[index].indexj);
			for (var j:int = 0; j < arr_menut.length; j++)		
			{
				if (countTmp == 0)
					break;
				if (indexc.toString() == arr_menut[j].indexc && indexj.toString() == arr_menut[j].indexj)
				{
					
					var str_menut:String = arr_menut[j].label;
					var menut:MenuT=new MenuT();
					mulu_mc.thismulu_mc.addChild(menut);
					menut.y = y_target+ menut_height * (int(arr_menuj[index].count)-countTmp);
					menut.x=menu_x;
					menut.gotoAndStop(1);
					menut.lock_mc.gotoAndStop(1);
					menut.contentLabel.text = str_menut;
					menut.addEventListener(MouseEvent.MOUSE_OVER, menu_mouseoverHandler);
					menut.addEventListener(MouseEvent.MOUSE_OUT,menu_mouseoutHandler);
					menut.addEventListener(MouseEvent.CLICK,menut_click);
					if (arr_menut[j].swf=="")
						menut.name = "menut" + indexc + "_" + indexj + "_" + j;
					else
						menut.name = arr_menut[j].swf;
					childName += menut.name + ",";
					
					trace("Create三级目录****	" + menut.name);
					countTmp--;
				}
				
			}
			arr_childName2[index] = childName.substr(0, childName.length - 1);
		}
		
		//删除目录---------》为目录收起
		private function removeChildMenu(index:int,levelMode:String):void
		{
			var childName:String = "";
			if (levelMode == LEVEL1)
			{
				childName = arr_childName[index];
			}
			else
				if (levelMode == LEVEL2 || levelMode == LEVEL3 )
				{
					childName = arr_childName2[index];
				}
			if (childName == null) return;
			var arr_tmp:Array = childName.split(",");
			trace("------------删除列表-----------"+levelMode);
			for (var i:int = 0; i < arr_tmp.length; i++)
			{
				var menu:MovieClip = mulu_mc.thismulu_mc.getChildByName(arr_tmp[i]) as MovieClip;
				if (menu != null)
				{
					if (levelMode == LEVEL3)
					{
						_count_child++;	
					}
					mulu_mc.thismulu_mc.removeChild(menu);
					trace(arr_tmp[i]);
				}
				else
					trace("不存在的删除条目：	"+arr_tmp[i]);
			}
			trace("-------------------------------");
		}
		
		//删除内部的三级目录-------->>removeChildMenu2原函数
		private function removeChildMenu3(indexc:int):void
		{
			for(var j:int=0;j<mulu_mc.thismulu_mc.numChildren;j++)			//*******getQualifiedClassName*********获取实例对象这个函数有重复
			{					
				if (getQualifiedClassName(mulu_mc.thismulu_mc.getChildAt(j)) == "MenuJ")
				{
					var menuj:MenuJ = mulu_mc.thismulu_mc.getChildAt(j) as MenuJ;
					if (menuj.name.substr(0, 5 + indexc.toString().length) == "menuj" + indexc)
					{	
						var str_tmp:String = menuj.name.substring(5, menuj.name.length);
						var arr_tmp:Array = str_tmp.split("_");
						var index:int = int(arr_tmp[1]);
						if (arr_menuj[index].showchild && arr_childName2[index] != undefined)
						{
							removeChildMenu(index, LEVEL3);							//用LEVEL3来标识关闭三级菜单时，
							arr_menuj[index].showchild = !(arr_menuj[index].showchild);
						}
					}
				}
			}
		}
		
		//删除内部的三级目录
		private function removeChildMenu2(indexc:int):void
		{
			if (arr_childName[indexc] != "")
			{
				
				var arr_tmp2:Array = arr_childName[indexc].split(",");
				for (var i:int = 0; i < arr_tmp2.length; i++)
				{
					if (arr_tmp2[i].substr(0, 5) == "menuj")
					{
						trace("***",arr_tmp2[i],"****")
						var str_tmp:String = arr_tmp2[i];
						var arr_tmp:Array = str_tmp.split("_");
						var index:int = int(arr_tmp[1]);
						if (arr_menuj[index].showchild && arr_childName2[index] != undefined)
						{
							removeChildMenu(index, LEVEL3);							//用LEVEL3来标识关闭三级菜单时，
							arr_menuj[index].showchild = !(arr_menuj[index].showchild);
						}
					}
				}
			}
		}
		
		//内部目录条的移动--------》为目录的增减
		private function menuMove(yy:Number,y_move:Number):void
		{
			if (y_move == 0)
			{
				return ;
			}
			for(var j:int=0;j<mulu_mc.thismulu_mc.numChildren;j++)			
			{
				var obj:Object=mulu_mc.thismulu_mc.getChildAt(j) as Object;
				if(obj.y>yy)
				{
					obj.y+=y_move;
				}
			}
		}
		
		
		//目录展开	---------->>默认是
		private function expandMenuC(menuName:String):void
		{
			var menuc:MenuC =mulu_mc.thismulu_mc.getChildByName(menuName)  as MenuC;
			
			if (menuName.substr(0, 5) == "menuc")
			{
				var indexc:int = int(menuName.substring(5, menuName.length));
				var countTmp:int = int(arr_menuc[indexc].count);
				
				trace("一级目录：	"+menuName+"------index:	"+indexc.toString());
				menuMove(menuc.y, menuj_height * countTmp);
				createMenuJ(indexc, menuc.y + menuc_height);
				arr_menuc[indexc].showchild = true;
			}
			setHkVis();
			
		}
		
		private function expandMenuJ(menuName:String):void
		{
			var menuj:MenuJ =mulu_mc.thismulu_mc.getChildByName(menuName)  as MenuJ;
			if (menuName.substr(0, 5) == "menuj")
			{
				var str_tmp:String = menuName.substring(5, menuName.length);
				var arr_tmp:Array = str_tmp.split("_");
				var index:int = int(arr_tmp[1]);
				var countTmp:int = int(arr_menuj[index].count);
				menuMove(menuj.y, menut_height * countTmp);
				createMenuT(index, menuj.y + menuj_height);
				arr_menuj[index].showchild = true;
			}
			setHkVis();
		}
		
		//一级目录的单击事件
		private function menuc_click(evt:MouseEvent):void
		{
			var menuName:String = evt.currentTarget.name.toString();
			menucClick(menuName);
			listRefresh(arr_readed);
			setHkVis();
		}
		
		private function menucClick(menuName:String):void
		{
			var menuc:MenuC =mulu_mc.thismulu_mc.getChildByName(menuName)  as MenuC;
			if (menuName.substr(0, 5) == "menuc")
			{
				var indexc:int = int(menuName.substring(5, menuName.length));
				var countTmp:int = int(arr_menuc[indexc].count);
			
				trace("menucClick一级目录名:	"+menuName);
				
				if (arr_menuc[indexc].showchild)	
				{
					removeChildMenu2(indexc);
					removeChildMenu(indexc, LEVEL1);
					var y_move:Number = _count_child * menut_height + menuj_height * countTmp;
					menuMove(menuc.y, y_move * ( -1));
					_count_child = 0;
				}
				else
				{
					menuMove(menuc.y, menuj_height * countTmp);
					createMenuJ(indexc, menuc.y + menuc_height);
				}
				arr_menuc[indexc].showchild = !(arr_menuc[indexc].showchild);
			}
			else
			{
				if (!_isChangeSWF)
				{
					menuc.gotoAndStop(3);
					menuc.contentLabel.textColor = 0xFFFFFF;
					playForClick(menuName);
				}
				
			}
			
			
		}
		
		//设置二级目录的单击处理函数
		private function menuj_click(evt:MouseEvent):void
		{
			var menuName:String = evt.currentTarget.name.toString();
			menujClick(menuName);
			listRefresh(arr_readed);
			setHkVis();
		}
		
		private function menujClick(menuName:String):void
		{
			var menuj:MenuJ =mulu_mc.thismulu_mc.getChildByName(menuName)  as MenuJ;
			if (menuName.substr(0, 5) == "menuj")
			{
				var str_tmp:String = menuName.substring(5, menuName.length);
				var arr_tmp:Array = str_tmp.split("_");
				var index:int = int(arr_tmp[1]);
				var countTmp:int = int(arr_menuj[index].count);
				
				if (arr_menuj[index].showchild)	
				{
					removeChildMenu(index,LEVEL2);
					menuMove(menuj.y, menut_height * countTmp * ( -1));	
				}
				else
				{
					menuMove(menuj.y, menut_height * countTmp);
					createMenuT(index, menuj.y + menuj_height);
				}
				arr_menuj[index].showchild = !(arr_menuj[index].showchild);
			}
			else
			{
				if (!_isChangeSWF)
				{
					menuj.gotoAndStop(3);
					menuj.contentLabel.textColor = 0xFFFFFF;
					playForClick(menuName);
				}
				
			}
			
		}
		
		//设置三级目录的单击处理函数
		private function menut_click(evt:MouseEvent):void
		{
			var menut:MenuT=evt.currentTarget as MenuT;
			var menuName:String = evt.currentTarget.name.toString();
			if (menuName.substr(0, 5) == "menut")
			{
				trace("存在四级目录！！！！！！！！！！！！！！");
			}
			else 
			{
				if (!_isChangeSWF)
				{
					menut.gotoAndStop(3);
					menut.contentLabel.textColor = 0xFFFFFF;
					playForClick(menut.name);
				}
				
			}
			//---------->>if level4 exits
			listRefresh(arr_readed);
		}
		
		
		//菜单的单击播放
		private function playForClick(swfName:String):void
		{
			//var index_tmp:int = arr_list.indexOf(swfName);
			var index_tmp:int = getPlayIndex(swfName);
			if (index_tmp != -1)
			{
				index_swf = index_tmp;
				//mouseWheelRemoveProcess();
				changeSWF_Handler();
				playStart();	
			}
			else
			{
				trace("播放列表中未找到。。。。"+swfName);
			}
		}
		
		//获取播放的index_swf
		private function getPlayIndex(swfName:String):int
		{
			for(var i:int=0;i<arr_list.length;i++)
			{
				if(arr_list[i]==swfName)
				{
					return i;
				}
			}
			return -1;
		}
		
		//获取二级目录的索引值
		private function getRealJindex(indexc:String, indexj:String):int
		{
			for (var i:int = 0; i < arr_menuj.length; i++ )
			{
				if (arr_menuj[i].indexc.toString() == indexc && arr_menuj[i].indexj.toString() == indexj)
					return i;
			}
			trace("**************找不到indexj*************");
			return 0;		//or return -1;
		}

		//目录列表状态刷新
		private function listRefresh(arr_tmp:Array):void
		{
			highLighted(index_swf,false);
			setMenuStatus(arr_tmp);
			
		}
		
		//目录完成状态设置------------->>包含多个swf的目录项 需要另外设置
		private function setMenuStatus(arr_tmp:Array):void
		{
			if (arr_tmp.length == 0) return;
			arr_tmp.sort();
			
			for (var t:int = 0; t < arr_menut.length; t++)
			{
				if (arr_tmp.toString().indexOf(arr_menut[t].menuChild) != -1) 
				{
					var menut0:MovieClip = mulu_mc.thismulu_mc.getChildByName(arr_menut[t].menuName) as MovieClip;
					if(menut0!=null)
						menut0.lock_mc.gotoAndStop(2);
				}
			}
			
			for (var j:int = 0; j < arr_menuj.length; j++)
			{
				if (arr_tmp.toString().indexOf(arr_menuj[j].menuChild) != -1) 
				{
					var menuj0:MovieClip = mulu_mc.thismulu_mc.getChildByName(arr_menuj[j].menuName) as MovieClip;
					if(menuj0!=null)
						menuj0.lock_mc.gotoAndStop(2);
				}
			}
			
			for (var i:int = 0; i < arr_menuc.length; i++)
			{
				if (arr_tmp.toString().indexOf(arr_menuc[i].menuChild) != -1) 
				{
					var menuc0:MovieClip = mulu_mc.thismulu_mc.getChildByName(arr_menuc[i].menuName) as MovieClip;
					if(menuc0!=null)
						menuc0.lock_mc.gotoAndStop(2);
				}
			}
		}
		//目录完成状态设置------------->>包含多个swf的目录项 需要另外设置
		private function setMenuStatus2(arr_tmp:Array):void
		{
			if (arr_tmp.length == 0) return;
			arr_tmp.sort();
			//menuc
			if (arr_tmp.toString().indexOf("c00s01p01,c00s01p02") != -1) 
			{
				var menuc0:MovieClip = mulu_mc.thismulu_mc.getChildByName("c00s01p01") as MovieClip;
				if(menuc0!=null)
					menuc0.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c01s01p01,c01s01p02,c01s02p01,c01s02p02,c01s02p03,c01s03p01,c01s03p02,c01s03p03,c01s03p04,c01s04p01,c01s04p02,c01s04p03,c01s05p01") != -1) 
			{
				var menuc1:MovieClip = mulu_mc.thismulu_mc.getChildByName("menuc1") as MovieClip;
				if(menuc1!=null)
					menuc1.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c02s01p01,c02s02p01,c02s02p02,c02s03p01,c02s03p02,c02s03p03,c02s04p01,c02s05p01,c02s05p02,c02s06p01") != -1) 
			{
				var menuc2:MovieClip = mulu_mc.thismulu_mc.getChildByName("menuc2") as MovieClip;
				if(menuc2!=null)
					menuc2.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c03s01p01,c03s02p01,c03s03t01p01,c03s03t01p02,c03s03t02p01,c03s03t03p01,c03s03t04p01,c03s04p01") != -1) 
			{
				var menuc3:MovieClip = mulu_mc.thismulu_mc.getChildByName("menuc3") as MovieClip;
				if(menuc3!=null)
					menuc3.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c04s01p01,c04s01p02,c04s01p03,c04s01p04,c04s01p05,c04s02p01,c04s02p02,c04s03p01,c04s03p02") != -1) 
			{
				var menuc4:MovieClip = mulu_mc.thismulu_mc.getChildByName("menuc4") as MovieClip;
				if(menuc4!=null)
					menuc4.lock_mc.gotoAndStop(2);
			}
			//menuj
			if (arr_tmp.toString().indexOf("c01s01p01,c01s01p02") != -1) 
			{
				var menuj0:MovieClip = mulu_mc.thismulu_mc.getChildByName("c01s01p01") as MovieClip;
				if(menuj0!=null)
					menuj0.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c01s02p01,c01s02p02,c01s02p03") != -1) 
			{
				var menuj1:MovieClip = mulu_mc.thismulu_mc.getChildByName("c01s02p01") as MovieClip;
				if(menuj1!=null)
					menuj1.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c01s03p01,c01s03p02,c01s03p03,c01s03p04") != -1) 
			{
				var menuj2:MovieClip = mulu_mc.thismulu_mc.getChildByName("c01s03p01") as MovieClip;
				if(menuj2!=null)
					menuj2.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c01s04p01,c01s04p02,c01s04p03") != -1) 
			{
				var menuj3:MovieClip = mulu_mc.thismulu_mc.getChildByName("c01s04p01") as MovieClip;
				if(menuj3!=null)
					menuj3.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c02s02p01,c02s02p02") != -1) 
			{
				var menuj4:MovieClip = mulu_mc.thismulu_mc.getChildByName("c02s02p01") as MovieClip;
				if(menuj4!=null)
					menuj4.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c02s03p01,c02s03p02,c02s03p03") != -1) 
			{
				var menuj5:MovieClip = mulu_mc.thismulu_mc.getChildByName("c02s03p01") as MovieClip;
				if(menuj5!=null)
					menuj5.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c02s05p01,c02s05p02") != -1) 
			{
				var menuj6:MovieClip = mulu_mc.thismulu_mc.getChildByName("c02s05p01") as MovieClip;
				if(menuj6!=null)
					menuj6.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c03s03t01p01,c03s03t01p02,c03s03t02p01,c03s03t03p01,c03s03t04p01") != -1) 
			{
				var menuj7:MovieClip = mulu_mc.thismulu_mc.getChildByName("menuj3_13") as MovieClip;
				if(menuj7!=null)
					menuj7.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c04s01p01,c04s01p02,c04s01p03,c04s01p04,c04s01p05") != -1) 
			{
				var menuj8:MovieClip = mulu_mc.thismulu_mc.getChildByName("c04s01p01") as MovieClip;
				if(menuj8!=null)
					menuj8.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c04s02p01,c04s02p02") != -1) 
			{
				var menuj9:MovieClip = mulu_mc.thismulu_mc.getChildByName("c04s02p01") as MovieClip;
				if(menuj9!=null)
					menuj9.lock_mc.gotoAndStop(2);
			}
			
			if (arr_tmp.toString().indexOf("c04s03p01,c04s03p02") != -1) 
			{
				var menuj10:MovieClip = mulu_mc.thismulu_mc.getChildByName("c04s03p01") as MovieClip;
				if(menuj10!=null)
					menuj10.lock_mc.gotoAndStop(2);
			}
			
			//menut
			if (arr_tmp.toString().indexOf("c03s03t01p01,c03s03t01p02") != -1) 
			{
				var menut0:MovieClip = mulu_mc.thismulu_mc.getChildByName("c03s03t01p01") as MovieClip;
				if(menut0!=null)
					menut0.lock_mc.gotoAndStop(2);
			}

			for (var i:int = 0; i < arr_tmp.length; i++)
			{
				var str_tmp:String = arr_tmp[i];
				if (str_tmp != null) 
				{
					var menu0:MovieClip = mulu_mc.thismulu_mc.getChildByName(str_tmp) as MovieClip;
					if (menu0 != null && getPlayIndex(str_tmp.substr(0,str_tmp.length-1)+"2")==-1)
						menu0.lock_mc.gotoAndStop(2);
				}
			}
		}
		
		//-------------------------目录滚动条---------------------------
		private function hk_mouseDownHandler(evt:MouseEvent):void 
		{
			mulu_mc.gdt.hk.startDrag(false,hkRect);
			isDown_hk=true;
			stage.addEventListener(MouseEvent.MOUSE_UP,hk_mouseUpHandler);
			mulu_mc.gdt.hk.buttonMode=true;
			
			hky=mulu_mc.gdt.hk.y;
			hky_tmp=hky;
		}
	
		private function hk_mouseUpHandler(evt:MouseEvent):void 
		{
			if(isDown_hk)
			{
				mulu_mc.gdt.hk.stopDrag();
				isDown_hk=false;
				stage.removeEventListener(MouseEvent.MOUSE_UP,hk_mouseUpHandler);
				mulu_mc.gdt.hk.buttonMode=false;
				changexy(mulu_mc.gdt.hk.y - hky_tmp);		//changexy(mulu_mc.gdt.hk.y-hky);
				
			}
			
		}
		
		//设置滚动条的可见性
		private function setHkVis():void
		{
			var menuCount:int = mulu_mc.thismulu_mc.numChildren;
			if (mulu_mc.thismulu_mc.height > mulu_mc.mask_mc.height)
			{
				mulu_mc.gdt._di.visible=true;
				mulu_mc.gdt.hk.visible=true;
				height_change = mulu_mc.thismulu_mc.height - mulu_mc.mask_mc.height;
				
				addEventListener(MouseEvent.MOUSE_WHEEL, mulu_WheelHandler);
			}	
			else
			{
				mulu_mc.gdt._di.visible=false;
				mulu_mc.gdt.hk.visible=false;
				mulu_mc.gdt.hk.y = hkRect.y;			//初始化
				mulu_mc.thismulu_mc.y = mulu_mc.mask_mc.y;		//滚动条消失时的菜单的位置处理函数
				if (hasEventListener(MouseEvent.MOUSE_WHEEL))
				{
					removeEventListener(MouseEvent.MOUSE_WHEEL, mulu_WheelHandler);
				}
				
			}
			changexy(0);			
		}
		
		private function mulu_WheelHandler(evt:MouseEvent):void
		{
			if (evt.delta < 0)
			{
				if (mulu_mc.gdt.hk.y >= (hkRect_y+hkRect.height))
				{
					MoveHK(0);
					changexy(0);
				}
				else
				{
					hky_tmp = mulu_mc.gdt.hk.y;	
					MoveHK(evt.delta);
					changexy(mulu_mc.gdt.hk.y-hky_tmp)
				}
			}
			else
			{
				if (mulu_mc.gdt.hk.y <= hkRect_y)
				{
					MoveHK(0);
					changexy(0);
				}
				else
				{
					hky_tmp = mulu_mc.gdt.hk.y;	
					MoveHK(evt.delta);
					changexy(mulu_mc.gdt.hk.y-hky_tmp)
				}
			}
			
		}
		
		private function MoveHK(yy:Number):void
		{
			if (yy == 0)
				return ;
			mulu_mc.gdt.hk.y += yy*(-1);
			if (mulu_mc.gdt.hk.y < hkRect_y)
			{
				mulu_mc.gdt.hk.y =  hkRect_y;
			}
			
			if (mulu_mc.gdt.hk.y > (hkRect_y+hkRect.height))
			{
				mulu_mc.gdt.hk.y = (hkRect_y + hkRect.height);
			}
			
		}
		
		//整个目录跟随滚动条的移动而移动
		private function changexy(yy:Number):void
		{
			if (yy != 0)
				mulu_mc.thismulu_mc.y += -yy /hkRect.height * height_change;
			if (mulu_mc.thismulu_mc.y > mulu_mc.mask_mc.y)
			{
				mulu_mc.gdt.hk.y = hkRect.y;
				mulu_mc.thismulu_mc.y = mulu_mc.mask_mc.y;
			}
			if (mulu_mc.thismulu_mc.height > mulu_mc.mask_mc.height && mulu_mc.thismulu_mc.y < (mulu_mc.mask_mc.y + mulu_mc.mask_mc.height - mulu_mc.thismulu_mc.height))
			{
				mulu_mc.thismulu_mc.y = mulu_mc.mask_mc.y + mulu_mc.mask_mc.height - mulu_mc.thismulu_mc.height;
				mulu_mc.gdt.hk.y = hkRect.height;
			}
			if (mulu_mc.gdt.hk.y == (hkRect_y + hkRect.height) && mulu_mc.thismulu_mc.height > mulu_mc.mask_mc.height)
			{
				mulu_mc.thismulu_mc.y = mulu_mc.mask_mc.y + mulu_mc.mask_mc.height - mulu_mc.thismulu_mc.height;
			}
			if (mulu_mc.gdt.hk.y == hkRect.y && mulu_mc.thismulu_mc.height > mulu_mc.mask_mc.height)
			{
				mulu_mc.gdt.hk.y = hkRect.y;
				mulu_mc.thismulu_mc.y = mulu_mc.mask_mc.y;
			}
			//trace(mulu_mc.gdt.hk.y,"******",hkRect_y + hkRect.height);
		}
		//---------------------------------------播放SWF---------------------------------------------

		//播放开始的初始化
		private function initForPlay():void
		{
			kzui_mc.time_txt.text = "00:00";
			kzui_mc.page_txt.text = (index_swf + 1).toString() + "/" + arr_list.length.toString();
			kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.x + kzui_mc.jdzz_mc.width * ( -1);
			//slider.x=401.45;
			
			btnPPVisSet(true);
			
			//帧测试
			//frameTest.txt_swfname.text = "当前动画名称:  " + arr_list[index_swf];
			//frameTest.txt_frame.text = "当前动画帧数：	0";
		}

		//视频播放
		private function playStart():void
		{
			bufferInit();
			initForPlay();
			var url:String="swf/"+arr_list[index_swf]+".swf";
			var request:URLRequest = new URLRequest(url);
			loader = new Loader();
			loader.load(request);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress_Handler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete_Handler);
			loader.contentLoaderInfo.addEventListener(Event.INIT, loadInit_Handler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			trace("swf url:		" + url);
			if (_isMUlU)
			{
				highLighted(index_swf, true);		//先展开当前层级
				setMenuStatus(arr_readed);			//setMenuStatus(arr_reading);------>>标识已阅读
			}
		}
		
		private function playStart2():void
		{
			setInteractEnabled(true);
			btnStatusRefresh();
			specialProcess_playStart();
			try
			{
				//mc.addChild(loader);
				stage_mc.addChild(loader);				
			}
			catch (error:Error) 
			{
				trace(error.message);
			}
			
			kzui_mc.totalBar.alpha = 1;
			mc_swf.gotoAndPlay(1);
			if(mc_swf._mc!=null)
				mc_swf._mc.gotoAndPlay(1);
			addToReading(arr_list[index_swf]);
			submitToPlatform();
			
			if (_isMUlU)
			{
				if (getMenuObj(index_swf) == null)
				{
					highLighted(index_swf, true);		//先展开当前层级
					setMenuStatus(arr_readed);			//setMenuStatus(arr_reading);------>>标识已阅读
				}
			}
			specialProcess_playStart2();
			//trace(mc_swf.loaderInfo.actionScriptVersion);
		}
		
		//添加到已阅读列表
		private function addToReading(swfName:String):void
		{
			var samenum:int = 0;
			for (var i:int = 0; i < arr_reading.length; i++)
			{
				if (arr_reading[i] == "") 
					arr_reading.splice(i,1);
				if(arr_reading[i]==swfName)
					samenum++;
			}
			if (samenum==0)
			{
				arr_reading.push(swfName);
				arr_reading.sort();
			}
		}
		
		//添加到阅读结束列表
		private function addToReaded(swfName:String):void
		{
			var samenum:int = 0;
			for (var i:int = 0; i < arr_readed.length; i++)
			{
				if (arr_readed[i] == "") 
					arr_readed.splice(i,1);
				if(arr_readed[i]==swfName)
					samenum++;
			}
			if (samenum==0)
			{
				arr_readed.push(swfName);
				arr_readed.sort();
				getLocationStr();
				submitToPlatform();
			}
			/*
			trace("----------readed		list-------------------");
			for (var j:int = 0; j < arr_readed.length; j++)
			{
				
				trace(arr_readed[j]);
			}
			trace("----------------------------------------");
			*/
			
		}

		//------------------------视频加载处理------------------------------------------------------------------
		private function loadProgress_Handler(evt:ProgressEvent):void
		{
			loading_mc.visible = true;
			loading_mc._txt.text = Math.round(evt.bytesLoaded / evt.bytesTotal * 100) + "%";
			loading_mc.bar_mc.width = evt.bytesLoaded / evt.bytesTotal * loading_width;
		}
		
		private function loadInit_Handler(evt:Event):void
		{
			var mc_tmp:MovieClip = evt.target.content as MovieClip;
			//if (mc_tmp != null)
				mc_tmp.stop();
		}
		
		private function errorHandler(evt:IOErrorEvent):void
		{
			trace("IOErrorEvent	错误信息：	" + evt.target);
			if (arr_list.length > 0)
				trace("IOErrorEvent	错误信息：	"+arr_list[index_swf],index_swf);
			
		}
	
		
		private function loadComplete_Handler(evt:Event):void
		{
			mc_swf = evt.target.content as MovieClip;
			swf_totalFrames=mc_swf.totalFrames;
			loading_mc.visible = false;
			
			//kzui_mc.zimu_mc.open_mc.visible = false;
			//kzui_mc.zimu_mc.close_mc.visible = true;
			zimuVisInit();
			playStart2();
			
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress_Handler);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete_Handler);
			loader.contentLoaderInfo.removeEventListener(Event.INIT, loadInit_Handler);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_isChangeSWF = false;
		}

		//-----------------------------------进度条和滑块的控制---------------------------------------
		
		//视频滑块拖动控制 
		private function getCurrentFrame():int
		{
			var f:int;
			if (kzui_mc.jdd_mc.mouseX < kzui_mc.jdd_mc.x)
			{
				
				//slider.x=rectRange_slider.x;
				kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.x + kzui_mc.jdzz_mc.width * ( -1);
			}
			else
				if (kzui_mc.jdd_mc.mouseX > (kzui_mc.jdd_mc.x + kzui_mc.jdd_mc.width))
				{
					
					//slider.x=rectRange_slider.x+rectRange_slider.width;
					kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.x;
				}
				else
				{
					//slider.x=mouseX;
					kzui_mc.jdzz_mc.x = kzui_mc.jdd_mc.mouseX - kzui_mc.jdzz_mc.width + kzui_mc.jdd_mc.x;
				}
			//kzui_mc.jdzz_mc.width=slider.x-kzui_mc.jdd_mc.x;
			//f=int((slider.x-kzui_mc.jdd_mc.x)/kzui_mc.jdd_mc.width*swf_totalFrames);
			f = int(kzui_mc.jdd_mc.mouseX / kzui_mc.jdd_mc.width * swf_totalFrames);
			if (f > swf_totalFrames)
				f = swf_totalFrames;
			return f;
		}
	
		private function jdd_mc_ClickHandler(evt:MouseEvent):void
		{
			
			mc_swf.gotoAndPlay(getCurrentFrame());
			if(mc_swf._mc!=null)
				mc_swf._mc.gotoAndPlay(getCurrentFrame());
			btnPPSet(true);
			
			/*trace(kzui_mc.mouseX, "	kzui_mc.mouseX");
			trace(mouseX, "	mouseX");
			trace(kzui_mc.jdd_mc.mouseX, "	kzui_mc.jdd_mc.mouseX");*/
		}
		
		//-------------btn函数   settings-------------------------------------------------------------
		private function eventListener():void
		{
			kzui_mc.porp_mc.buttonMode = true;
			kzui_mc.zimu_mc.buttonMode = true;
			
			/*kzui_mc.porp_mc.pause_mc.mouseChildren = false;
			kzui_mc.porp_mc.play_mc.mouseChildren = false;
			kzui_mc.pre_mc.mouseChildren = false;
			kzui_mc.next_mc.mouseChildren = false;
			kzui_mc.zimu_mc.open_mc.mouseChildren = false;
			kzui_mc.zimu_mc.close_mc.mouseChildren = false;*/
		
			//click
			kzui_mc.porp_mc.pause_mc.addEventListener(MouseEvent.CLICK,btn_pause_ClickHandler);
			kzui_mc.porp_mc.play_mc.addEventListener(MouseEvent.CLICK,btn_play_ClickHandler);
			kzui_mc.pre_mc.addEventListener(MouseEvent.CLICK,btn_pre_ClickHandler);
			kzui_mc.next_mc.addEventListener(MouseEvent.CLICK, btn_next_ClickHandler);
			kzui_mc.mulu_btn.addEventListener(MouseEvent.CLICK, btn_mulu_ClickHandler);
			kzui_mc.zimu_mc.open_mc.addEventListener(MouseEvent.CLICK, btn_zimu_ClickHandler);
			kzui_mc.zimu_mc.close_mc.addEventListener(MouseEvent.CLICK, btn_zimu_ClickHandler);

			addEventListener(Event.ENTER_FRAME,onFrameHandler);
			
			//进度条的控制相应区域
			kzui_mc.jdd_mc.addEventListener(MouseEvent.CLICK, jdd_mc_ClickHandler);
			kzui_mc.jdd_mc.buttonMode = true;
			
			//special
			mulutiao_btn.addEventListener(MouseEvent.CLICK, btn_mulu_ClickHandler);
			
		}
		
		//背景音乐处于一直可点的状态
		private function setInteractEnabled(enValue:Boolean):void
		{
			kzui_mc.porp_mc.pause_mc.mouseEnabled = enValue;
			kzui_mc.porp_mc.play_mc.mouseEnabled = enValue;
			kzui_mc.zimu_mc.open_mc.mouseEnabled = enValue;
			kzui_mc.zimu_mc.close_mc.mouseEnabled = enValue;
			kzui_mc.jdd_mc.mouseEnabled = enValue;
			
			
			if (enValue)
			{
				kzui_mc.porp_mc.pause_mc.alpha = 1.0;
				kzui_mc.porp_mc.play_mc.alpha = 1.0;
				kzui_mc.zimu_mc.open_mc.alpha = 1.0;
				kzui_mc.zimu_mc.close_mc.alpha = 1.0;
				//kzui_mc.pre_mc.alpha= 1.0;
				//kzui_mc.next_mc.alpha = 1.0;	
			}
			else
			{
				kzui_mc.porp_mc.pause_mc.alpha = 0.5;
				kzui_mc.porp_mc.play_mc.alpha = 0.5;
				kzui_mc.zimu_mc.open_mc.alpha = 0.5;
				kzui_mc.zimu_mc.close_mc.alpha = 0.5;
				kzui_mc.pre_mc.alpha = 0.5;
				kzui_mc.pre_mc.mouseEnabled = false;
				kzui_mc.next_mc.mouseEnabled = false;
				kzui_mc.next_mc.alpha = 0.5;
			}
			 //mulu_mc.thismulu_mc.mouseEnabled = enValue;
			// mulu_mc.thismulu_mc.mouseChildren = enValue;
			
		}

		//对于前进和后退按钮的可用性的控制
		private function btnStatusRefresh():void
		{
			
			if (arr_list.length < 2)
			{
				kzui_mc.next_mc.mouseEnabled=false;	
				kzui_mc.next_mc.alpha = 0.5;
				kzui_mc.pre_mc.mouseEnabled=false;	
				kzui_mc.pre_mc.alpha = 0.5;
				return;
			}
			
			if(index_swf>0 && index_swf<(arr_list.length-1))
			{
				kzui_mc.pre_mc.alpha=1;	
				kzui_mc.pre_mc.mouseEnabled = true;
				if (kzui_mc.next_mc != null)
				{
					kzui_mc.next_mc.alpha=1;
					kzui_mc.next_mc.mouseEnabled=true;		
				}
			}
			else
			{	
				if(index_swf==0)
				{
					if (kzui_mc.next_mc != null)
					{
						kzui_mc.next_mc.alpha=1;
						kzui_mc.next_mc.mouseEnabled = true;	
					}
					kzui_mc.pre_mc.mouseEnabled=false;			
					kzui_mc.pre_mc.alpha = 0.5;
				}
				if(index_swf==(arr_list.length-1))
				{
					kzui_mc.pre_mc.alpha=1;
					kzui_mc.pre_mc.mouseEnabled = true;
					if (kzui_mc.next_mc != null)
					{
						kzui_mc.next_mc.mouseEnabled=false;	
						kzui_mc.next_mc.alpha=0.5;
					}
				}
			}
		}
		
		private function btnPPSet(enValue:Boolean):void
		{
			if (enValue)
			{
				kzui_mc.porp_mc.pause_mc.mouseEnabled = true;
				kzui_mc.porp_mc.play_mc.mouseEnabled = true;
				kzui_mc.porp_mc.pause_mc.alpha = 1.0;
				kzui_mc.porp_mc.play_mc.alpha = 1.0;
			}
			else
			{
				kzui_mc.porp_mc.pause_mc.mouseEnabled = false;
				kzui_mc.porp_mc.play_mc.mouseEnabled = false;
				kzui_mc.porp_mc.pause_mc.alpha = 0.5;
				kzui_mc.porp_mc.play_mc.alpha = 0.5;
			}
			btnPPVisSet(true);
			
		}
		
		
		private function btnPPVisSet(visValue:Boolean):void
		{
			if (visValue)
			{
				kzui_mc.porp_mc.pause_mc.visible = true;
				kzui_mc.porp_mc.play_mc.visible = false;
			}
			else
			{
				kzui_mc.porp_mc.pause_mc.visible = false;
				kzui_mc.porp_mc.play_mc.visible = true;
			}
		}
		
		//-------------btn函数-------------------------------------------------------------
		private function btn_exit_ClickHandler(evt:MouseEvent):void
		{
			//sound.close();			//关闭流
			//channel.stop();			//停止音乐的播放
			//mc.removeChild(loader);
			//removeChild(mc);			//**********************removeall(), flash自动回收机制？？？？
			SoundMixer.stopAll();
			submitToPlatform();
			fscommand("EXIT");
			
			
			//var adobeURL:URLRequest=new URLRequest("Scripts/close.html");
			//navigateToURL(adobeURL,"_top");
		}
		
		private function btn_help_ClickHandler(evt:MouseEvent):void
		{
			//弹出帮助页面
			var adobeURL:URLRequest=new URLRequest("Scripts/help.html");
			navigateToURL(adobeURL);
		}
		
		private function SWFPause():void
		{
			mc_swf.stop();
			if (mc_swf._mc != null)
			{
				mc_swf._mc.stop();
			}
			btnPPVisSet(false);
		}
		
		private function SWFPlay():void
		{
			if (mc_swf != null)
			{
				mc_swf.gotoAndPlay(mc_swf.currentFrame);
				if (mc_swf._mc != null)
				{
					mc_swf._mc.gotoAndPlay(mc_swf.currentFrame);
				}
				
				if (mc_swf.totalFrames == mc_swf.currentFrame)
				{
					mc_swf.gotoAndPlay(0);
					if (mc_swf._mc != null)
					{
						mc_swf._mc.gotoAndPlay(0);
					}
				}
				
				btnPPVisSet(true);
			}
			
		}
		
		private function SWFNext():void
		{
			if(index_swf<arr_list.length-1)
			{
				changeSWF_Handler();
				index_swf++;
				playStart();
			}
		}
		
		private function btn_pause_ClickHandler(evt:MouseEvent):void
		{
			SWFPause();
		}
		
		private function btn_play_ClickHandler(evt:MouseEvent):void
		{
			SWFPlay();
		}
	
		private function btn_replay_ClickHandler(evt:MouseEvent):void
		{
			mc_swf.gotoAndPlay(0);
			if(mc_swf._mc!=null)
				mc_swf._mc.gotoAndPlay(0);
			btnPPSet(true);
		}
	
		
		private function btn_zimu_ClickHandler(evt:MouseEvent):void
		{
			kzui_mc.zimu_mc.open_mc.visible = !(kzui_mc.zimu_mc.open_mc.visible);
			kzui_mc.zimu_mc.close_mc.visible = !(kzui_mc.zimu_mc.close_mc.visible);
			if (mc_swf != null && mc_swf._mc!=null)
			{
				mc_swf._mc.visible = kzui_mc.zimu_mc.close_mc.visible;
			}
		}
		
		private function btn_pre_ClickHandler(evt:MouseEvent):void
		{
			if(index_swf>0)
			{
				changeSWF_Handler();
				index_swf--;
				playStart();
			}
		}
		
		private function btn_next_ClickHandler(evt:MouseEvent):void
		{
			SWFNext();		
		}
	
		private function btn_mulu_ClickHandler(evt:MouseEvent):void
		{
			
			if (mulu_mc.y<452)
			{
				var twMove:Tween = new Tween(mulu_mc, "y", Bounce.easeIn, 70, 500, 0.8, true);
				mulutiao_btn.mouseEnabled = true;
				setTimeout(function() { mulutiao_btn.visible = true; }, 800);
				if (hasEventListener(MouseEvent.MOUSE_WHEEL))
				{
					removeEventListener(MouseEvent.MOUSE_WHEEL, mulu_WheelHandler);
				}
				
			}
			else
			{
				var twMove1:Tween = new Tween(mulu_mc, "y", Bounce.easeOut, 500 , 70, 0.8, true);
				mulutiao_btn.mouseEnabled = false;
				setTimeout(function() { mulutiao_btn.visible = false; }, 0);
				setHkVis();
			}
		}
	
		//-----------------------------------------------------------------------------------------

	}
} 
