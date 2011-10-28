package ltg.ps.clients.helioroom {
	
	import com.hurlant.crypto.prng.Random;
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.geom.Matrix;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import flashx.textLayout.formats.TextAlign;
	
	import ltg.ps.clients.commons.Degree;
	import ltg.ps.clients.vector.VectorRenderingManager;
	
	[Bindable]
	public class Planet extends Shape {
		
		// Phenomena variables
		private var _planetName:String;			// The name of the planet
		private var _speed:Number;				// Speed of the planet (in deg/sec)
		private var _color:uint;				// Color of the planet
		private var _colorName:String;			// The name of the color of the planet
		private var _startPos:Degree			// Initial position in degrees (randomized)
		// Graphics variables
		private var _label:TextField = null;
		private var txtFormat:TextFormat = null;
		private var _positionLabel:TextField = null									//DEBUG
		
		
		/**
		 * Constructor
		 */ 
		public function Planet(name:String, colorName:String, label:String, color:String, speed:Number, startPos:Number){
			_planetName = name;
			_colorName = colorName;
			initializeLabel(label);
			_color = parseInt(color);
			// Speed is transformed from minutes/round to deg/sec
			//_speed = 6 / speed;
			// Speed is transformed from minutes/round to milliseconds/round
			_speed = 60000 * speed;
			_startPos =  new Degree(startPos);
		}
		
		// Setters
		public function setName(value:String):void{_planetName = value;}
		public function setColorName(value:String):void{_colorName = value;}
		public function setLabel(value:String):void{_label.text = value.toUpperCase();}
		public function setColor(value:String):void{_color = parseInt(value);}
		public function setSpeed(value:Number):void{_speed = 60000*value;}
		public function setStartPos(value:Number):void{_startPos = new Degree(value);}
		

		public function getPlanet():Planet{
			var pl:Planet = new Planet(_planetName, _colorName, _label.text, _color.toString(), 6/_speed, _startPos.value);
			return pl;
		}
		
		
		private function initializeLabel(label:String):void {
			_label = new TextField();
			_label.autoSize = TextFieldAutoSize.CENTER;
			_label.text = label.toUpperCase();
			_positionLabel = new TextField();											//DEBUG
		}
		
		
		
		/**
		 * Draws the planet everytime it is called
		 */
		public function draw(appHeight:int): void{
			var size:int = 0.3 * appHeight; 
			this.graphics.clear();
			var mxBox:Matrix = new Matrix();
			mxBox.createGradientBox(size*2, size*2, 0, -size, -size);
			this.graphics.beginGradientFill(GradientType.RADIAL, [0xFFFFFF, _color], [1,1], [0, 255], mxBox);
			this.graphics.drawCircle(0,0, size);
			this.graphics.endFill();
			//Change label font size
			txtFormat = null;
			txtFormat = new TextFormat();
			txtFormat.align = TextAlign.CENTER;
			txtFormat.font="Arial";
			txtFormat.bold = true;
			txtFormat.size = (size/3).toFixed();
			_label.setTextFormat(txtFormat);
		}
		
		
		/**
		 * Returns the real position of the planet at the present time based on the
		 * initial state of the simulation
		 */
		public function findRealStartPositionDeg():Number {
			var timeDelta:Number = new Date().getTime();
			var remainder:Number = timeDelta % _speed;
			var realPosDeg:Degree = new Degree(_startPos.value - 360*(remainder / _speed));
			_positionLabel.text = realPosDeg.value.toString() + " \n " +
				"delta=" + timeDelta + "\n " +
				"remainder=" + remainder + "\n " +
				"speed=" + _speed + "\n " + 
				"startPos=" + _startPos.value;    															//DEBUG
			_positionLabel.textColor = 0x000000;															//DEBUG
			_positionLabel.autoSize = TextFieldAutoSize.LEFT;
			return realPosDeg.value; 
		}
		
		
		
		public function get planetName():String {return _planetName}
		public function get speed():Number {return _speed}
		public function get color():uint {return _color}
		public function get colorName():String {return _colorName}
		public function get startPos():Degree {return _startPos}
		public function get label():TextField {return _label}
		public function get positionLabel():TextField {return _positionLabel}								//DEBUG
		
	}
}