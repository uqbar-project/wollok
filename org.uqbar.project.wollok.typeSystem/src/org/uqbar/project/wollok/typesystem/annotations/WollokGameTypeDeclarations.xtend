package org.uqbar.project.wollok.typesystem.annotations

class WollokGameTypeDeclarations extends TypeDeclarations {
	
	
	override declarations() {
		Position.variable("x", Number)
		Position.variable("y", Number)
		Position.clear
		Position >> "right" === #[Number] => Position
		Position >> "left" === #[Number] => Position
		Position >> "up" === #[Number] => Position
		Position >> "down" === #[Number] => Position
		Position >> "drawElement" === #[T] => Void
		Position >> "drawCharacter" === #[T] => Void
		Position >> "say" === #[T, String] => Void
		Position >> "allElements" === #[] => List.of(T)
		Position >> "clone" === #[] => Position
		Position >> "distance" === #[Position] => Number
		Position >> "clear" === #[] => Void
		Position >> "up" === #[Number] => Position
		Position >> "down" === #[Number] => Position
		Position >> "left" === #[Number] => Position
		Position >> "right" === #[Number] => Position
		Position >> "toString" === #[] => String

		// TODO: getter and setters are implemented because native implementations exist
		game.fakeProperty("title", String)
		game.fakeProperty("width", Number)
		game.fakeProperty("height", Number)
		game.clear
		game >> "addVisual" === #[T] => Void
		game >> "addVisualIn" === #[T, Position] => Void
		game >> "addVisualCharacter" === #[T] => Void
		game >> "addVisualCharacterIn" === #[T, Position] => Void
		game >> "removeVisual" === #[T] => Void
		game >> "hasVisual" === #[T] => Boolean
		game >> "allVisuals" === #[] => List.of(T)
		game >> "whenKeyPressedDo" === #[Number, closure(#[], Void)] => Void
		game >> "whenCollideDo" === #[U, closure(#[T], Void)] => Void
		game >> "onCollideDo" === #[U, closure(#[T], Void)] => Void
		game >> "onTick" === #[Number, String, closure(#[], Void)] => Void
		game >> "schedule" === #[Number, closure(#[], Void)] => Void
		game >> "removeTickEvent" === #[String] => Void
		game >> "getObjectsIn" === #[Position] => List.of(T)
		game >> "say" === #[T, String] => Void
		game >> "colliders" === #[U] => List.of(T)
		game >> "uniqueCollider" === #[U] => T
		game >> "stop" === #[] => Void
		game >> "start" === #[] => Void
		game >> "doStart" === #[Boolean] => Void
		game >> "at" === #[Number, Number] => Position
		game >> "origin" === #[] => Position
		game >> "center" === #[] => Position
		game >> "ground" === #[String] => Void
		game >> "boardGround" === #[String] => Void
		game >> "hideAttributes" === #[T] => Void
		game >> "showAttributes" === #[T] => Void
		game >> "errorReporter" === #[T] => Void
		game >> "sound" === #[String] => Sound

		keyboard.allMethods.except("num") === #[] => Key
		keyboard >> "num" === #[Number] => Key
		
		Sound.variable("file",String)
		Sound.fakeProperty("volume",Number)
		Sound.fakeProperty("shouldLoop",Boolean)
		Sound >> "play" === #[] => Void
		Sound >> "played" === #[] => Boolean
		Sound >> "stop" === #[] => Void
		Sound >> "pause" === #[] => Void
		Sound >> "isPaused" === #[] => Boolean
		Sound >> "resume" === #[] => Void
						
		Key >> "onPressDo" === #[closure(#[], Void)] => Void
	}
}