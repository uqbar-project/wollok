class S {
	method whatIf(x) {
		if (x % 2 == 0)
			"even"
		else
			"odd"
	}
}

program ifs {
	val number = 2
	val oddOrEven = if (number % 2 == 0) "even" else "odd"
	
	this.assert("even" == oddOrEven)
	
	this.assert("odd" == if (3 % 2 == 0) "even" else "odd")
	
	// now in a method
	
	val s = new S()
	
	this.assert("even" == s.whatIf(2))
	this.assert("odd" == s.whatIf(3))
}