package org.uqbar.project.wollok.game.listeners

import org.uqbar.project.wollok.game.listeners.GameboardListener
import org.uqbar.project.wollok.game.gameboard.Gameboard
import com.google.common.collect.AbstractIterator

class CharacterSayListener implements GameboardListener {
	
	var AbstractIterator<String> text
	var int key
	
	new (int aKey, AbstractIterator<String> aText) {
		key = aKey
		text = aText
	}
	
	override notify(Gameboard gameboard) {
		if (gameboard.isKeyPressed(this.key) && text.hasNext)
			gameboard.characterSay(text.next)
	}
	
}