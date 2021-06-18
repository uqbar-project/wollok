package org.uqbar.project.wollok.typesystem.annotations

class ExceptionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		ExceptionType.variable("message", String)
		ExceptionType.variable("cause", ExceptionType)
		ExceptionType >> "printStackTrace" === #[] => Void
		ExceptionType >> "getStackTraceAsString" === #[] => String
		ExceptionType >> "getFullStackTrace" === #[] => List.of(String)
		ExceptionType >> "getStackTrace" === #[] => List.of(String)
		/* privates */
		ExceptionType >> "printStackTrace" === #[unionType(console, StringPrinter)] => Void
		ExceptionType >> "printStackTraceWithPrefix" === #[String, unionType(console, StringPrinter)] => Void
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement
		
		StackTraceElement.variable("contextDescription", String)
		StackTraceElement.variable("location", String)
	}
}