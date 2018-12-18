package org.uqbar.project.wollok.typesystem.annotations

class WollokCoreTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Boolean >> "||" === #[Boolean] => Boolean
		Boolean >> "&&" === #[Boolean] => Boolean
		Boolean >> "and" === #[Boolean] => Boolean
		Boolean >> "or" === #[Boolean] => Boolean
		Boolean >> "negate" === #[] => Boolean

		PairType.constructor(PKEY, PVALUE)
		PairType.variable("x", PKEY)
		PairType.variable("y", PVALUE)
		PairType >> "key" === #[] => PKEY;
		PairType >> "value" === #[] => PVALUE;

		// Closure >> "apply" === #[List] => RETURN

		// This must come at last, because of "allTypes"
		// TODO: should include Object type?
		allTypes.forEach[ T |
			(T == Any) => Boolean;
			(T != Any) => Boolean;
			(T === Any) => Boolean;
			(T !== Any) => Boolean;
//			(T -> Any) => PairType; //TODO: generics 
			T >> "equals" === #[Any] => Boolean;
			T >> "toString" === #[] => String;
			T >> "printString" === #[] => String;
			T >> "internalToSmartString" === #[Boolean] => String;
			T >> "simplifiedToSmartString" === #[] => String;
			T >> "kindName" === #[] => String;
			T >> "className" === #[] => String;
			T >> "error" === #[String] => Void;
		]
	}
}
