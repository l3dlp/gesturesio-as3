/**
 * GESTURES.IO - AS3 Wrapper
 * @version 1.7.0
 * @author MediaStanza
 */
package io.gestures 
{
	public class GIOJoint 
	{
		private var _x:Number;
		private var _y:Number;
		private var _z:Number;
		public var name:String;
		public function GIOJoint(x:Number,y:Number,z:Number,name:String) 
		{
			this.name = name;
			this._x = x;
			this._y = y;
			this._z = z;
		}
		public function update(x:Number, y:Number, z:Number):void {
			this._x = x;
			this._y = y;
			this._z = z;
		}
		// getter
		public function get x():Number { return (_x) ; }
		public function get y():Number { return (_y) ; }
		public function get z():Number { return (_z) ; }
	}

}