package org.uqbar.project.wollok.typesystem.annotations

import static org.uqbar.project.wollok.typesystem.constraints.variables.EffectStatus.*

class WollokGameTypeDeclarations extends TypeDeclarations {
	
	
	override declarations() {
		Position.variable("x", Number)
		Position.variable("y", Number)
		Position.clear
		Position >> "right" === #[Number] => Position
		Position >> "left" === #[Number] => Position
		Position >> "up" === #[Number] => Position
		Position >> "down" === #[Number] => Position
		Position >> "drawElement" === #[T] => Void(Change)
		Position >> "drawCharacter" === #[T] => Void(Change)
		Position >> "say" === #[T, String] => Void(Change)
		Position >> "allElements" === #[] => List.of(T)
		Position >> "clone" === #[] => Position
		Position >> "distance" === #[Position] => Number
		Position >> "clear" === #[] => Void(Change)
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
		game >> "addVisual" === #[T] => Void(Change)
		game >> "addVisualIn" === #[T, Position] => Void(Change)
		game >> "addVisualCharacter" === #[T] => Void(Change)
		game >> "addVisualCharacterIn" === #[T, Position] => Void(Change)
		game >> "removeVisual" === #[T] => Void(Change)
		game >> "hasVisual" === #[T] => Boolean
		game >> "allVisuals" === #[] => List.of(T)
		game >> "whenKeyPressedDo" === #[Number, closure(#[], Void)] => Void(Change)
		game >> "whenCollideDo" === #[U, closure(#[T], Void)] => Void(Change)
		game >> "onCollideDo" === #[U, closure(#[T], Void)] => Void(Change)
		game >> "onTick" === #[Number, String, closure(#[], Void)] => Void(Change)
		game >> "schedule" === #[Number, closure(#[], Void)] => Void(Change)
		game >> "removeTickEvent" === #[String] => Void(Change)
		game >> "getObjectsIn" === #[Position] => List.of(T)
		game >> "say" === #[T, String] => Void(Change)
		game >> "colliders" === #[U] => List.of(T)
		game >> "uniqueCollider" === #[U] => T
		game >> "stop" === #[] => Void(Change)
		game >> "start" === #[] => Void(Change)
		game >> "doStart" === #[Boolean] => Void(Change)
		game >> "at" === #[Number, Number] => Position
		game >> "origin" === #[] => Position
		game >> "center" === #[] => Position
		game >> "ground" === #[String] => Void(Change)
		game >> "boardGround" === #[String] => Void(Change)
		game >> "cellSize" === #[Number] => Void(Change)
		game >> "doCellSize" === #[Number] => Void(Change)
		game >> "hideAttributes" === #[T] => Void(Change)
		game >> "showAttributes" === #[T] => Void(Change)
		game >> "errorReporter" === #[T] => Void(Change)
		game >> "sound" === #[String] => Sound

		keyboard.allMethods.except("num", "letter", "arrow") === #[] => Key
		keyboard >> "num" === #[Number] => Key
		keyboard >> "letter" === #[String] => Key
		keyboard >> "arrow" === #[String] => Key
		
		Sound.variable("file",String)
		Sound.fakeProperty("volume",Number)
		Sound.fakeProperty("shouldLoop",Boolean)
		Sound >> "play" === #[] => Void(Change)
		Sound >> "played" === #[] => Boolean
		Sound >> "stop" === #[] => Void(Change)
		Sound >> "pause" === #[] => Void(Change)
		Sound >> "paused" === #[] => Boolean
		Sound >> "resume" === #[] => Void(Change)
						
		Key >> "onPressDo" === #[closure(#[], Void)] => Void(Change)
	}
}