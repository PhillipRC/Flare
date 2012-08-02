package flare.scale
{
	import flare.util.Arrays;
	
	import flash.utils.Dictionary;
	
	/**
	 * Scale for ordered sequential data. This supports both numeric and
	 * non-numeric data, and simply places each element in sequence using
	 * the ordering found in the input data array.
	 */
	public class OrdinalScale extends Scale
	{
		private var _ordinals:Array;
		private var _lookup:Dictionary;

		/**
		 * Creates a new OrdinalScale.
		 * @param ordinals an ordered array of data values to include in the
		 *  scale
		 * @param flush the flush flag for scale padding
		 * @param copy flag indicating if a copy of the input data array should
		 *  be made. True by default.
		 * @param labelFormat the formatting pattern for value labels
		 */
		public function OrdinalScale(ordinals:Array=null, flush:Boolean=false,
			copy:Boolean=true, labelFormat:String=null)
        {
        	_ordinals = (ordinals==null ? new Array() :
        				 copy ? Arrays.copy(ordinals) : ordinals);
            buildLookup();
            _flush = flush;
            _format = labelFormat;
        }
        
        /** @inheritDoc */
		public override function get scaleType():String {
			return ScaleType.ORDINAL;
		}
        
        /** @inheritDoc */
        public override function clone() : Scale
        {
        	return new OrdinalScale(_ordinals, _flush, true, _format);
        }
        
		// -- Properties ------------------------------------------------------

		/** The number of distinct values in this scale. */
		public function get length():int
		{
			return _ordinals.length;
		}

		/** The ordered data array defining this scale. */
		public function get ordinals():Array
		{
			return _ordinals;
		}
		public function set ordinals(val:Array):void
		{
			_ordinals = val; buildLookup();
		}

		/**
		 * Builds a lookup table for mapping values to their indices.
		 */
		protected function buildLookup():void
        {
        	_lookup = new Dictionary();
            for (var i:int = 0, n:int = _ordinals.length; i < n; ++i)
                _lookup[ordinals[i]] = i;
        }
		
		/** @inheritDoc */
		public override function get min():Object { return _ordinals[0]; }
		
		/** @inheritDoc */
		public override function get max():Object { return _ordinals[_ordinals.length-1]; }
		
		// -- Scale Methods ---------------------------------------------------
		
		/**
		 * Returns the index of the input value in the ordinal array
		 * @param value the value to lookup
		 * @param defaultIndex the index to return if value is not found. Defaults to -1.
		 * @return the index of the input value. If the value is not contained
		 *  in the ordinal array, this method returns <code>defaultIndex</code>.
		 */
		public function index(value:Object, defaultIndex:int = -1):int
		{
			return value in _lookup ? _lookup[value] : defaultIndex;
		}
		
		/** @inheritDoc */
		public override function interpolate(value:Object):Number
		{
			if (_ordinals==null || _ordinals.length==0) return 0.5;
			
            var idx:Number = index(value, 0);
		    return _flush ? idx / (_ordinals.length-1) : (0.5 + idx) / _ordinals.length;
		}
		
		/** @inheritDoc */
		public override function lookup(f:Number):Object
		{
			if (_flush) {
				return _ordinals[int(Math.round(f*(_ordinals.length-1)))];
			} else {
				f = Math.max(0, Math.min(1, f*_ordinals.length - 0.5));
				return _ordinals[int(Math.round(f))];
			}
		}
		
		/** @inheritDoc */
		public override function values(num:int=-1):Array
		{
			var a:Array = new Array();
			var stride:Number = num<0 ? 1 
				: Math.max(1, Math.floor(_ordinals.length / num));
			for (var i:uint = 0; i < _ordinals.length; i += stride) {
				a.push(_ordinals[i]);
			}
			return a;
		}

	} // end of class OrdinalScale
}