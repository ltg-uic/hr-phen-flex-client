package ltg.ps.clients.raster {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;

	public class GraphicResource {
		public var bitmap:BitmapData = null;
		public var bitmapAlpha:BitmapData = null;
		
		
		public function GraphicResource(image:DisplayObject) {
			bitmap = createBitmapData(image);
			bitmapAlpha = createAlphaBitmapData(image);
		}
		
		
		protected function createBitmapData(image:DisplayObject):BitmapData {
			var bitmap:BitmapData = new BitmapData(image.width, image.height);
			bitmap.draw(image);
			return bitmap;
		}
		
		
		protected function createAlphaBitmapData(image:DisplayObject):BitmapData {
			var bitmap:BitmapData = new BitmapData(image.width, image.height);
			bitmap.draw(image, null, null, flash.display.BlendMode.ALPHA);
			return bitmap;
		}
	}
}