package com.gio 
{
	/**
	 * ...
	 * @author Gestures.IO
	 */
	public class GIOServiceMessage extends GIOMessage 
	{
		public function GIOServiceMessage(data:Object) 
		{
			super("SERVICE_MESSAGE", data);
		}
	}

}