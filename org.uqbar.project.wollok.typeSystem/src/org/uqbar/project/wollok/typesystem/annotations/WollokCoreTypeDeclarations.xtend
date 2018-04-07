package org.uqbar.project.wollok.typesystem.annotations

import org.uqbar.project.wollok.typesystem.ConcreteType

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		
		(Object == Any) => Boolean;
		Object >> "toString" === #[] => String;
		Object >> "printString" === #[] => String;

		(Boolean == Any) => Boolean		
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean
		Boolean >> "toString" === #[] => String;

		PairType.constructor(KEY, VALUE)
		PairType >> "key" === #[] => KEY;
		PairType >> "value" === #[] => VALUE;
		
		Number + Number => Number
		Number - Number => Number
		Number * Number => Number
		Number >> "/" === #[Number] => Number
		Number >> "div" === #[Number] => Number
		Number >> "rem" === #[Number] => Number
		Number >> "**" === #[Number] => Number
		Number >> ">" === #[Number] => Boolean
		Number >> "<" === #[Number] => Boolean
		Number >> ">=" === #[Number] => Boolean
		Number >> "<=" === #[Number] => Boolean
		Number / Number => Number
		Number >> "between" === #[Number, Number] => Boolean
		Number % Number => Number
		Number >> "toString" === #[] => String
		Number >> "invert" === #[] => Number
		Number >> "abs" === #[] => Number
		Number >> "limitBetween" === #[Number, Number] => Number
		Number >> ".." === #[Number] => Range
		Number >> "max" === #[Number] => Number
		Number >> "min" === #[Number] => Number
		Number >> "square" === #[] => Number
		Number >> "squareRoot" === #[] => Number
		Number >> "even" === #[] => Boolean
		Number >> "odd" === #[] => Boolean
		Number >> "roundUp" === #[] => Number
		Number >> "roundUp" === #[Number] => Number
		Number >> "truncate" === #[Number] => Number;
		Number >> "randomUpTo" === #[Number] => Number;
		Number >> "gcd" === #[Number] => Number;
		Number >> "lcm" === #[Number] => Number;
		Number >> "digits" === #[] => Number;
		Number >> "isInteger" === #[] => Boolean;
		Number >> "isPrime" === #[] => Boolean;
		Number >> "plus" === #[] => Number;
		Number >> "times" === #[closure(#[], Any)] => Void;
		Number >> "checkNotNull" === #[Any, String] => Void;
		Number >> "simplifiedToSmartString" === #[] => String;
		Number >> "internalToSmartString" === #[Boolean] => String;
		Number >> "coerceToInteger" === #[] => Number;

		(String == Any) => Boolean
		String >> "length" === #[] => Number
		String >> "size" === #[] => Number
		String >> "charAt" === #[Number] => String
		String >> "startsWith" === #[String] => Boolean
		String >> "endsWith" === #[String] => Boolean
		String >> "indexOf" === #[String] => Number
		String >> "lastIndexOf" === #[String] => Number
		String >> "toUpperCase" === #[] => String
		String >> "trim" === #[] => String
		String >> "contains" === #[String] => Boolean
		String >> "isEmpty" === #[] => Boolean
		String >> "substring" === #[Number] => String
		String >> "substring" === #[Number, Number] => String
		String >> "split" === #[String] => List
		String >> "equalsIgnoreCase" === #[String] => Boolean
		String >> "printString" === #[] => String
		String >> "toString" === #[] => String
		String >> "replace" === #[String, String] => String
		String + String => String;
		(String > String) => Boolean
		String >> "take" === #[Number] => String
		String >> "drop" === #[Number] => String
		String >> "words" === #[] => List
		String >> "capitalize" === #[] => String

		ExceptionType >> "getMessage" === #[] => String
		ExceptionType >> "getCause" === #[] => ExceptionType
		ExceptionType >> "equals" === #[ExceptionType] => Boolean
		ExceptionType >> "printStackTrace" === #[] => Void
		ExceptionType >> "getStackTraceAsString" === #[] => String
		ExceptionType >> "getFullStackTrace" === #[] => List
		ExceptionType >> "getStackTrace" === #[] => List
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement
		
		Collection >> "add" === #[ELEMENT] => Void
		Collection + Collection => Collection;

		(List == Any) => Boolean
		List + List => List
		List >> "add" === #[ELEMENT] => Void
		List >> "contains" === #[ELEMENT] => Boolean
		List >> "first" === #[] => ELEMENT
		List >> "size" === #[] => Number
		List >> "sum" === #[closure(#[ELEMENT], Number)] => Number
		
		Range >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
		 
		(Set == Any) => Boolean
		Set + Set => Set;
		Set >> "add" === #[ELEMENT] => Void
		Set >> "contains" === #[ELEMENT] => Boolean
		Set >> "sum" === #[closure(#[ELEMENT], Number)] => Number;
		
		Date.constructor(Number, Number, Number)
		(Date == Date) => Boolean
		Date - Date => Number
		Date >> "initialize" === #[Number, Number, Number] => Void
		Date >> "plusDays" === #[Number] => Date
		Date >> "plusMonths" === #[Number] => Date
		Date >> "plusYears" === #[Number] => Date
		Date >> "isLeapYear" === #[] => Boolean
		Date >> "day" === #[] => Number
		Date >> "dayOfWeek" === #[] => Number
		Date >> "month" === #[] => Number
		Date >> "year" === #[] => Number
		Date >> "minusDays" === #[Number] => Date
		Date >> "minusMonths" === #[Number] => Date
		Date >> "minusYears" === #[Number] => Date
		Date >> "between" === #[Date, Date] => Boolean
		Date >> "toSmartString" === #[Boolean] => String;
		
		Position.constructor(Number, Number)
		(Position == Any) => Boolean;
