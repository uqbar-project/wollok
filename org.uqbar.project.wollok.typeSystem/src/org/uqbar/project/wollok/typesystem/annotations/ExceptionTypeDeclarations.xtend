package org.uqbar.project.wollok.typesystem.annotations

class ExceptionTypeDeclarations extends TypeDeclarations {
	override declarations() {
		ExceptionType.constructor(String)
		ExceptionType >> "getMessage" === #[] => String
		ExceptionType >> "getCause" === #[] => ExceptionType
		ExceptionType >> "equals" === #[ExceptionType] => Boolean
		ExceptionType >> "printStackTrace" === #[] => Void
		ExceptionType >> "getStackTraceAsString" === #[] => String
		ExceptionType >> "getFullStackTrace" === #[] => List.of(String)
		ExceptionType >> "getStackTrace" === #[] => List.of(String)
		ExceptionType >> "createStackTraceElement" === #[String, String] => StackTraceElement
	}
}