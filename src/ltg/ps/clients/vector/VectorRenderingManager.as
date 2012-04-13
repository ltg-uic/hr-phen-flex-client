package ltg.ps.clients.vector {
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ltg.ps.clients.commons.Degree;
	import ltg.ps.clients.helioroom.Helioroom;
	import ltg.ps.clients.helioroom.Main_vector;
	import ltg.ps.clients.helioroom.Planet;
	
	import mx.containers.Canvas;
	
	public class VectorRenderingManager {
		
		/// Resources
		[Embed(source="/Users/tebemis/Workspace/Flash/helioroom-sim-flex-client/resources/stars2.jpeg")]
		public static var Stars:Class;
		
		/// static singleton instance 
		protected static var _instance:VectorRenderingManager = null;
		
		/// Acceleration factor
		private static var accelerationFactor:Number = 1;
		
		// Canvas and other drawing parameter
		private var _appWidth:int;
		private var _appHeight:int;
		private var _appHeight_16_9:int;
		private var _canvas:Canvas;
		private var _rightLim:Number;
		private var _leftLim:Number;
		private var _render:Boolean = false;
		private var _firstFrame:Boolean = true;
		private var _canvasObjects:Array = new Array();
		// the previous frame time 
		private var _lastFrame:Date;
		//Data
		private var _helio:Helioroom = null;
		
		
		
		/** 
		 * Constructor
		 */ 
		public function VectorRenderingManager() { 
		}
		
		

		/** 
		 * Initializas the Rendering Manager
		 */ 
		public function startup(myCanvas:Canvas, helio:Helioroom):void {
			_helio = helio;
			_canvas = myCanvas;
			// No need to check if _helio!=null here because this function is
			// triggered by the PhenInit event which ensures that helio has
			// been updated at least once.
			_leftLim = _appWidth/2 - 180*_appWidth/_helio.span;
			_rightLim = _appWidth/2 + 180*_appWidth/_helio.span;
			drawBackground();
			addPlanets();
			_lastFrame = new Date();
			_render = true;
		}
		
		
		
		/** 
		 * Draws the background (stars)
		 */
		private function drawBackground():void {
			var s:DisplayObject = new Stars();
			var bmpImage:BitmapData = new BitmapData(s.width, s.height);
			bmpImage.draw(s);
			var bg:Shape = new Shape();
			bg.graphics.beginBitmapFill(bmpImage);
			bg.graphics.drawRect(0, 0, Capabilities.screenResolutionX, Capabilities.screenResolutionY);
			bg.graphics.endFill();
			_canvas.rawChildren.addChild(bg);
		}
		
		
	
		/**
		 * Adds all planets to the canvas in reverse order to preserve the right occlusion sequence
		 */
		private function addPlanets():void {
			var plans:Array = _helio.planets;
			for each (var p:Planet in plans) {
				p.draw(_appHeight_16_9);
				p.x = setPlanetPosition(p);
				p.y = _appHeight/2;
				_canvas.rawChildren.addChild(p);
				if (p.label != null)
					_canvas.rawChildren.addChild(p.label);
				if(Main_vector.mode=="DEBUG")
					_canvas.rawChildren.addChild(p.positionLabel);												//DEBUG
			}
		}
		
		
		
		/**
		 * Re-draws planets after an update
		 */
		public function reDrawPlanets():void {
			var plans:Array = _helio.planets;
			for each (var p:Planet in plans)
				p.draw(_appHeight_16_9);
		}
		
		
		
		/** 
		 * Executed once per frame
		 */
		public function enterFrame():String {
			if(_render) {
				// Calculate the time since the last frame
				var thisFrame:Date = new Date();
				var seconds:Number = (thisFrame.getTime() - _lastFrame.getTime())/1000.0;
				_lastFrame = thisFrame;
				// Update planets positions
				for each (var p:Planet in _helio.planets) {
					if(_helio.phenState=="running")
						p.x = setPlanetPosition(p);
					p.y = _appHeight/2;
					if (p.label!= null) {
						p.label.x = p.x - p.label.width/2;
						p.label.y = p.y - p.label.height/2;
					}
					if(Main_vector.mode=="DEBUG") {
						p.positionLabel.x = p.x;														//DEBUG
						p.positionLabel.y = p.y+30;														//DEBUG
					}
				}
				if(Main_vector.mode=="DEBUG")
					return "Rendering"+thisFrame.getTime();
			}
			return "";
		}
		
		
		
		/**
		 *  Finds the start position based on current time
		 */
		private function setPlanetPosition(p:Planet):Number {
			// Finds real start position (rsp) in degrees
			var rsp_deg:Number = p.findRealStartPositionDeg();
			// Finds degrees displacement with respect to viewAngleEnd
			var disp_deg:Number = rsp_deg - _helio.viewingAngleEnd.value;
			// Transform the displacement in pixels
			var disp_pix:Number = disp_deg * _appWidth / _helio.span;
			if (disp_pix > 0) {
				if (disp_pix < _rightLim)
					return disp_pix;
				else 
					return _leftLim + (disp_pix - _rightLim);
			} else {
				if (disp_pix > _leftLim)
					return disp_pix;
				else
					return _rightLim + (disp_pix - _leftLim); 
			}
		}
		
		
		
		/**
		 *  Shuts down the Rendering Manager.
		 *  Disposes all GraphicObject that haven't been disposed yet.
		 */
		public function shutdown():void{
			_render = false;
			_canvas.graphics.clear();
		}
		
		
		
		/**
		 * Updates application size
		 */
		public function updateAppSize(width:int, height:int):void {
			_appWidth = width;
			_appHeight = height;
			_appHeight_16_9 = (width * 9) / 16;
			if (_helio!=null) {
				_leftLim = _appWidth/2 - 180*_appWidth/_helio.span;
				_rightLim = _appWidth/2 + 180*_appWidth/_helio.span;
				// Updates planets size, vertical and horizontal position
				for each (var p:Planet in _helio.planets) {
					p.draw(_appHeight_16_9);
					p.y = _appHeight/2;
					p.x = setPlanetPosition(p);
				}
			}
		}
		
	}
}