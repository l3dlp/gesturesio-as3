package  
{
	import flash.ui.Mouse;
	import flare.basic.Scene3D;
	import flare.core.Light3D;
	import flare.core.Camera3D;
	import flare.system.Input3D;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	import flash.display.Sprite;

	// import of the GIO library
	import io.gestures.G;
	// import of the GIO debug library
	import io.gestures.GIODebug;
	
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
			// flare3D specifics
			scene = new Scene3D(this);
			scene.backgroundColor = 0x00aeef;
			scene.antialias = 2;
			scene.autoResize = true;
			scene.camera = new Camera3D();
			scene.camera.z = distanceZaxis;
			light = new Light3D("sun",1);
			scene.addChild(light);
						
			// init GIO
			G.IO().init(800, 450);
			
			// adding GIODebug sprite as invisible, a keyboard stroke will switch to visible and vice versa
			debugSprite = new GIODebug();
			addChild(debugSprite); 
			debugSprite.visible = false;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey_Down, false, 0, true); 
			scene.addEventListener(Scene3D.UPDATE_EVENT, updateEvent );
		}
		private function onKey_Down (event:KeyboardEvent):void {  
			if(event.keyCode == 32){ //SPACEBAR
				debugSprite.visible = !debugSprite.visible;
			}
        }
		private function updateEvent(e:Event):void 
		{
			var resultUpdateGIO:String = G.IO().update();
			var i:int;
			var rightX:Number;
			var rightY:Number;	
			var rightZ:Number = 0.0;	
			
			// we move the light around so it's prettier
			light.x = Math.cos( getTimer() / 1000 ) * 500;
			light.y = 500
			light.z = Math.sin( getTimer() / 1000 ) * 500;
			
			
			if (resultUpdateGIO == "data") {
				// we have a user
				Mouse.hide();
				rightX = G.IO().getPos("right_hand").x;
				rightY =  G.IO().getPos("right_hand").y;
				// what we receive has been normalised: -1 = 0 ; 0 = 1 ; 1 = 2
				// denormalisation then multiplication
				rightZ = 800.0 * reverseNormalisation(G.IO().getPos("right_hand").z);
				// we apply a factor to scale what we have from the center out
				rightX = (rightX - stage.stageWidth / 2.0) * 0.88 / stage.stageWidth * 800.0;
				rightY = -(rightY - stage.stageHeight / 2.0) * 0.88 / stage.stageHeight * 450.0;
				createCube(rightX, rightY, rightZ);
			} else {
				// there is no visible user we take the mouse as input
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