//		Position >> "x" === #[] => Number
//		Position >> "y" === #[] => Number
		Position >> "moveRight" === #[Number] => Void
		Position >> "moveLeft" === #[Number] => Void
		Position >> "moveUp" === #[Number] => Void
		Position >> "moveDown" === #[Number] => Void
		Position >> "drawElement" === #[Any] => Void
		Position >> "drawCharacter" === #[Any] => Void
		Position >> "deleteElement" === #[Any] => Void
		Position >> "say" === #[Any, String] => Void
		Position >> "allElements" === #[] => List
		Position >> "clone" === #[] => Position
		Position >> "distance" === #[Position] => Number
		Position >> "clear" === #[] => Void
		Position >> "toString" === #[] => String;
		

		// console
		console >> "println" === #[Any] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Number
		console >> "newline" === #[] => Void

		assertWKO >> "that" === #[Boolean] => Void
		assertWKO >> "notThat" === #[Boolean] => Void
		assertWKO >> "equals" === #[Any, Any] => Void
		assertWKO >> "notEquals" === #[Any, Any] => Void
		// TODO: Uncomment these definitions when solving closure parameters
		//assertWKO >> "throwsException" === #[closure(#[], Any)] => Void
		//assertWKO >> "throwsExceptionLike" === #[ExceptionType, closure(#[], Any)] => Void
		//assertWKO >> "throwsExceptionWithMessage" === #[String, closure(#[], Any)] => Void
		//assertWKO >> "throwsExceptionWithType" === #[ExceptionType, closure(#[], Any)] => Void
		//assertWKO >> "throwsExceptionByComparing" === #[closure(#[], Any), closure(#[Any], Boolean)] => Void
		assertWKO >> "fail" === #[String] => Void;

		game.property("title", String)
		game.property("width", Number)
		game.property("height", Number)
		game >> "addVisual" === #[Any] => Void
		game >> "addVisualIn" === #[Any, Position] => Void
		game >> "addVisualCharacter" === #[Any] => Void
		game >> "addVisualCharacterIn" === #[Any, Position] => Void
		game >> "removeVisual" === #[Any] => Void
//		game >> "whenKeyPressedDo" === #[Number, closure(#[], Void)] => Void
//		game >> "whenCollideDo" === #[Any, closure(#[Any], Void)] => Void
		game >> "getObjectsIn" === #[Position] => List
		game >> "say" === #[Any, String] => Void
		game >> "clear" === #[] => Void
		game >> "colliders" === #[Any] => List
		game >> "stop" === #[] => Void
		game >> "start" === #[] => Void
		game >> "at" === #[Number, Number] => Position
		game >> "origin" === #[] => Position
		game >> "center" === #[] => Position
		game >> "ground" === #[String] => Void
		game >> "boardGround" === #[String] => Void;
		
		comparable(Number, String, Date)
		
		Closure >> "apply" === #[List] => RETURN
		
		InstanceVariableMirror >> "value" === #[] => Void
	}
	
	def comparable(SimpleTypeAnnotation<? extends ConcreteType>... types) {
		types.forEach[ T |
			(T > T) => Boolean;
			(T < T) => Boolean;
			(T <= T) => Boolean;
			(T >= T) => Boolean;
			(T === T) => Boolean;
		]
	}
	
	def property(SimpleTypeAnnotation<? extends ConcreteType> it, String property, SimpleTypeAnnotation<? extends ConcreteType> type) {
		it >> property === #[type] => Void
		it >> property === #[] => type
	}
}
