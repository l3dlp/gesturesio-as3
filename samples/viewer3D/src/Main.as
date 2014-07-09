package 
{
	import flare.basic.Scene3D;
	import flare.core.Pivot3D;
	import flare.core.Camera3D;
	import flare.system.Input3D;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.events.KeyboardEvent;

	// import gesturesIO main library
	import io.gestures.G;
	// import gesturesIO debug library
	import io.gestures.GIODebug;
	
	public class Main extends Sprite 
	{
		// scene objects.
		private var scene:Scene3D;
		private var watch:Pivot3D;
		
		private var debugSprite:GIODebug;
		
		public var spinX:Number = 0;
		public var spinY:Number = 0;
		public var angleY:Number = 0;
		public var angleX:Number = 10;
		public var distanceZ:Number = -200;
		public var distanceZMax:Number = -200;
		public var distanceZMin:Number = -20;
		public var lookAt:Pivot3D = new Pivot3D();
		
		private var newhandX:Number;
		private var newhandY:Number;
		
		private var angularRotationXspeed:Number = 1.0;
		private var angularRotationYspeed:Number = 2.0;
		
		private var currentHandZone:String = "center";
		private var nextHandZone:String = "center";
		private var absorptionSpeed:Number = 0.02;
		private var absorptionRight:Number = 0.0;
		private var absorptionLeft:Number = 0.0;
		private var absorptionTop:Number = 0.0;
		private var absorptionBottom:Number = 0.0;
		private var endDeceleration:Boolean = true;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Mouse.hide();
			scene = new Scene3D(this, "");
			scene.camera = new Camera3D();
			scene.camera.lookAt( 0, 0, 0 );
			scene.autoResize = true;
			watch = scene.addChildFromFile( "./assets/watch.zf3d" );
			scene.addEventListener( Scene3D.COMPLETE_EVENT, completeEvent );
			// init gesturesIO 
			G.IO().init(800, 450);
			// activate filter on right hand's x and y coordinates
			G.IO().addFilter("right_hand", "x");
			G.IO().addFilter("right_hand", "y");
			stage.addEventListener(Event.RESIZE, resizeListener); 
			// add gesturesIO debug sprite and make it invisible
			debugSprite = new GIODebug();
			addChild(debugSprite);
			debugSprite.visible = false;
			// hitting the spacebar key will gesturesIODebug sprite from non visible to visible and vice versa
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey_Down, false, 0, true);
			// just in case the swf is played in a different size than its original size
			resize();
		}
		private function onKey_Down (event:KeyboardEvent):void {  
			if(event.keyCode == 32){ //SPACEBAR
				debugSprite.visible = !debugSprite.visible;
			}
        }
		private function completeEvent(e:Event):void 
		{
			scene.removeEventListener( Scene3D.COMPLETE_EVENT, completeEvent );
			scene.addChild( watch );
			scene.addEventListener( Scene3D.RENDER_EVENT, renderEvent );
			placeCamera();
		}
		private function placeCamera():void {
			if ( angleX < 10 ) angleX = 10;
			else if ( angleX > 88 ) angleX = 88;
			lookAt.setRotation( angleX, angleY, 0 );
			scene.camera.copyTransformFrom( lookAt );
			scene.camera.translateZ( distanceZ );
			scene.camera.lookAt(0, 0, 0);	
		}
		private function resizeListener (e:Event):void { 
			resize();
		}
		private function resize():void {
			// tell gesturesIO to map x and y coordinates to current size of swf
			G.IO().rescale(stage.stageWidth, stage.stageHeight);
		}
		private function renderEvent(e:Event):void 
		{
			var resultUpdateGestureIO:String = G.IO().update();
			// we keep the possibility for the user to use his mouse
			if ( Input3D.mouseDown ) {
				Mouse.show();
				newhandX = mouseX;
				newhandY = mouseY;
			} else {
				// initiation of right hand at the center of the screen
				newhandX = stage.stageWidth / 2.0;
				newhandY = stage.stageHeight / 2.0;
			}
			if (resultUpdateGestureIO == "data") {
				// getting position of right hand from gesturesIO
				newhandX = G.IO().getPos("right_hand").x;
				newhandY = G.IO().getPos("right_hand").y;
			}
			// the goal is to see if the right hand is in the center, on the right, the left, the top or the bottom of the screen
			manageHandPosition();
			// manage smooth movement of camera
			if (endDeceleration == false) {
				endDeceleration = manageDeceleration();
			} else {
				calculateAngles();
			}
			placeCamera();
		}
		private function manageHandPosition():void {
			if (newhandY < stage.stageHeight / 3.0) {
				if ((newhandX > stage.stageWidth / 3.0) && (newhandX < 2.0 * stage.stageWidth / 3.0)) {
					//hand is on top center
					if (currentHandZone != "top") {
						endDeceleration = false;
						nextHandZone = "top";
					}
				}
			} else if (newhandY < 2.0 * stage.stageHeight / 3.0) {
				if (newhandX < stage.stageWidth *0.4) {
					// hand is at left
					if (currentHandZone != "left") {
						endDeceleration = false;
						nextHandZone = "left";
					}
				} else if (newhandX > stage.stageWidth * 0.6) {
					// hand is at right
					if (currentHandZone != "right") {
						endDeceleration = false;
						nextHandZone = "right";
					}
				} else {
					// hand is in center
					if (currentHandZone != "center") {
						endDeceleration = false;
						nextHandZone = "center";
					}
				}
			} else {
				if ((newhandX > stage.stageWidth / 3.0) && (newhandX <  2.0 * stage.stageWidth / 3.0)) {
					//hand is on bottom center
					if (currentHandZone != "bottom") {
						endDeceleration = false;
						nextHandZone = "bottom";
					}
				}
			}
		}
		private function manageDeceleration():Boolean {
			// this to have a smooth rotation
			var returnValue:Boolean = false;
			var mouseXDelta:Number = 0;
			var mouseYDelta:Number = 0;
			if (currentHandZone == "top") {
				absorptionTop -= absorptionSpeed;
				if (absorptionTop <= 0) {
					returnValue = true;
				} else {
					mouseYDelta = absorptionTop * angularRotationXspeed;
				}
			} else if (currentHandZone == "bottom") {
				absorptionBottom -= absorptionSpeed;
				if (absorptionBottom <= 0) {
					returnValue = true;
				} else {
					mouseYDelta = - absorptionBottom * angularRotationXspeed;
				}
			} else if (currentHandZone == "center") {
				returnValue = true;
			} else if (currentHandZone == "right") {
				absorptionRight -= absorptionSpeed;
				if (absorptionRight <= 0) {
					returnValue = true;
				} else {
					mouseXDelta = absorptionRight * angularRotationYspeed;
				}
			} else if (currentHandZone == "left") {
				absorptionLeft -= absorptionSpeed;
				if (absorptionLeft <= 0) {
					returnValue = true;
				} else {
					mouseXDelta = -absorptionLeft * angularRotationYspeed;
				}
			}
			angleY += mouseXDelta;
			angleX += mouseYDelta;
			if (returnValue == true) {
				absorptionBottom = 0.0;
				absorptionLeft = 0.0;
				absorptionRight = 0.0;
				absorptionTop = 0.0;
				currentHandZone = nextHandZone;
			}
			return(returnValue);
		}
		private function calculateAngles():void {
			var mouseXDelta:Number = 0;
			var mouseYDelta:Number = 0;
			if (currentHandZone == "top") {
				absorptionTop += absorptionSpeed;
				if (absorptionTop >= 1.0) {
					absorptionTop = 1.0;
				}
				mouseYDelta = absorptionTop * angularRotationXspeed;
			} else if (currentHandZone == "bottom") {
				absorptionBottom += absorptionSpeed;
				if (absorptionBottom >= 1.0) {
					absorptionBottom = 1.0;
				}
				mouseYDelta = - absorptionBottom * angularRotationXspeed;
			} else if (currentHandZone == "right") {
				absorptionRight += absorptionSpeed;
				if (absorptionRight >= 1.0) {
					absorptionRight = 1.0;
				} 
				mouseXDelta = absorptionRight * angularRotationYspeed;
			} else if (currentHandZone == "left") {
				absorptionLeft += absorptionSpeed;
				if (absorptionLeft >= 1.0) {
					absorptionLeft = 1.0;
				}
				mouseXDelta = -absorptionLeft * angularRotationYspeed;
			}
			angleY += mouseXDelta;
			angleX += mouseYDelta;
		}
	}
}