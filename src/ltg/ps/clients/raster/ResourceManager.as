package ltg.ps.clients.raster {
	
	public final class ResourceManager {
		
		[Embed(source="/Users/tebemis/Workspace/Flash/Helioroom/resources/brownplane.png")]
		public static var BrownPlane:Class;
		public static var BrownPlaneGraphics:GraphicResource = new GraphicResource(new BrownPlane());
		
	}
}