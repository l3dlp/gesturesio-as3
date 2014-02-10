package com.gio 
{
	/**
	 * ...
	 * @author Gestures.IO
	 */
	public class GIOUser 
	{
		public var trackingID:int;
		public var joints:Object;
		public function GIOUser(trackingID:int) 
		{
			this.trackingID = trackingID;
		}
		public function updateJoints(objectToBeParsed:Object):void {
			var i:int;
			var jointName:String;
			if (joints == null) {
				joints = new Object();
				for (i = 0; i < objectToBeParsed.length; i++) {
					jointName = objectToBeParsed[i].name.toLowerCase();
					joints[jointName] = new GIOJoint(objectToBeParsed[i].x, objectToBeParsed[i].y, objectToBeParsed[i].z, jointName);
				}
			} else {
				for (i = 0; i < objectToBeParsed.length; i++) {
					jointName = objectToBeParsed[i].name.toLowerCase();
					joints[jointName].update(objectToBeParsed[i].x, objectToBeParsed[i].y, objectToBeParsed[i].z);
				}
			}					
		}
		public function nullify():void {
			joints = null;
		}
	}
}