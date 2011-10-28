package ltg.ps.clients.raster {
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Point;
	
	import mx.core.Application;
	
	
	/**
	 * This is an example class to show how to create an object from a sprite
	 */
	public class BouncingPlane extends GraphicObject {
		// movement speed of the bouncing object
		protected static const speed:Number = 100;
		// direction that the bouncing object should move (1 for right/down, -1 for left/up)
		protected var direction:Point = new Point(1, 1);
		
		
		public function BouncingPlane() {
			super();
		}
		
		
		public function startupBounce():void {
			super.startupGraphicObject(ResourceManager.BrownPlaneGraphics, new Point(0, 0));
		}
		
		
		override public function shutdown():void {
			super.shutdown();
		}
		
		
		override public function enterFrame(dt:Number):void {
			super.enterFrame(dt);
			
			position.x += direction.x * speed * dt;
			position.y += direction.y * speed * dt;
			
			if (position.x >= 854 - graphics.bitmap.width)
				direction.x = -1;
			else if (position.x <= 0)
				direction.x = 1;
			
			if (position.y >= 480 - graphics.bitmap.height)
				direction.y = -1;
			else if (position.y <= 0)
				direction.y = 1;
		}
	}
}