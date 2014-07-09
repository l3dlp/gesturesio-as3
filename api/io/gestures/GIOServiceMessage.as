/**
 * GESTURES.IO - AS3 Wrapper
 * @version 1.7.0
 * @author MediaStanza
 */
package io.gestures 
{
	public class GIOServiceMessage extends GIOMessage 
	{
		public function GIOServiceMessage(data:Object) 
		{
			super("SERVICE_MESSAGE", data);
		}
	}

}