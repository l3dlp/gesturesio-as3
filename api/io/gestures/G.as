/**
 * GESTURES.IO - AS3 Wrapper
 * @version 1.7.0
 * @author MediaStanza
 */
package io.gestures 
{
	import flash.system.Security;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.events.ProgressEvent;
	import flash.net.LocalConnection;

	public class G extends Sprite
	{
		/*
		 * Fundamentals
		 */
		private static var _instance:G;
		private static var _allowInstance:Boolean;

		/*
		 * Socket Vars
		 */
		private var GIOSocket:Socket;
		private var socketClientId:String;
		private var statusId:uint = 2;
		private var users:Vector.<GIOUser>;
		private var messagesQueue:Vector.<GIOMessage> = new Vector.<GIOMessage>();
		private var messagesQueueMemory:Vector.<GIOMessage> = new Vector.<GIOMessage>();
		private var domainName:String;
		private var portNumber:int;

		/* 
		 * Gfx Vars
		 */
		private var windowW:Number;
		private var windowH:Number;
		private var scaleWinX:Number;
		private var scaleWinY:Number;

		/*
		 * Force the use of the Singleton
		 */
		public function G() 
		{
			if (!G._allowInstance)
			{
				throw new Error("Use G.IO() instead of new GIO()");
			}
		}

		/*
		 * Singleton Instance of GIO
		 */
		public static function IO():G
		{
			if (G._instance == null)
			{
				G._allowInstance = true;
				G._instance = new G();
				G._allowInstance = false;
			}
			return G._instance;
		}

		/*
		 * INIT()
		 */
		public function init(windowW:Number, windowH:Number, portNumber:int = 3310, domainName:String = "localhost"):void
		{
			this.portNumber = portNumber;
			rescale(windowW, windowH);	
			GIOSocket = new Socket();
			GIOSocket.connect(domainName, portNumber);
			GIOSocket.addEventListener(Event.CONNECT, GIOSocketHandler);
			GIOSocket.addEventListener(Event.CLOSE, GIOSocketHandler);
			GIOSocket.addEventListener(IOErrorEvent.IO_ERROR, GIOSocketHandler);
			GIOSocket.addEventListener(ProgressEvent.SOCKET_DATA, GIOSocketDataHandler);
			users = new Vector.<GIOUser>();
			var UTCdate:Date = new Date();
			var year:String = normalizeToNChars(UTCdate.fullYearUTC.toString(), 4);
			var numMonth:Number = UTCdate.monthUTC + 1;
			var month:String = normalizeToNChars(numMonth.toString(), 2);
			var numDay:Number = UTCdate.dayUTC + 1;
			var day:String = normalizeToNChars(numDay.toString(), 2);
			var hour:String = normalizeToNChars(UTCdate.getHours().toString(), 2);
			var minutes:String = normalizeToNChars(UTCdate.getMinutes().toString(), 2);
			var seconds:String = normalizeToNChars(UTCdate.getSeconds().toString(), 2);
			var milliSeconds:String = normalizeToNChars(UTCdate.getMilliseconds().toString(), 4);
			var randomToken:int = int((999 * Math.random()));
			var randomTokenString:String = getTimer().toString() + randomToken.toString();
			socketClientId = year + month + day + hour + minutes + seconds + milliSeconds + randomTokenString;
		}

		public function update():String
		{
			var returnVal:String = "";
			var i:int;
			switch(statusId)
			{
			 case 1:
				returnVal = "data";
				if (messagesQueue.length > 0) {
					for (i = 0 ; i < messagesQueue.length; i++) {
						GIOSocket.writeObject(messagesQueue[i]);
						GIOSocket.flush();
						messagesQueueMemory.push(messagesQueue[i]);
					}
					messagesQueue = new Vector.<GIOMessage>();
				}
				break;
			 case 0:
				returnVal = "nodata";
				if (messagesQueue.length > 0) {
					for (i = 0 ; i < messagesQueue.length; i++) {
						GIOSocket.writeObject(messagesQueue[i]);
						GIOSocket.flush();
						messagesQueueMemory.push(messagesQueue[i]);
					}
					messagesQueue = new Vector.<GIOMessage>();
				}
				break;
			 case 2:
				 returnVal = "notconnected";
				 if (messagesQueue.length == 0) {
					for (i = 0 ; i < messagesQueueMemory.length; i++) {
						messagesQueue.push(messagesQueueMemory[i]);
					}
				}
				 break;
			 default:
				trace("None of the above were met");
			}
			trace  (returnVal);
			return (returnVal);
		}

		private function GIOSocketHandler(event:Event):void
		{
			switch (event.type) {
				case 'ioError' :
					trace("Can't connect.");
					statusId = 2;
					break;
				case 'connect' :
					statusId = 0;
					break;
				case 'close' :
					trace("Closed.");
					statusId = 2;
					break;
			}
		}

		private function GIOSocketDataHandler(event:ProgressEvent):void
		{
			while(GIOSocket.bytesAvailable > 0)
			{
				try
				{
					var message:Object = GIOSocket.readObject();
					var theObject:Object = message.data;
					var i:int;
					var currentUsersTrackingIDs:Vector.<int> = new Vector.<int>;
					var indexUser:int;
					var currentEvent:GIOEvent;
				
					if ((message.command == "SKELETON_UPDATE") && (theObject.length != 0)) {
						statusId = 1;
						for (i = 0; i < theObject.length; i++) {
							indexUser = returnUserIndex(theObject[i].trackingID);
							if (indexUser == -1) {
								users.push(new GIOUser(theObject[i].trackingID));
								indexUser = users.length -1;
							}
							users[indexUser].updateJoints(theObject[i].joints);
							currentUsersTrackingIDs.push(theObject[i].trackingID);
						}
					} else if (message.command == "SKELETON_UPDATE") {
						statusId = 0;
					} else if (message.command == "GESTURE") {
						currentEvent = new GIOEvent(message.command, theObject);
						this.dispatchEvent(currentEvent);
					} else if (message.command == "serviceMessage") {
						currentEvent = new GIOEvent(message.command, theObject);
						this.dispatchEvent(currentEvent);
					}
					cleanUpUsers(currentUsersTrackingIDs);
				}
				catch(e:Error)
				{
				}
			}
		}

		/*
		 * Gestures and Filters Functions
		 */
		public function addGesture(whichGesture:String , whichJoint:String, whichCoordinate:String = "", whichDirection:int = 0,whichUser:uint = 0):void
		{
			messagesQueue.push(new GIODataMessage(whichGesture, whichJoint, whichCoordinate , whichUser,whichDirection ));
		}
		public function removeGesture(whichGesture:String , whichJoint:String, whichCoordinate:String = "", whichDirection:int = 0,whichUser:uint = 0):void
		{
			messagesQueue.push(new GIODataMessage("stop_" + whichGesture, whichJoint, whichCoordinate , whichUser,whichDirection ));
		}
		public function addFilter(whichJoint:String, whichCoordinate:String, whichUser:uint = 0):void
		{
			messagesQueue.push(new GIODataMessage("activateFilter", whichJoint, whichCoordinate, whichUser ));
		}
		public function removeFilter(whichJoint:String, whichCoordinate:String, whichUser:uint = 0):void
		{
			messagesQueue.push(new GIODataMessage("removeFilter", whichJoint, whichCoordinate, whichUser ));
		}

		/*
		 * Service Messages Functions
		 */
		public function sendServiceMessage(theObject:Object):void
		{
			messagesQueue.push(new GIOServiceMessage(theObject));
		}

		/*
		 * Socket Functions
		 */
		private function returnUserIndex(trackingID:int):int
		{
			var indexUser:int = -1;
			for (var i:int = 0; i < users.length; i++)
			{
				if (users[i].trackingID == trackingID)
				{
					indexUser = i;
					break;
				}
			}
			return (indexUser);
		}
		private function cleanUpUsers(currentUsersTrackingIDs:Vector.<int>):void
		{
			var i:int;
			var j:int;
			var isCurrent:Boolean;
			var nbUsers:int = users.length - 1;
			for (i = nbUsers; i >= 0; i--)
			{
				isCurrent = false;
				for (j = 0; j < currentUsersTrackingIDs.length; j++)
				{
					if (users[i].trackingID == currentUsersTrackingIDs[j])
					{
						isCurrent = true;
						break;
					}
				}
				if (isCurrent == false)
				{
					users[i].nullify();
					users.splice(i, 1);
				}
			}
		}
		
		/*
		 * Actions Functions
		 */
		public function getPos(whichJoint:String, whichUser:uint = 0):GIOPoint3D
		{
			var joint3DPoint:GIOPoint3D = new GIOPoint3D();
			if (whichUser < users.length)
			{
				var joint:GIOJoint = users[whichUser].joints[whichJoint];
				if (joint != null)
				{
					joint3DPoint = new GIOPoint3D(windowW * joint.x,windowH * joint.y,joint.z);
				}
			}
			return (joint3DPoint);
		}
		public function rescale(windowW:Number, windowH:Number):void
		{
			this.windowW = windowW;
			this.windowH = windowH;
			var cropW:Number = 400;
			var cropH:Number = 300;
			scaleWinX = windowW / cropW;
			scaleWinY = windowH / cropH;
		}
		
		/*
		 * String Functions
		 */
		private function normalizeToNChars(inputString:String, n:int):String
		{
			var outputString:String = inputString;
			var nbChars:int = inputString.length;
			for (var i:int = 0; i < (n -nbChars); i++) {
				outputString = "0" + outputString;
			}
			return (outputString);
		}

		/*
		 * Reset Functions
		 */
		public function stopListeners():void
		{
			GIOSocket.removeEventListener(Event.CONNECT, GIOSocketHandler);
			GIOSocket.removeEventListener(Event.CLOSE, GIOSocketHandler);
			GIOSocket.removeEventListener(IOErrorEvent.IO_ERROR, GIOSocketHandler);
			GIOSocket.removeEventListener(ProgressEvent.SOCKET_DATA, GIOSocketDataHandler);
		}

		/*
		 * Getters // Setters
		 */
		public function get status():Number { return (statusId) ; }
		public function get clientId():String { return (socketClientId) ; }
		public function get windowHeight():Number { return (windowH) ; }
		public function get windowWidth():Number { return (windowW) ; }
		public function get scaleWindowY():Number { return (scaleWinY) ; }
		public function get scaleWindowX():Number { return (scaleWinX) ; }
		public function set scaleWindowY(_scaleWinY:Number):void { scaleWinY = _scaleWinY; }
		public function set scaleWindowX(_scaleWinX:Number):void { scaleWinX = _scaleWinX; }
	}
}