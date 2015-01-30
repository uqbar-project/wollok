package warriors {
	class Warrior {
		var collectedPoints = 0
	
		method takeGem(aGem) {
			collectedPoints = collectedPoints + aGem.getPoints()
		}
	}
	
	class Gem {
		var points
		var color
		new(c, p) {
			color = c
			points = p
		}
		method getColor() {
			color
		}
		method getPoints() {
			points
		}
	}
}