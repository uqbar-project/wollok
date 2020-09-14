package org.uqbar.project.wollok.typesystem.annotations

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*

class ExceptionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		ExceptionType.variable("message", String)
		ExceptionType.variable("cause", ExceptionType)
		ExceptionType >> "printStackTrace" === #[] => Void(Change)
		ExceptionType >> "getStackTraceAsString" === #[] => String
		ExceptionType >> "getFullStackTrace" === #[] => List.of(String)
		ExceptionType >> "getStackTrace" === #[] => List.of(String)
		/* privates */
		ExceptionType >> "printStackTrace" === #[unionType(console, StringPrinter)] => Void(Change)
		ExceptionType >> "printStackTraceWithPrefix" === #[String, unionType(console, StringPrinter)] => Void(Change)
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement
		
		
		StackTraceElement.variable("contextDescription", String)
		StackTraceElement.variable("location", String)
	}
}