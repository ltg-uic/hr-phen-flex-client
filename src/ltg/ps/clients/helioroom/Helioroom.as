package ltg.ps.clients.helioroom {
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import ltg.ps.clients.commons.ClientNetworkController;
	import ltg.ps.clients.commons.Degree;
	import ltg.ps.clients.vector.VectorRenderingManager;
	
	import mx.states.State;
	
	import org.flexunit.runner.notification.async.WaitingListener;
	import org.igniterealtime.xiff.data.Message;
	import org.igniterealtime.xiff.data.Presence;
	import org.igniterealtime.xiff.events.MessageEvent;
	import org.igniterealtime.xiff.events.PresenceEvent;
	
	[Bindable]
	public class Helioroom extends EventDispatcher{
		
		//Constants
		public  static const PHEN_INIT:String 	  		= "phenInit";
		public  static const PHEN_UPDATE:String   		= "phenUpdate";
		public  static const PHEN_UPDATE_DONE:String   	= "phenUpdateDone";
		private static const DEFAULT_STATE:String 		= "default";
		private static const UPDATED_STATE:String 		= "updated";
	  	
		// Simulation parameters - defaulted to solar system with 9 planets
		private var _viewingAngleBegin:Degree;
		private var _viewingAngleEnd:Degree;
		private var _span:Number;
		private var _planetRepresentation:String = "";
		private var _planetNames:String = "";
		private var _phenState:String = "";
		private var _startTime:Number = -1;
		private var _planets:Array;
		
		// State
		private var state:String = DEFAULT_STATE;
		
		
		// Constructor
		public function Helioroom() {
		}
		
		
		
		public function get viewingAngleBegin():Degree {return _viewingAngleBegin};
		public function get viewingAngleEnd():Degree {return _viewingAngleEnd};
		public function get span():Number {return _span};
		public function get planetRepresentation():String {return _planetRepresentation};
		public function get planetNames():String {return _planetNames};
		public function get phenState():String {return _phenState};
		public function get startTime():Number {return _startTime};
		public function get planets():Array {return _planets};
			
		// Whenever an update is received from the server
		public function onUpdateReceived(e:MessageEvent): void {
			// Update the data
			var message:XML = new XML(e.data.body);
			if (state==DEFAULT_STATE) {
				parseFirstXMLupdate(message);
				state=UPDATED_STATE;
				// Propagate the first update which will trigger the change of state from connecting to rendering 
				dispatchEvent(new Event(Helioroom.PHEN_INIT));
			} else {
				parseXMLupdate(message);
				dispatchEvent(new Event(Helioroom.PHEN_UPDATE_DONE));
			}
		}
		
		
		private function parseFirstXMLupdate(m:XML): void {
			_viewingAngleBegin = new Degree(m.viewAngleBegin);
			_viewingAngleEnd = new Degree(m.viewAngleEnd);
			_span = viewingAngleBegin.sub(viewingAngleEnd).value;
			_planetRepresentation = m.planetRepresentation;
			_planetNames = m.planetNames;
			_phenState = m.state;
			_startTime = m.startTime;
			_planets = new Array();
			var plans:XMLList = m.planets.planet;
			for each (var p:XML in plans) {
				if (planetNames == "none")
					_planets.push(new Planet(p.name, p.colorName, "", 			p.color, p.classOrbitalTime, p.startPosition));
				if (planetNames == "color")
					_planets.push(new Planet(p.name, p.colorName, p.colorName, 	p.color, p.classOrbitalTime, p.startPosition));
				if (planetNames == "names")
					_planets.push(new Planet(p.name, p.colorName, p.name, 		p.color, p.classOrbitalTime, p.startPosition));
			}
			_planets.reverse();
		}
		
		
		private function parseXMLupdate(m:XML): void {
			_viewingAngleBegin = new Degree(m.viewAngleBegin);
			_viewingAngleEnd = new Degree(m.viewAngleEnd);
			_span = viewingAngleBegin.sub(viewingAngleEnd).value;
			_planetRepresentation = m.planetRepresentation;
			_planetNames = m.planetNames;
			_phenState = m.state;
			_startTime = m.startTime;
			var plans:XMLList = m.planets.planet;
			var i:int = _planets.length-1;
			for each (var p:XML in plans) {
				var pippo:Planet = _planets[i];
				_planets[i].setName(p.name);
				_planets[i].setColorName(p.colorName);
				if (planetNames == "none")
					_planets[i].setLabel("");
				if (planetNames == "color")
					_planets[i].setLabel(p.colorName);
				if (planetNames == "names")
					_planets[i].setLabel(p.name);
				_planets[i].setColor(p.color);
				_planets[i].setSpeed(p.classOrbitalTime);
				_planets[i].setStartPos(p.startPosition);
				i--;
			}
		}
		
		
		// whenever a presence message is received
//		public function onPresenceReceived(e:PresenceEvent):void {
//			trace("onPresence. " + e.toString());
//			var len:uint = e.data.length;
//			for (var i:uint = 0; i < len; ++i)
//			{
//				var presence:Presence= e.data[i] as Presence;
//				trace("onPresence. " + i + " show: " + presence.show);
//				trace("onPresence. " + i + " type: " + presence.type);
//				trace("onPresence. " + i + " status: " + presence.status);
//				trace("onPresence. " + i + " from: " + presence.from);
//				trace("onPresence. " + i + " to: " + presence.to);
//			}
//		}
	
			
	}
}