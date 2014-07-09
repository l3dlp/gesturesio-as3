package 
{
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	import flash.filters.GlowFilter;
	// import gesturesIO main library
	import io.gestures.G;

	public class Main extends Sprite 
	{
		[Embed(source = "./assets/menu1.png")] private var PictureMenu1:Class;
		[Embed(source = "./assets/menu2.png")] private var PictureMenu2:Class;
		[Embed(source = "./assets/menu3.png")] private var PictureMenu3:Class;
		[Embed(source = "./assets/cursor.png")] private var PictureCursor:Class;
		private var picCursor:Bitmap;
		private var picMenu1:Bitmap;
		private var picMenu2:Bitmap;
		private var picMenu3:Bitmap;
			
		private var timerClick:Number = -1;	
		private var currentButton:int = -1;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Mouse.hide();
			picMenu1 = new PictureMenu1();
			addChild(picMenu1);
			picMenu2 = new PictureMenu2();
			addChild(picMenu2);
			picMenu3 = new PictureMenu3();
			addChild(picMenu3);
			picCursor = new PictureCursor();
			addChild(picCursor);
			picCursor.visible = false;
			// init gesturesIO
			G.IO().init(800, 450);
			// activate filter on right hand for the x and y coordiantes
			G.IO().addFilter("right_hand", "x");
			G.IO().addFilter("right_hand", "y");
			// just in case the swf is resized for whatever reason
			stage.addEventListener(Event.RESIZE, resizeListener); 
			stage.addEventListener(Event.ENTER_FRAME, enterFrame); 
			// in the resize handler we display the three buttons centered and aligned
			resize();
		}
		private function resizeListener (e:Event):void { 
			resize();
		}
		private function resize():void {
			// inform gesturesIO that the coordinates have to be mapped to the current viewport
			G.IO().rescale(stage.stageWidth, stage.stageHeight);
			picMenu1.x = picMenu2.x = picMenu3.x = stage.stageWidth / 2 - picMenu2.width / 2;
			picMenu2.y = stage.stageHeight / 2 - picMenu2.height / 2;
			picMenu1.y = picMenu2.y - picMenu2.height - 10;
			picMenu3.y = picMenu2.y + picMenu2.height + 10;
		}
		private function enterFrame(e:Event):void 
		{
			var resultUpdateGIO:String = G.IO().update();
			var newHandX:Number;
			var newHandY:Number;
			if (resultUpdateGIO == "data") {
				picCursor.visible = true;
				newHandX = G.IO().getPos("right_hand").x;
				newHandY = G.IO().getPos("right_hand").y;
				picCursor.x = newHandX - picCursor.width / 2.0;
				picCursor.y = newHandY - picCursor.height / 2.0;
				// we will apply a glow filter to the button that the user's hand is above
				// and make it disappear if the user keeps his hand over the button for more than two seconds
				picMenu1.filters = [];
				picMenu2.filters = [];
				picMenu3.filters = [];
				var _buttonGlow:GlowFilter = new GlowFilter();
				_buttonGlow.blurX = _buttonGlow.blurY = 20;
				_buttonGlow.strength = 10;
				if (picMenu1.hitTestPoint(newHandX,newHandY) && picMenu1.visible)
				{
					picMenu1.filters = new Array(_buttonGlow);
					if (currentButton != 1) {
						timerClick = -1;
						currentButton = 1;
					}
					if (timerClick == -1) {
						timerClick = getTimer() + 2000;
					} else {
						if (getTimer() > timerClick) {
							timerClick = -1;
							currentButton = -1;
							picMenu1.visible = false;
						}
					}
				} else if (picMenu2.hitTestPoint(newHandX,newHandY) && picMenu2.visible)
				{
					picMenu2.filters = new Array(_buttonGlow);
					if (currentButton != 2) {
						timerClick = -1;
						currentButton = 2;
					}
					if (timerClick == -1) {
						timerClick = getTimer() + 2000;
					} else {
						if (getTimer() > timerClick) {
							timerClick = -1;
							currentButton = -1;
							picMenu2.visible = false;
						}
					}
				} else if (picMenu3.hitTestPoint(newHandX,newHandY) && picMenu3.visible)
				{
					picMenu3.filters = new Array(_buttonGlow);
					if (currentButton != 3) {
						timerClick = -1;
						currentButton = 3;
					}
					if (timerClick == -1) {
						timerClick = getTimer() + 2000;
					} else {
						if (getTimer() > timerClick) {
							timerClick = -1;
							currentButton = -1;
							picMenu3.visible = false;
						}
					}
				} else {
					timerClick = -1;
					currentButton = -1;
				}
			} else {
				// if the user moves offscreen we rebuild the menus
				picCursor.visible = false;
				timerClick = -1;
				currentButton = -1;
				picMenu1.filters = [];
				picMenu2.filters = [];
				picMenu3.filters = [];
				picMenu1.visible = true;
				picMenu2.visible = true;
				picMenu3.visible = true;
			}
		}
	}
}