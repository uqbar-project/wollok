	object console {
		method println(obj) native
		method readLine() native
		method readInt() native
	}
	
	object assert {
		method that(value) native
		method notThat(value) native
		method equals(expected, actual) native
		method notEquals(expected, actual) native
		method throwsException(block) native
		method fail(message) native
	}
	
	class StringPrinter {
		var buffer = ""
		method println(obj) {
			buffer += obj.toString() + "\n"
		}
		method getBuffer() = buffer
	}	
	
	object wgame {
		method addVisual(element) native
		method addVisualIn(element, position) native
		method addVisualCharacter(element) native
		method addVisualCharacterIn(element, position) native
		method removeVisual(element) native
		method whenKeyPressedDo(key, action) native
		method whenKeyPressedSay(key, function) native
		method whenCollideDo(element, action) native
		method getObjectsIn(position) native
		method say(element, message) native
		method clear() native
		method start() native
		method stop() native
		
		method setTitle(title) native
		method getTitle() native
		method setWidth(width) native
		method getWidth() native
		method setHeight(height) native
		method getHeight() native
		method setGround(image) native
	}
	
	class Position {
		var x = 0
		var y = 0
		
		constructor() { }		
				
		constructor(_x, _y) {
			x = _x
			y = _y
		}
		
		method moveRight(num) { x += num }
		method moveLeft(num) { x -= num }
		method moveUp(num) { y += num }
		method moveDown(num) { y -= num }
	
		method drawElement(element) { wgame.addVisualIn(element, self) }
		method drawCharacter(element) { wgame.addVisualCharacterIn(element, self) }		
		method deleteElement(element) { wgame.removeVisual(element) }
		method say(element, message) { wgame.say(element, message) }
		method allElements() = wgame.getObjectsIn(self)
		
		method clone() = new Position(x, y)

		method clear() {
			self.allElements().forEach{it => wgame.removeVisual(it)}
		}
		
		method getX() = x
		method setX(_x) { x = _x }
		method getY() = y
		method setY(_y) { y = _y }
	}
