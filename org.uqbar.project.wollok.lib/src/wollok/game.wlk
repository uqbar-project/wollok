import wollok.vm.runtime

/**
  * Wollok Game main object 
  */
object game {
	
	/**
	 * Adds an object to the board for drawing it.
	 * Object should understand a position property 
	 * (implemented by a reference or getter method).
	 *
	 * Example:
	 *     game.addVisual(pepita) ==> pepita should have a position property
	 */
	method addVisual(positionable) native

	/**
	 * Adds an object to the board for drawing it on a specific position.
	 *
	 * Example:
	 *     game.addVisualIn(pepita, game.origin()) ==> no need for pepita to have a position property
	 *     game.addVisualIn(pepita, game.at(2, 2))
	 */
	method addVisualIn(element, position) native

	
	/**
	 * Adds an object to the board for drawing it. It can be moved with arrow keys.
	 * That object should understand a position property 
	 * (implemented by a reference or getter method).
	 *
	 * Example:
	 *     game.addVisualCharacter(pepita) ==> pepita should have a position property
	 */
	method addVisualCharacter(positionable) native

	/**
	 * Adds an object to the board for drawing it on a specific position. It can be moved with arrow keys.
	 *
	 * Example:
	 *     game.addVisualCharacterIn(pepita, game.origin()) ==> no need for pepita to have a position property
	 */	
	method addVisualCharacterIn(element, position) native

	/**
	 * Removes an object from the board for stop drawing it.
	 *
	 * Example:
	 *     game.removeVisual(pepita)
	 */
	method removeVisual(visual) native
	
	/**
	 * Verifies if an object is currently in the board.
	 *
	 * Example:
	 *     game.hasVisual(pepita)
	 */
	method hasVisual(visual) native

	/**
	 * Returns all visual objects added to the board.
	 *
	 * Example:
	 *     game.getAllVisuals()
	 */
	method getAllVisuals() native

	/**
	 * Adds a block that will be executed each time a specific key is pressed
	 * @see keyboard.onPressDo()
	 */	
	method whenKeyPressedDo(key, action) native

	/**
	 * Adds a block that will be executed when the given object collides with other. 
	 * Two objects collide when are in the same position.
	 *
	 * The block should expect the other object as parameter.
	 *
	 * Example:
	 *     game.whenCollideDo(pepita, { comida => pepita.comer(comida) })
	 */	
	method whenCollideDo(visual, action) native

	/**
	 * Adds a block with a specific name that will be executed every n milliseconds.
	 * Block expects no argument.
	 * Be careful not to set it too often :)
	 *
	 * Example:
	 *     	game.onTick(5000, "pepitaMoving", { => pepita.position().x(0.randomUpTo(4)) })
	 */
	method onTick(milliseconds, name, action) native
	 
	/**
	 * Remove a tick event created with onTick message
	 *
	 * Example:
	 *      game.removeTickEvent("pepitaMoving")
	 */ 
	method removeTickEvent(name) native
	
	/**
	 * Returns all objects in given position.
	 *
	 * Example:
	 *     game.getObjectsIn(game.origin())
	 */	
	method getObjectsIn(position) native

	/**
	 * Draws a dialog balloon with given message in given visual object position.
	 *
	 * Example:
	 *     game.say(pepita, "hola!")
	 */
	method say(visual, message) native

	/**
	 * Removes all visual objects on board and configurations (colliders, keys, etc).
	 */	
	method clear() native

	/**
	 * Returns all objects that are in same position of given object.
	 */	
	method colliders(visual) native

	/**
	 * Stops render the board and finish the game.
	 */	
	method stop() native
	
	/**
	 * Starts render the board in a new windows.
	 */	
	method start() {
		self.doStart(runtime.isInteractive())
	}
	
	/**
	 * Returns a position for given coordinates.
	 */	
	method at(x, y) {
		return new Position(x = x, y = y)
	}

	/**
	 * Returns the position (0,0).
	 */	
	method origin() = self.at(0, 0)

	/**
	 * Returns the center board position (rounded down).
	 */	
	method center() = self.at(self.width().div(2), self.height().div(2))

	/**
	 * Sets game title.
	 */		
	method title(title) native

	/**
	 * Returns game title.
	 */		
	method title() native
	
	/**
	 * Sets board width (in cells).
	 */			
	method width(width) native

	/**
	 * Returns board width (in cells).
	 */		
	method width() native

	/**
	 * Sets board height (in cells).
	 */			
	method height(height) native

	/**
	 * Returns board height (in cells).
	 */		
	method height() native

	/**
	 * Sets cells background image.
	 */			
	method ground(image) native
	
	/**
	 * Sets full background image.
	 */			
	method boardGround(image) native
	
	/**
	 * Attributes will not show when user mouse over a visual component.
	 * Default behavior is to show them.
	 */
	method hideAttributes(visual) native
	
	/**
	 * Attributes will appear again when user mouse over a visual component.
	 * Default behavior is to show them, so this is not necessary.
	 */
	method showAttributes(visual) native
	
	/**
	 * Allows to configure a visual component as "error reporter".
	 * Then every error in game board will be reported by this visual component,
	 * in a balloon message form.
     */
    method errorReporter(visual) native
     
    /**
	 * Plays once a .mp3, .ogg or .wav audio file
     */ 
    method sound(audioFile) native
    
	/** 
	* @private
	*/
	method doStart(isRepl) native
}

