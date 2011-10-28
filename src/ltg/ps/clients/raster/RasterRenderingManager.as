package ltg.ps.clients.raster {
	
	import flash.display.BitmapData;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	public class RasterRenderingManager {
		
		/// static singleton instance 
		protected static var instance:RasterRenderingManager = null;
		// double buffer
		public var backBuffer:BitmapData;
		// the last frame time 
		protected var lastFrame:Date;
		
		// collection of all rendered objects
		protected var graphicObjects:ArrayCollection = new ArrayCollection();
		// a collection where new GraphicObjects are placed
		protected var newGraphicObjects:ArrayCollection = new ArrayCollection();
		// a collection where removed GraphicObjects are placed 
		protected var removedGraphicObjects:ArrayCollection = new ArrayCollection();
		
		
		/**
		 * Returns the only instance of this class
		 */
		static public function get Instance():RasterRenderingManager {
			if ( instance == null )
				instance = new RasterRenderingManager();
			return instance;
		}
		
		
		/** 
		 * Constructor
		 */ 
		public function RasterRenderingManager() {
			if ( instance != null )
				throw new Error( "Only one Singleton instance should be instantiated" ); 	
			backBuffer = new BitmapData(FlexGlobals.topLevelApplication.width, FlexGlobals.topLevelApplication.height, false);
		}
		
		
		/** 
		 * Initializas the Rendering Manager
		 */ 
		public function startup():void {
			lastFrame = new Date();
			
			new BouncingPlane().startupBounce();
		}
		
		
		/**
		 *  Shuts down the Rendering Manager.
		 *  Disposes all GraphicObject that haven't been disposed yet.
		 */
		public function shutdown():void{
			for each (var go:GraphicObject in graphicObjects) {
				var found:Boolean = false;
				for each (var removedObject:GraphicObject in removedGraphicObjects) {
					if (removedObject == go) {
						found = true;
						break;
					}
				}
				if (!found)
					go.shutdown();
			}
		}
		
		
		/** 
		 * Executed once per frame
		 */
		public function enterFrame():void {
			// Calculate the time since the last frame
			var thisFrame:Date = new Date();
			var seconds:Number = (thisFrame.getTime() - lastFrame.getTime())/1000.0;
			lastFrame = thisFrame;	
			
			// Add/Remove objects
			removeDeletedGraphicObjects();
			insertNewGraphicObjects();
			
			// Update all active GraphicObject
			for each (var go:GraphicObject in graphicObjects) {
				if (go.inuse) 
					go.enterFrame(seconds);
			}
			
			// Draw all active GraphicObjects
			drawObjects();
		}
		
		
		/**
		 *  Renders all active objects.
		 */
		protected function drawObjects():void {
			// Clear the back buffer
			backBuffer.fillRect(backBuffer.rect, 0xFF0043AB);
			
			// Draws objects
			for each (var go:GraphicObject in graphicObjects) {
				if (go.inuse) 
					go.copyToBackBuffer(backBuffer);
			}
		}
		
		
		/**
		 * Adds a graphic object.
		 * The objects are added to the newGraphicObjects collection to avoid modifying the
		 * grphicObjects collection while iterating over it. This avoids racing conditions.
		 */
		public function addGraphicObject(go:GraphicObject):void {
			newGraphicObjects.addItem(go);
		}
		
		
		/**
		 * Removes a graphic object.
		 * The objects are removed from the removedGraphicObjects collection to avoid modifying the 
		 * grphicObjects collection while iterating over it. This avoids racing conditions.
		 */
		public function removeGraphicObject(go:GraphicObject):void {
			removedGraphicObjects.addItem(go);
		}
		
		
		/**
		 * Moves all the new  objects from newGraphicObjects to the main 
		 * graphicObjects collection: this way they will appear in the next 
		 * frame refresh. This is an expansive opearation!!!
		 */
		protected function insertNewGraphicObjects():void {
			for each (var go:GraphicObject in newGraphicObjects) {
				for (var i:int = 0; i < graphicObjects.length; ++i) {
					if (graphicObjects.getItemAt(i).zOrder > go.zOrder ||
						graphicObjects.getItemAt(i).zOrder == -1)
						break;
				}
				graphicObjects.addItemAt(go, i);
			}
			newGraphicObjects.removeAll();
		}
		
		
		/**
		 * Removes all deleted objects in removedGraphicObjects from the 
		 * main graphicObjects collection: this way they will disappear in the next 
		 * frame refresh. This is an expansive opearation!!!
		 */
		protected function removeDeletedGraphicObjects():void {
			// insert the object acording to it's z position
			for each (var ro:GraphicObject in removedGraphicObjects) {
				var i:int = 0;
				for (i = 0; i < graphicObjects.length; ++i) {
					if (graphicObjects.getItemAt(i) == ro) {
						graphicObjects.removeItemAt(i);
						break;
					}
				}
			}
			removedGraphicObjects.removeAll();
		}
	}
}