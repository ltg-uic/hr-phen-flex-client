package ltg.ps.clients.raster {
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class GraphicObject {
		
		// object position
		public var position:Point = new Point(0, 0);
		// higher zOrder objects are rendered on top of lower ones
		public var zOrder:int = 0;
		// the bitmap data to display	
		public var graphics:GraphicResource = null;
		// true if the object is active in the game
		public var inuse:Boolean = false;
		
		
		/**
		 *  Constructor
		 */
		public function GraphicObject() {
		}
		
		
		/** 
		 * Called when the object is added to the scene.
		 */
		public function startupGraphicObject(graphics:GraphicResource, position:Point, z:int = 0):void {
			if (!inuse) {
				this.graphics = graphics;
				this.zOrder = z;
				this.position = position.clone();
				this.inuse = true;
				
				RasterRenderingManager.Instance.addGraphicObject(this);
			}
		}
		
		
		/** 
		 * Called when the object is removed from the scene.
		 */
		public function shutdown():void {
			if (inuse) {				
				graphics = null;
				inuse = false;
				
				RasterRenderingManager.Instance.removeGraphicObject(this);
			}
		}
		
		
		/**
		 * Copies the object to the back buffer making it visible.
		 */
		public function copyToBackBuffer(db:BitmapData):void {
			db.copyPixels(graphics.bitmap, graphics.bitmap.rect, position, graphics.bitmapAlpha, new Point(0, 0), true);
		}
		
		
		/**
		 * This must be overloaded by specific GraphicObjects
		 * for updates that occur every frame. 
		 * The number received in input is the amount of milliseconds elapsed since last frame.
		 */
		public function enterFrame(dt:Number):void {
		}
		
	}
}