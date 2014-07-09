/**
 * GESTURES.IO - AS3 Wrapper
 * @version 1.7.0
 * @author MediaStanza
 */
package io.gestures 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	public class GIODebug extends Sprite
	{
		private var rectangle:Sprite = new Sprite();
		private var face:Sprite = new Sprite();
		private var leftHand:Sprite = new Sprite();
		private var rightHand:Sprite = new Sprite();
		private var textMessage:TextField = new TextField();
		
		public function GIODebug() 
		{
			var rectangleHeight:Number = G.IO().windowHeight; 
			var rectangleWidth:Number = G.IO().windowWidth; 
			rectangle.graphics.lineStyle(2, 0x000000, 1);
			rectangle.graphics.moveTo(0, 0); 
			rectangle.graphics.lineTo(rectangleWidth, 0); 
			rectangle.graphics.lineTo(rectangleWidth, rectangleHeight); 
			rectangle.graphics.lineTo(0, rectangleHeight); 
			rectangle.graphics.lineTo(0, 0); 
			rectangle.graphics.endFill();
			addChild(rectangle);
			rectangle.height = G.IO().windowHeight;
			rectangle.width = G.IO().windowWidth; 
			
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
			var resultUpdate:String = G.IO().update();
			if (resultUpdate == "data") {
				face.x = G.IO().getPos("head").x;
				face.y = G.IO().getPos("head").y;
				leftHand.x = G.IO().getPos("left_hand").x;
				leftHand.y = G.IO().getPos("left_hand").y;
				rightHand.x = G.IO().getPos("right_hand").x;
				rightHand.y = G.IO().getPos("right_hand").y;
				face.visible = true;
				leftHand.visible = true;
				rightHand.visible = true;
				textMessage.text = "";
			} else {
				if (resultUpdate == "nodata") {
					textMessage.text = "Veuillez vous approcher de la caméra";
				} else {
					textMessage.text = "caméra non connectée";
				}
				face.visible = false;
				leftHand.visible = false;
				rightHand.visible = false;
			}
			if (rectangle.width != G.IO().windowWidth) {
				rectangle.height = G.IO().windowHeight;
				rectangle.width = G.IO().windowWidth; 
			}	
		}
		public function outputText(someString:String):void {
			textMessage.text = someString;
		}
	}
}