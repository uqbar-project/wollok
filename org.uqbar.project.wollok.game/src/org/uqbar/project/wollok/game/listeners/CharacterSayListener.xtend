package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.gameboard.Gameboard

import com.google.common.collect.AbstractIterator

import org.uqbar.project.wollok.game.helpers.Keyboard

class CharacterSayListener implements GameboardListener {
	
	var keyboard = Keyboard.instance
	var AbstractIterator<String> text
	var int key
	
	new (int aKey, AbstractIterator<String> aText) {
		key = aKey
		text = aText
	}
	
	override notify(Gameboard gameboard) {
		if (keyboard.isKeyPressed(this.key) && text.hasNext)
			gameboard.characterSay(text.next)
	}
}