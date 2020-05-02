package org.uqbar.project.wollok.typesystem.annotations

class WollokLibTypeDeclarations extends TypeDeclarations {
	override declarations() {
		console >> "println" === #[T] => Void
		console >> "readLine" === #[] => String
		console >> "readInt" === #[] => Number
		console >> "newline" === #[] => String

		assertWKO >> "that" === #[Boolean] => Void
		assertWKO >> "notThat" === #[Boolean] => Void
		assertWKO >> "equals" === #[T, T] => Void
		assertWKO >> "notEquals" === #[T, T] => Void
		assertWKO >> "throwsException" === #[closure(#[], T)] => Void
		assertWKO >> "throwsExceptionLike" === #[ExceptionType, closure(#[], T)] => Void
		assertWKO >> "throwsExceptionWithMessage" === #[String, closure(#[], T)] => Void
		assertWKO >> "throwsExceptionWithType" === #[ExceptionType, closure(#[], T)] => Void
		assertWKO >> "throwsExceptionByComparing" === #[closure(#[], T), closure(#[ExceptionType], Boolean)] => Void
		assertWKO >> "fail" === #[String] => Void;

		InstanceVariableMirror.variable("target", Object)
		InstanceVariableMirror.variable("name", String)
		InstanceVariableMirror >> "value" === #[] => T //TODO: should return variable type
		InstanceVariableMirror >> "valueToString" === #[] => String

		ObjectMirror >> "resolve" === #[String] => T
		ObjectMirror >> "instanceVariableFor" === #[String] => InstanceVariableMirror
		ObjectMirror >> "instanceVariables" === #[] => List.of(InstanceVariableMirror)

		StringPrinter >> "println" === #[T] => Void
		StringPrinter >> "getBuffer" === #[] => String
		
		runtime >> "isInteractive" === #[] => Boolean
	}
}
