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

		// Closure >> "apply" === #[List] => RETURN //TODO: VarArgs

		// This must come at last, because of "allTypes"
		// TODO1: should include Object type?
		// TODO2: should only be declared for Object?
		allTypes.forEach[ O |
			(O == Any) => Boolean;
			(O != Any) => Boolean;
			(O === Any) => Boolean;
			(O !== Any) => Boolean;
			(O -> T) => PairType.instance(#{PKEY.paramName -> O, PVALUE.paramName -> T});
			O >> "identity" === #[] => Number; 
			O >> "equals" === #[Any] => Boolean;
			O >> "toString" === #[] => String;
			O >> "printString" === #[] => String;
			O >> "shortDescription" === #[] => String;
			O >> "kindName" === #[] => String;
			O >> "className" === #[] => String;
			O >> "error" === #[String] => Void;
			/* privates */
			O >> "toSmartString" === #[List.of(Object)] => String
			O >> "internalToSmartString" === #[List.of(Object)] => String
			O >> "simplifiedToSmartString" === #[] => String
			O >> "messageNotUnderstood" === #[String, List.of(Object)] => Void
			O >> "generateDoesNotUnderstandMessage" === #[String, String, Number] => String
			/* introspection */
			O >> "instanceVariables" === #[] => List.of(InstanceVariableMirror)
			O >> "instanceVariableFor" === #[String] => InstanceVariableMirror
			O >> "resolve" === #[String] => Any //TODO: should return variable type
		]
	}
}
