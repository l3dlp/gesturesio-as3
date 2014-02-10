package com.gio  
{
	/**
	 * ...
	 * @author Gestures.IO
	 */
	public class GIOMessage 
	{
		public var command:String;
		public var data:Object;
		public var senderId:uint = 0;
		public function GIOMessage(command:String,data:Object = null) 
		{
			this.command = command;
			this.data = data;
			this.data["clientId"] = GIO.getInstance().clientId;
		}
	}

}