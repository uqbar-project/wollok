package org.uqbar.project.wollok.typesystem.annotations

class WollokGameTypeDeclarations extends TypeDeclarations {
	override declarations() {
		Position.constructor(Number, Number)
		Position.variable("x", Number)
		Position.variable("y", Number)
		Position.clear
		Position >> "validateX" === #[] => Void
		Position >> "validateY" === #[] => Void
		Position >> "moveRight" === #[Number] => Void
		Position >> "moveLeft" === #[Number] => Void
		Position >> "moveUp" === #[Number] => Void
		Position >> "moveDown" === #[Number] => Void
		Position >> "right" === #[Number] => Position
		Position >> "left" === #[Number] => Position
		Position >> "up" === #[Number] => Position
		Position >> "down" === #[Number] => Position
		Position >> "drawElement" === #[Any] => Void
		Position >> "drawCharacter" === #[Any] => Void
		Position >> "deleteElement" === #[Any] => Void
		Position >> "say" === #[Any, String] => Void
		Position >> "allElements" === #[] => List.of(Any)
		Position >> "clone" === #[] => Position
		Position >> "distance" === #[Position] => Number
		Position >> "toString" === #[] => String

		// TODO: getter and setters are implemented because native implementations exist
		game.fakeProperty("title", String)
		game.fakeProperty("width", Number)
		game.fakeProperty("height", Number)
		game.clear
		game >> "addVisual" === #[Any] => Void
		game >> "addVisualIn" === #[Any, Position] => Void
		game >> "addVisualCharacter" === #[Any] => Void
		game >> "addVisualCharacterIn" === #[Any, Position] => Void
		game >> "removeVisual" === #[Any] => Void
		game >> "whenKeyPressedDo" === #[Number, closure(#[], Void)] => Void
		game >> "whenCollideDo" === #[Any, closure(#[Any], Void)] => Void
		game >> "onTick" === #[Number, closure(#[], Void)] => Void
		game >> "getObjectsIn" === #[Position] => List.of(Any)
		game >> "say" === #[Any, String] => Void
		game >> "colliders" === #[Any] => List.of(Any)
		game >> "stop" === #[] => Void
		game >> "start" === #[] => Void
		game >> "at" === #[Number, Number] => Position
		game >> "origin" === #[] => Position
		game >> "center" === #[] => Position
		game >> "ground" === #[String] => Void
		game >> "boardGround" === #[String] => Void
		game >> "hideAttributes" === #[Any] => Void
		game >> "showAttributes" === #[Any] => Void
		game >> "errorReporter" === #[Any] => Void

		keyboard.allMethods === #[] => Key
		keyboard >> "num" === #[Number] => Key

		Key >> "onPressDo" === #[closure(#[], Void)] => Void
	}
}