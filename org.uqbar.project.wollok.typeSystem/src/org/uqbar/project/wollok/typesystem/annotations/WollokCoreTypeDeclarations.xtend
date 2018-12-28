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
		// TODO1: should include Object type?
		// TODO2: should only be declared for Object?
		allTypes.forEach[ T |
			(T == Any) => Boolean;
			(T != Any) => Boolean;
			(T === Any) => Boolean;
			(T !== Any) => Boolean;
//			(T -> Any) => PairType; //TODO: generics
			T >> "identity" === #[] => Number; 
			T >> "equals" === #[Any] => Boolean;
			T >> "toString" === #[] => String;
			T >> "printString" === #[] => String;
			T >> "kindName" === #[] => String;
			T >> "className" === #[] => String;
			T >> "error" === #[String] => Void;
			/* privates */
			T >> "toSmartString" === #[List.of(Object)] => String
			T >> "internalToSmartString" === #[List.of(Object)] => String
			T >> "simplifiedToSmartString" === #[] => String
			T >> "messageNotUnderstood" === #[String, List.of(Object)] => Void
			T >> "generateDoesNotUnderstandMessage" === #[String, String, Number] => String
			/* introspection */
			T >> "instanceVariables" === #[] => List.of(InstanceVariableMirror)
			T >> "instanceVariableFor" === #[String] => InstanceVariableMirror
			T >> "resolve" === #[String] => Any //TODO: should return variable type
		]
	}
}
