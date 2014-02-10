package com.gio 
{
	/**
	 * ...
	 * @author Gestures.IO
	 */
	public class GIODataMessage extends GIOMessage 
	{
		public function GIODataMessage(command:String,whichJoint:String ="",whichCoordinate:String = "",whichUser:int = 0,whichDirection:int = 0) 
		{
			var data:Object = new Object();
			data["joint"] = whichJoint;
			data["user"] = whichUser;
			data["coordinate"] = whichCoordinate;
			data["direction"] = whichDirection;
			super(command, data);
		}
	}
}