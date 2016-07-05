class Key {	
	var keyCodes
	
	constructor(_keyCodes) {
		keyCodes = _keyCodes
	}

	method onPressDo(action) {
		keyCodes.forEach{ key => wgame.whenKeyPressedDo(key, action) }
	}
	
	method onPressCharacterSay(function) {
		keyCodes.forEach{ key => wgame.whenKeyPressedSay(key, function) }
	}
}

object ANY_KEY inherits Key([-1]) { }

object NUM_0 inherits Key([7, 144]) { }

object NUM_1 inherits Key([8, 145]) { }

object NUM_2 inherits Key([9, 146]) { }

object NUM_3 inherits Key([10, 147]) { }

object NUM_4 inherits Key([11, 148]) { }

object NUM_5 inherits Key([12, 149]) { }

object NUM_6 inherits Key([13, 150]) { }

object NUM_7 inherits Key([14, 151]) { }

object NUM_8 inherits Key([15, 152]) { }

object NUM_9 inherits Key([16, 153]) { }

object A inherits Key([29]) { }

object ALT inherits Key([57, 58]) { }
	
object B inherits Key([30]) { }

object BACKSPACE inherits Key([67]) { }
	
object C inherits Key([31]) { }
  
object CONTROL inherits Key([129, 130]) { }
  
object D inherits Key([32]) { }
	
object DEL inherits Key([67]) { }
  
object CENTER inherits Key([23]) { }
	
object DOWN inherits Key([20]) { }
	
object LEFT inherits Key([21]) { }
	
object RIGHT inherits Key([22]) { }
	
object UP inherits Key([19]) { }

object E inherits Key([33]) { }

object ENTER inherits Key([66]) { }
	
object F inherits Key([34]) { }

object G inherits Key([35]) { }

object H inherits Key([36]) { }

object I inherits Key([37]) { }

object J inherits Key([38]) { }

object K inherits Key([39]) { }
	
object L inherits Key([40]) { }

object M inherits Key([41]) { }

object MINUS inherits Key([69]) { }

object N inherits Key([42]) { }

object O inherits Key([43]) { }

object P inherits Key([44]) { }

object PLUS inherits Key([81]) { }

object Q inherits Key([45]) { }

object R inherits Key([46]) { }

object S inherits Key([47]) { }

object SHIFT inherits Key([59, 60]) { }
	
object SLASH inherits Key([76]) { }

object SPACE inherits Key([62]) { }

object T inherits Key([48]) { }

object U inherits Key([49]) { }

object V inherits Key([50]) { }

object W inherits Key([51]) { }

object X inherits Key([52]) { }

object Y inherits Key([53]) { }

object Z inherits Key([54]) { }