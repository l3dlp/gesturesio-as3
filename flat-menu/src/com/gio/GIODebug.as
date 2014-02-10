package com.gio 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Gestures.IO
	 */
	public class GIODebug extends Sprite
	{
		private var rectangle:Sprite = new Sprite();
		private var face:Sprite = new Sprite();
		private var leftHand:Sprite = new Sprite();
		private var rightHand:Sprite = new Sprite();
		private var textMessage:TextField = new TextField();
		
		public function GIODebug() 
		{
			var rectangleHeight:Number = GIO.getInstance().windowHeight; 
			var rectangleWidth:Number = GIO.getInstance().windowWidth; 
			rectangle.graphics.lineStyle(2, 0x000000, 1);
			rectangle.graphics.moveTo(0, 0); 
			rectangle.graphics.lineTo(rectangleWidth, 0); 
			rectangle.graphics.lineTo(rectangleWidth, rectangleHeight); 
			rectangle.graphics.lineTo(0, rectangleHeight); 
			rectangle.graphics.lineTo(0, 0); 
			rectangle.graphics.endFill();
			addChild(rectangle);
			rectangle.height = GIO.getInstance().windowHeight;
			rectangle.width = GIO.getInstance().windowWidth; 
			
			face.graphics.beginFill(0xcccccc);
			face.graphics.drawCircle(0, 0, 30);
			face.graphics.endFill();
			addChild(face);
			
			leftHand.graphics.beginFill(0xFF0000);
			leftHand.graphics.drawCircle(0, 0, 20);
			leftHand.graphics.endFill();
			addChild(leftHand);
			
			rightHand.graphics.beginFill(0x00FF00);
			rightHand.graphics.drawCircle(0, 0, 20);
			rightHand.graphics.endFill();
			addChild(rightHand);
			
			face.visible = false;
			leftHand.visible = false;
			rightHand.visible = false;
			
			textMessage.x = 0; textMessage.y = 0;
            textMessage.width = 400; textMessage.height = 20;
            addChild(textMessage);
			addEventListener(Event.ENTER_FRAME, updateGIOSocket);
		}
		private function updateGIOSocket(event:Event):void {
			var resultUpdate:String = GIO.getInstance().updateGIOSocket();
			if (resultUpdate == "data") {
				face.x = GIO.getInstance().getJointPosition("head").x;
				face.y = GIO.getInstance().getJointPosition("head").y;
				leftHand.x = GIO.getInstance().getJointPosition("left_hand").x;
				leftHand.y = GIO.getInstance().getJointPosition("left_hand").y;
				rightHand.x = GIO.getInstance().getJointPosition("right_hand").x;
				rightHand.y = GIO.getInstance().getJointPosition("right_hand").y;
				face.visible = true;
				leftHand.visible = true;
				rightHand.visible = true;
				textMessage.text = "";
			} else {
				if (resultUpdate == "nodata") {
					textMessage.text = "Please move in front of the camera";
				} else {
					textMessage.text = "Camera is not connected";
				}
				face.visible = false;
				leftHand.visible = false;
				rightHand.visible = false;
			}
			if (rectangle.width != GIO.getInstance().windowWidth) {
				rectangle.height = GIO.getInstance().windowHeight;
				rectangle.width = GIO.getInstance().windowWidth; 
			}	
		}
		public function outputText(someString:String):void {
			textMessage.text = someString;
		}
	}
}