package Extensions
{
	import Actions.*;
	
	import Conditions.*;
	
	import Expressions.*;
	
	import RunLoop.*;
	
	import Services.*;
	
	import Sprites.*;
	
	public class CRunStochasticUtility extends CRunExtension
	{
		public function CRunStochasticUtility()
		{
			
		}
		
		public override function createRunObject(file:CBinaryFile, cob:CCreateObjectInfo, version:int):Boolean
		{
			seed = 1;
			return false;
		}
		
		public override function getNumberOfConditions():int
		{
			return 1;
		}
		
		public override function action(num:int, act:CActExtension):void
		{
			switch(num)
			{
				case 0:
					seed = act.getParamExpression(rh,0);
					break;
				case 1:
					seed = Math.random()*0xffffffff;
					break;
			}
		}
		
		public function Compare(First:Number, Second:Number, ComparisonType:int):Boolean
		{
			switch(ComparisonType)
			{
				case 0:
					return First == Second;
					
				case 1:
					return First != Second;
					
				case 2:
					return First > Second;
					
				case 3:
					return First < Second;
					
				case 4:
					return First >= Second;
					
				case 5:
					return First <= Second;
					
				default:
					return false;
			};
		}

		
		public override function condition(num:int, cnd:CCndExtension):Boolean
		{
			switch(num)
			{
				case 0:
					return Compare(cnd.getParamExpression(rh,0),cnd.getParamExpression(rh,1),cnd.getParamExpression(rh,2));
					break;
			}
			return false;
		}
		
		//Useful Functions
		public function Round(Value:Number):int
		{
			return (Value > 0) ? Math.floor(Value + 0.5) : Math.ceil(Value - 0.5);
		}
		
		//Number Expressions
		public function GenerateRandom(Minimum:Number, Maximum:Number):Number
		{
			return nextDoubleRange(Minimum,Maximum);
		}
		
		public function Limit(Value:Number, Minimum:Number, Maximum:Number):Number
		{
			if (Minimum < Maximum)
				return (Value < Minimum) ? (Minimum) : (Value > Maximum ? Maximum : Value);
			return (Value < Maximum) ? (Maximum) : (Value > Minimum ? Minimum : Value);
		}
		
		
		public function Nearest(Value:Number, Minimum:Number, Maximum:Number):Number
		{
			return ((Minimum > Value) ? (Minimum - Value) : (Value - Minimum)) > 
				((Maximum > Value) ? (Maximum - Value) : (Value - Maximum)) ?
				Maximum : Minimum;
		}
		
		public function Normalise(Value:Number, Minimum:Number, Maximum:Number, LimitRange:int):Number
		{
			Value = (Value - Minimum) / (Maximum - Minimum);
			
			if (LimitRange != 0)
				return Limit(Value,0,1);
			return Value;
		}
		
		public function ModifyRange(Value:Number, Minimum:Number, Maximum:Number, NewMinimum:Number, NewMaximum:Number, LimitRange:int):Number
		{
			Value = NewMinimum + (Value - Minimum) * (NewMaximum - NewMinimum) / (Maximum - Minimum);
			
			if(LimitRange != 0) return Limit(Value,NewMinimum,NewMaximum);
			return Value;
		}
		
		public function Wave(Waveform:int, Value:Number, CycleStart:Number, CycleEnd:Number, Minimum:Number, Maximum:Number):Number
		{
			switch(Waveform)
			{
				case 0:
				{
					// Sine
					return ModifyRange(Math.sin(ModifyRange(Value,CycleStart,CycleEnd,0,6.283185307179586,0)),-1,1,Minimum,Maximum,0);
				}
					
				case 1:
				{
					// Cosine
					return ModifyRange(Math.cos(ModifyRange(Value,CycleStart,CycleEnd,0,6.283185307179586,0)),-1,1,Minimum,Maximum,0);
				}
					
				case 2:
				{
					// Saw
					return UberMod(ModifyRange(Value, CycleStart, CycleEnd, Minimum, Maximum, 0), Minimum, Maximum);
				}
					
				case 3:
				{
					// Inverted Saw
					return UberMod(ModifyRange(Value, CycleStart, CycleEnd, Maximum, Minimum, 0), Minimum, Maximum);
				}
					
				case 4:
				{
					// Triangle
					return Mirror(ModifyRange(Value, CycleStart, CycleStart+(CycleEnd-CycleStart)/2, Minimum, Maximum, 0), Minimum, Maximum);
				}
					
				case 5:
				{
					// Square
					if (UberMod(Value, CycleStart, CycleEnd) < CycleStart+(CycleEnd-CycleStart)/2) return Minimum; else return Maximum;
				}
					
				default:
				{            
					// Non-existing waveform
					return 0;
				}
			};
		}
		
		
		
		public function EuclideanMod(Dividend:Number, Divisor:Number):Number
		{
			return ((Dividend%Divisor)+Divisor)%Divisor;
		}
		public function UberMod(Dividend:Number, Lower:Number, Upper:Number):Number
		{
			return ModifyRange(EuclideanMod(Normalise(Dividend,Lower,Upper,0),1),0,1,Lower,Upper,0);
		}
		
		public function Interpolate(Value:Number, From:Number, To:Number, LimitRange:int):Number
		{
			Value = From+Value*(To-From);
			
			if(LimitRange != 0) return Limit(Value,From,To);
			return Value;
		}
		public function Mirror(Value:Number, From:Number, To:Number):Number
		{
			if (From < To) {
				return From+Math.abs(EuclideanMod(Value-To,(To-From)*2)-(To-From));
			} else {
				return To+Math.abs(EuclideanMod(Value-From,(From-To)*2)-(From-To));
			}
		}
		
		public function ExpressionCompare(First:Number, Second:Number, ComparisonType:int, ReturnIfTrue:Number, ReturnIfFalse:Number):Number
		{
			if (Compare(First,Second,ComparisonType)) return ReturnIfTrue; else return ReturnIfFalse;
		}
		
		public function Approach(Value:Number, Amount:Number, Target:Number):Number
		{
			return (Value<Target) ? Math.min(Value + Amount, Target) : Math.max(Value - Amount, Target);
		}
		
		//Integer versions of the Number expressions
		public function IntGenerateRandom(Minimum:int, Maximum:int):int
		{
			return Round(GenerateRandom(Minimum,Maximum));
		}
		
		public function IntLimit(Value:int, Minimum:int, Maximum:int):int
		{
			return Round(Limit(Value,Minimum,Maximum));
		}
		public function IntNearest(Value:int, Minimum:int, Maximum:int):int
		{
			return Round(Nearest(Value,Minimum,Maximum));
		}
		public function IntNormalise(Value:int, Minimum:int, Maximum:int, LimitRange:int):int
		{
			return Round(Normalise(Value,Minimum,Maximum,LimitRange));
		}
		
		public function IntModifyRange(Value:int, Minimum:int, Maximum:int, NewMinimum:int, NewMaximum:int, LimitRange:int):int
		{
			return Round(ModifyRange(Value,Minimum,Maximum,NewMinimum,NewMaximum,LimitRange));
		}
		
		public function IntWave(Waveform:int, Value:int, CycleStart:int, CycleEnd:int, Minimum:int, Maximum:int):int
		{
			return Round(Wave(Waveform,Value,CycleStart,CycleEnd,Minimum,Maximum));
		}
		public function IntEuclideanMod(Dividend:int, Divisor:int):int
		{
			return Round(EuclideanMod(Dividend,Divisor));
		}
		public function IntUberMod(Dividend:int, Lower:int, Upper:int):int
		{
			return Round(UberMod(Dividend,Lower,Upper));
		}
		
		public function IntInterpolate(Value:int, From:int, To:int, LimitRange:int):int
		{
			return Round(Interpolate(Value,From,To,LimitRange));
		}
		public function IntMirror(Value:int, From:int, To:int):int
		{
			return Round(Mirror(Value,From,To));
		}
		
		public function IntExpressionCompare(First:int, Second:int, ComparisonType:int, ReturnIfTrue:int, ReturnIfFalse:int):int
		{
			return Round(ExpressionCompare(First, Second, ComparisonType, ReturnIfTrue, ReturnIfFalse));
		}
		
		public function IntApproach(Value:int, Amount:int, Target:int):int
		{
			return Round(Approach(Value, Amount, Target));
		}
		
		//String expressions
		public function Substr(Str:String, Start:int, Length:int):String
		{
			if(Start >= 0)
				Str = Str.substr(Start);
			else
				Str = Str.substr(Str.length+Start);
			
			if(Length >= 0)
			{
				return Str = Str.substr(0,Length);
			}
			
			var RealLength:int = Str.length;
			return Str.substr(0,RealLength + Length);
		}
			
		public function StrExpressionCompare(First:Number, Second:Number, ComparisonType:int, ReturnIfTrue:String, ReturnIfFalse:String):String
		{
			if (Compare(First,Second,ComparisonType)) return ReturnIfTrue; else return ReturnIfFalse;
		}
		
		public override function expression(num:int):CValue
		{
			var v:CValue = new CValue(0);
			switch(num)
			{
				case 0: v.forceInt(IntGenerateRandom(ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 1: v.forceDouble(GenerateRandom(ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 2: v.forceDouble(Limit(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 3: v.forceString(Substr(ho.getExpParam().getString(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 4: v.forceDouble(Nearest(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 5: v.forceDouble(Normalise(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getInt())); break;
				case 6: v.forceDouble(ModifyRange(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getInt())); break;
				case 7: v.forceDouble(Wave(ho.getExpParam().getInt(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 8: v.forceDouble(EuclideanMod(ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 9: v.forceDouble(UberMod(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 10: v.forceDouble(Interpolate(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getInt())); break;
				case 11: v.forceDouble(Mirror(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 21: v.forceDouble(ExpressionCompare(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getInt(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 12: v.forceInt(IntLimit(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 13: v.forceInt(IntNearest(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 14: v.forceInt(IntNormalise(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 15: v.forceInt(IntModifyRange(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 16: v.forceInt(IntWave(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 17: v.forceInt(IntEuclideanMod(ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 18: v.forceInt(IntUberMod(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 19: v.forceInt(IntInterpolate(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 20: v.forceInt(IntMirror(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 22: v.forceInt(IntExpressionCompare(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;
				case 23: v.forceString(StrExpressionCompare(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getInt(),ho.getExpParam().getString(),ho.getExpParam().getString())); break;
				case 24: v.forceDouble(Approach(ho.getExpParam().getDouble(),ho.getExpParam().getDouble(),ho.getExpParam().getDouble())); break;
				case 25: v.forceInt(IntApproach(ho.getExpParam().getInt(),ho.getExpParam().getInt(),ho.getExpParam().getInt())); break;		
			}
			return v;
		}
		
		/**
		 * set seed with a 31 bit unsigned integer
		 * between 1 and 0X7FFFFFFE inclusive. don't use 0!
		 */
		public var seed:uint;
		
		/**
		 * provides the next pseudorandom number
		 * as an unsigned integer (31 bits)
		 */
		public function nextInt():uint
		{
			return gen();
		}
		
		/**
		 * provides the next pseudorandom number
		 * as a Number between nearly 0 and nearly 1.0.
		 */
		public function nextDouble():Number
		{
			return (gen() / 2147483647);
		}
		
		/**
		 * provides the next pseudorandom number
		 * as an unsigned integer (31 bits) betweeen
		 * a given range.
		 */
		public function nextIntRange(min:Number, max:Number):uint
		{
			min -= .4999;
			max += .4999;
			return Math.round(min + ((max - min) * nextDouble()));
		}
		
		/**
		 * provides the next pseudorandom number
		 * as a Number between a given range.
		 */
		public function nextDoubleRange(min:Number, max:Number):Number
		{
			return min + ((max - min) * nextDouble());
		}
		
		/**
		 * generator:
		 * new-value = (old-value * 16807) mod (2^31 - 1)
		 */
		private function gen():uint
		{
			//integer version 1, for max int 2^46 - 1 or larger.
			return seed = (seed * 16807) % 2147483647;
		}
	}
}