/**
 * Represents a position in a two-dimensional gameboard.
 * It is an immutable object since Wollok 1.8.0
 */
class Position {
	const property x = 0
	const property y = 0
	
	/**
	 * Returns a new Position n steps right from this one.
	 */		
	method right(n) = new Position(x = x + n, y = y)
	
	/**
	 * Returns a new Position n steps left from this one.
	 */		
	method left(n) = new Position(x = x - n, y = y)
	
	/**
	 * Returns a new Position n steps up from this one.
	 */		
	method up(n) = new Position(x = x, y = y + n)
	
	/**
	 * Returns a new Position, n steps down from this one.
	 */		
	method down(n) = new Position(x = x, y = y - n) 

	/**
	 * Adds an object to the board for drawing it in self.
	 */
	method drawElement(element) { game.addVisualIn(element, self) } //TODO: Implement native
	
	/**
	 * Adds an object to the board for drawing it in self. It can be moved with arrow keys.
	 */
	method drawCharacter(element) { game.addVisualCharacterIn(element, self) } //TODO: Implement native

	/**
	 * Draw a dialog balloon with given message in given visual object position.
	 */	
	method say(element, message) { game.say(element, message) } //TODO: Implement native

	/**
	 * Returns all objects in self.
	 */	
	method allElements() = game.getObjectsIn(self) //TODO: Implement native
	
	/**
	 * Returns a new position with same coordinates.
	 */	
	method clone() = new Position(x = x, y = y)

	/**
	 * Returns the distance between given position and self.
	 */	
	method distance(position) {
		self.checkNotNull(position, "distance")
		const deltaX = x - position.x()
		const deltaY = y - position.y()
		return (deltaX.square() + deltaY.square()).squareRoot() 
	}

	/**
	 * Removes all objects in self from the board for stop drawing it.
	 */
	method clear() {
		self.allElements().forEach{it => game.removeVisual(it)}
	}
	
	/**
	 * Two positions are equals if they have same coordinates.
	 */	
	override method ==(other) = x == other.x() && y == other.y()
	
	/**
	 * String representation of a position
	 */
	override method toString() = "(" + x + "," + y + ")"
	
}

/**
 * Keyboard object handles all keys movements. There is a method for each key.
 * 
 * Examples:
 *     keyboard.i().onPressDo { game.say(pepita, "hola!") } 
 *         => when user hits "i" key, pepita will say "hola!"
 *
 *     keyboard.any().onPressDo { game.say(pepita, "you pressed a key!") }
 *         => any key pressed will activate its closure
 */
object keyboard {

	method any() = new Key(keyCodes = [-1])

	method num(n) = new Key(keyCodes = [n + 7, n + 144])
	
	method num0() = self.num(0)

	method num1() = self.num(1)

	method num2() = self.num(2)

	method num3() = self.num(3)

	method num4() = self.num(4)

	method num5() = self.num(5)

	method num6() = self.num(6)

	method num7() = self.num(7)

	method num8() = self.num(8)

	method num9() = self.num(9)

	method a() = new Key(keyCodes = [29])

	method alt() = new Key(keyCodes = [57, 58])

	method b() = new Key(keyCodes = [30])

	method backspace() = new Key(keyCodes = [67])

	method c() = new Key(keyCodes = [31])

	method control() = new Key(keyCodes = [129, 130])

	method d() = new Key(keyCodes = [32])

	method del() = new Key(keyCodes = [67])

	method center() = new Key(keyCodes = [23])

	method down() = new Key(keyCodes = [20])

	method left() = new Key(keyCodes = [21])

	method right() = new Key(keyCodes = [22])

	method up() = new Key(keyCodes = [19])

	method e() = new Key(keyCodes = [33])

	method enter() = new Key(keyCodes = [66])

	method f() = new Key(keyCodes = [34])

	method g() = new Key(keyCodes = [35])

	method h() = new Key(keyCodes = [36])

	method i() = new Key(keyCodes = [37])

	method j() = new Key(keyCodes = [38])

	method k() = new Key(keyCodes = [39])

	method l() = new Key(keyCodes = [40])

	method m() = new Key(keyCodes = [41])

	method minusKey() = new Key(keyCodes = [69])

	method n() = new Key(keyCodes = [42])

	method o() = new Key(keyCodes = [43])

	method p() = new Key(keyCodes = [44])

	method plusKey() = new Key(keyCodes = [81])

	method q() = new Key(keyCodes = [45])

	method r() = new Key(keyCodes = [46])

	method s() = new Key(keyCodes = [47])

	method shift() = new Key(keyCodes = [59, 60])

	method slash() = new Key(keyCodes = [76])

	method space() = new Key(keyCodes = [62])

	method t() = new Key(keyCodes = [48])

	method u() = new Key(keyCodes = [49])

	method v() = new Key(keyCodes = [50])

	method w() = new Key(keyCodes = [51])

	method x() = new Key(keyCodes = [52])

	method y() = new Key(keyCodes = [53])

	method z() = new Key(keyCodes = [54])

}


class Key {	
	const property keyCodes
	
	/**
	 * Adds a block that will be executed always self is pressed.
	 *
	 * Example:
     	 *     keyboard.i().onPressDo { game.say(pepita, "hola!") } 
     	 *         => when user hits "i" key, pepita will say "hola!"
	 */	
	method onPressDo(action) {
		keyCodes.forEach{ key => game.whenKeyPressedDo(key, action) } //TODO: Implement native
	}
}
