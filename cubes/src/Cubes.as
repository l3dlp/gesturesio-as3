package  
{
	import flash.ui.Mouse;
	import flare.loaders.Flare3DLoader;
	import flare.basic.*;
	import flare.collisions.*;
	import flare.core.*;
	import flare.materials.*;
	import flare.materials.filters.*;
	import flare.system.*;
	import flare.utils.*;
	import flash.display.*;
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	import flare.primitives.SkyBox;
	// import of the GIO library
	import com.gio.GIO;
	// import of the GIOEvent library
	import com.gio.GIOEvent;
	// import of the GIO debug library
	import com.gio.GIODebug;
	
	//[SWF(frameRate = 60, width = 800, height = 450, backgroundColor = 0x000000)]
	
	public class Cubes extends Sprite 
	{
		private var scene:Scene3D;
		private var distanceZaxis:Number = -500;
		private var debugSprite:Sprite;
		private var vectorCubes:Vector.<LivingCube> = new Vector.<LivingCube>;
		private var numberOfCubes:int = 0;
		private var MaxNumberOfCubes:int = 500;
		private var light:Light3D;
		
		public function Cubes() 
		{
			scene = new Scene3D(this);
			scene.backgroundColor = 0x00aeef;
			scene.antialias = 2;
			scene.autoResize = true;
			scene.camera = new Camera3D();
			
			scene.camera.z = distanceZaxis;
			
			light = new Light3D("sun",1);
			scene.addChild(light);
						
			// init GIO
			GIO.getInstance().Init(800, 450);
			// To add  GIOEvent support you have to add GIO.getInstance() to the stage
			addChild(GIO.getInstance());
			// and now add the listener
			//addEventListener(GIOEvent.GESTURE_EVENT, onGestureEvent);

			stage.addEventListener(Event.RESIZE, resizeListener); 
			
			debugSprite = new GIODebug();
			addChild(debugSprite); 
			debugSprite.visible = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey_Down, false, 0, true); 
			resizeStage();
			scene.addEventListener( Scene3D.UPDATE_EVENT, updateEvent );
		}
		private function onKey_Down (event:KeyboardEvent):void {  
			if(event.keyCode == 32){ //SPACEBAR
				debugSprite.visible = !debugSprite.visible;
			}
        }
		private function resizeListener (e:Event):void { 
			resizeStage();
		}
		private function resizeStage():void {
			GIO.getInstance().rescaleStage(stage.stageWidth, stage.stageHeight);
		}

		private function updateEvent(e:Event):void 
		{
			var resultUpdateGIO:String = GIO.getInstance().updateGIOSocket();
			var i:int;
			var rightX:Number;
			var rightY:Number;	
			var rightZ:Number = 0.0;	
			
			
			
			light.x = Math.cos( getTimer() / 1000 ) * 500;
			light.y = 500
			light.z = Math.sin( getTimer() / 1000 ) * 500;
			
			
			if (resultUpdateGIO == "data") {
				trace (GIO.getInstance().getJointPosition("right_hand").z);
				Mouse.hide();
				rightX = GIO.getInstance().getJointPosition("right_hand").x;
				rightY =  GIO.getInstance().getJointPosition("right_hand").y;
				// what we receive has been normalised: -1 = 0 ; 0 = 1 ; 1 = 2
				// denormalisation then multiplication
				rightZ = 800.0 * reverseNormalisation(GIO.getInstance().getJointPosition("right_hand").z);
				
				if ( Input3D.mouseDown ) {
					rightX = mouseX;
					rightY = mouseY;
				}
				
				rightX = (rightX - stage.stageWidth / 2.0) * 0.88 / stage.stageWidth * 800.0;
				rightY = -(rightY - stage.stageHeight / 2.0) * 0.88 / stage.stageHeight * 450.0;
				createCube(rightX, rightY, rightZ);
			} else {
				Mouse.show();
				if ( Input3D.mouseDown ) {
					rightX = mouseX;
					rightY = mouseY;
					rightX = (rightX - stage.stageWidth / 2.0) * 0.88 / stage.stageWidth * 800.0;
					rightY = -(rightY - stage.stageHeight / 2.0) * 0.88 / stage.stageHeight * 450.0;
					createCube(rightX, rightY, rightZ);
				}
			}
			for (i = 0; i < vectorCubes.length; i++ ) {
				vectorCubes[i].update();
			}
		}
		private function createCube(rightX:Number, rightY:Number, rightZ:Number):void {
			var i:int;
			if (numberOfCubes < MaxNumberOfCubes) {
				vectorCubes.push(new LivingCube(scene, rightX, rightY, rightZ));
				numberOfCubes++;
			} else {
				for (i = 0; i < vectorCubes.length; i++ ) {
					if (vectorCubes[i].hasToBeRemoved) {
						vectorCubes[i].recycle(rightX, rightY, rightZ);
						i = vectorCubes.length;
					}
				}
			}
		}
		private function reverseNormalisation(value:Number):Number {
			var returnVal:Number = value - 1.0;
			return (returnVal);
		}
	}
}