package org.uqbar.project.wollok.game.listeners

import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.gameboard.Gameboard
import org.uqbar.project.wollok.game.helpers.Keyboard

@Accessors(PUBLIC_GETTER)
class KeyboardListener extends GameboardListener {

	var keyboard = Keyboard.instance
	String keyCode
	Runnable gameAction

	new(String keyCode, Runnable gameAction) {
		this.keyCode = keyCode
		this.gameAction = gameAction
	}

	override notify(Gameboard gameboard) {
		if (keyCode.toKeys.exists[keyboard.isKeyPressed(it)])
			gameAction.run()
	}

	override isObserving(VisualComponent component) {
		false
	}

	def toKeys(String wollokKeycode) {
		newHashMap(
			"ANY" -> newArrayList(-1),
			"Digit0" -> newArrayList(7, 114),
			"Digit1" -> newArrayList(8, 115),
			"Digit2" -> newArrayList(9, 116),
			"Digit3" -> newArrayList(10, 117),
			"Digit4" -> newArrayList(11, 118),
			"Digit5" -> newArrayList(12, 119),
			"Digit6" -> newArrayList(13, 120),
			"Digit7" -> newArrayList(14, 121),
			"Digit8" -> newArrayList(15, 122),
			"Digit9" -> newArrayList(16, 123),
			"KeyA" -> newArrayList(29),
			"KeyB" -> newArrayList(30),
			"KeyC" -> newArrayList(31),
			"KeyD" -> newArrayList(32),
			"KeyE" -> newArrayList(33),
			"KeyF" -> newArrayList(34),
			"KeyG" -> newArrayList(35),
			"KeyH" -> newArrayList(36),
			"KeyI" -> newArrayList(37),
			"KeyJ" -> newArrayList(38),
			"KeyK" -> newArrayList(39),
			"KeyL" -> newArrayList(40),
			"KeyM" -> newArrayList(41),
			"KeyN" -> newArrayList(42),
			"KeyO" -> newArrayList(43),
			"KeyP" -> newArrayList(44),
			"KeyQ" -> newArrayList(45),
			"KeyR" -> newArrayList(46),
			"KeyS" -> newArrayList(47),
			"KeyT" -> newArrayList(48),
			"KeyU" -> newArrayList(49),
			"KeyV" -> newArrayList(50),
			"KeyW" -> newArrayList(51),
			"KeyX" -> newArrayList(52),
			"KeyY" -> newArrayList(53),
			"KeyZ" -> newArrayList(54),
			"ArrowCenter" -> newArrayList(23),
			"ArrowDown" -> newArrayList(20),
			"ArrowLeft" -> newArrayList(21),
			"ArrowRight" -> newArrayList(22),
			"ArrowUp" -> newArrayList(19),
			"AltLeft" -> newArrayList(57),
			"AltRight" -> newArrayList(58),
			"Backspace" -> newArrayList(67),
			"Control" -> newArrayList(129, 130),
			"Delete" -> newArrayList(67),
			"Enter" -> newArrayList(66),
			"Minus" -> newArrayList(69),
			"Plus" -> newArrayList(81),
			"Shift" -> newArrayList(59, 60),
			"Slash" -> newArrayList(76),
			"Space" -> newArrayList(62)
		).get(wollokKeycode)
	}
}
