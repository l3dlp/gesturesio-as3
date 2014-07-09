/**
 * GESTURES.IO - AS3 Wrapper
 * @version 1.7.0
 * @author MediaStanza
 */
package io.gestures 
{
	public class GIOMessage 
	{
		public var command:String;
		public var data:Object;
		public var senderId:uint = 0;
		public function GIOMessage(command:String,data:Object = null) 
		{
			this.command = command;
			this.data = data;
			this.data["clientId"] = G.IO().clientId;
		}
	}

}