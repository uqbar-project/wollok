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
	 *     game.addVisual(pepita, game.origin()) ==> no need for pepita to have a position property
	 *     game.addVisual(pepita, game.at(2, 2))
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
		return new Position(x, y)
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
	const property x
	const property y
	
	/**
	 * Returns the position at origin: (0,0).
	 */		
	constructor() = self(0, 0)
			
	/**
	 * Returns a position with given x and y coordinates.
	 * From now on, position is immutable.
	 */	
	constructor(_x, _y) {
		x = _x
		y = _y
	}
	
	/**
	 * Returns a new Position n steps right from this one.
	 */		
	method right(n) = new Position(x + n, y)
	
	/**
	 * Returns a new Position n steps left from this one.
	 */		
	method left(n) = new Position(x - n, y)
	
	/**
	 * Returns a new Position n steps up from this one.
	 */		
	method up(n) = new Position(x, y + n)
	
	/**
	 * Returns a new Position, n steps down from this one.
	 */		
	method down(n) = new Position(x, y - n) 

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
	method clone() = new Position(x, y)

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

	method any() = new Key(-1)

	method num(n) = new Key(n + 7, n + 144)
	
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

	method a() = new Key(29)

	method alt() = new Key(57, 58)

	method b() = new Key(30)

	method backspace() = new Key(67)

	method c() = new Key(31)

	method control() = new Key(129, 130)

	method d() = new Key(32)

	method del() = new Key(67)

	method center() = new Key(23)

	method down() = new Key(20)

	method left() = new Key(21)

	method right() = new Key(22)

	method up() = new Key(19)

	method e() = new Key(33)

	method enter() = new Key(66)

	method f() = new Key(34)

	method g() = new Key(35)

	method h() = new Key(36)

	method i() = new Key(37)

	method j() = new Key(38)

	method k() = new Key(39)

	method l() = new Key(40)

	method m() = new Key(41)

	method minusKey() = new Key(69)

	method n() = new Key(42)

	method o() = new Key(43)

	method p() = new Key(44)

	method plusKey() = new Key(81)

	method q() = new Key(45)

	method r() = new Key(46)

	method s() = new Key(47)

	method shift() = new Key(59, 60)

	method slash() = new Key(76)

	method space() = new Key(62)

	method t() = new Key(48)

	method u() = new Key(49)

	method v() = new Key(50)

	method w() = new Key(51)

	method x() = new Key(52)

	method y() = new Key(53)

	method z() = new Key(54)

}


class Key {	
	var keyCodes
	
	constructor(_keyCodes...) {
		keyCodes = _keyCodes
	}

	/**
	 * Adds a block that will be executed always self is pressed.
	 *
	 * Examples:
     *     keyboard.i().onPressDo { game.say(pepita, "hola!") } 
     *         => when user hits "i" key, pepita will say "hola!"
	 */	
	method onPressDo(action) {
		keyCodes.forEach{ key => game.whenKeyPressedDo(key, action) } //TODO: Implement native
	}
}
