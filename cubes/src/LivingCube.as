package  
{
	import flash.utils.getTimer;
	import flare.basic.*;
	import flare.core.*;
	import flare.materials.*;
	import flare.materials.filters.*;
	import flare.system.*;
	import flare.primitives.Cube;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	/**
	 * ...
	 * @author philippe
	 */
	public class LivingCube
	{
		private var stepZ:Number = 5;
		private var maxDistanceZ:Number = 500;
		public var hasToBeRemoved:Boolean = false;
		private var alphaValue:Number = 1.0;
		private var colorValue:Number;
		public var theCube:Pivot3D;
		public var theCubeContainer:Pivot3D;
		private var pointOfReference:Pivot3D = new Pivot3D;
		private var rotationX:Number;
		private var rotationY:Number;
		private var timeOfBirth:Number;
		private var theScene:Scene3D;
		private var distanceZ:Number = 0;
		private var mainColorMaterial:Shader3D;
		public function LivingCube(theScene:Scene3D,startX:Number,startY:Number, rightZ:Number) 
		{
			this.theScene = theScene;
			var sizeOfCube:Number = 20;
			theCube = new Cube("", sizeOfCube, sizeOfCube, sizeOfCube);
			theCubeContainer = new Pivot3D;
			theCubeContainer.addChild(theCube);
			theScene.addChild(theCubeContainer);
			rotationX = Math.random() * 180 -90;
			rotationY = Math.random() * 180 -90;
			pointOfReference.x = startX;
			pointOfReference.y = startY;
			pointOfReference.z = rightZ;
			pointOfReference.setRotation( rotationX, rotationY, 0 );
			mainColorMaterial = new Shader3D( "mainColor" );
			mainColorMaterial.filters.push( new ColorFilter( 0xff0000, 1, BlendMode.NORMAL ) );
			mainColorMaterial.filters.push( new SpecularFilter( 200, 1 ) );
			mainColorMaterial.transparent = true;
			mainColorMaterial.build();
			theCube.setMaterial(mainColorMaterial);
			mainColorMaterial.filters[0].r = Math.cos( getTimer() / 600 ) * 0.5 + 0.5;
			mainColorMaterial.filters[0].g = Math.cos( getTimer() / 700 ) * 0.5 + 0.5;
			mainColorMaterial.filters[0].b = Math.cos( getTimer() / 800 ) * 0.5 + 0.5;
		}
		public function update():void {
			distanceZ+=stepZ;
			theCubeContainer.copyTransformFrom( pointOfReference );
			theCubeContainer.translateZ( distanceZ );
			theCube.rotateX(1);
			theCube.rotateY(1);
			var theAlpha:Number = (maxDistanceZ - distanceZ) / maxDistanceZ;
			if (distanceZ > maxDistanceZ) {
				mainColorMaterial.filters[0].a = 0;
				hasToBeRemoved = true;
			} else {
				mainColorMaterial.filters[0].a = (maxDistanceZ - distanceZ) / maxDistanceZ;
			}
		}
		public function recycle(startX:Number, startY:Number, rightZ:Number):void {
			hasToBeRemoved = false;
			rotationX = Math.random() * 180 -90;
			rotationY = Math.random() * 180 -90;
			pointOfReference.x = startX;
			pointOfReference.y = startY;
			pointOfReference.z = rightZ;
			pointOfReference.setRotation( rotationX, rotationY, 0 );
			mainColorMaterial.filters[0].r = Math.cos( getTimer() / 600 ) * 0.5 + 0.5;
			mainColorMaterial.filters[0].g = Math.cos( getTimer() / 700 ) * 0.5 + 0.5;
			mainColorMaterial.filters[0].b = Math.cos( getTimer() / 800 ) * 0.5 + 0.5;
			mainColorMaterial.filters[0].a = 1.0;
			distanceZ = 0;
		}
	}

}