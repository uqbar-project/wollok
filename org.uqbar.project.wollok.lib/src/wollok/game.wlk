object keyboard {

	method any() = new Key(-1)

	method num0() = new Key(7, 144)

	method num1() = new Key(8, 145)

	method num2() = new Key(9, 146)

	method num3() = new Key(10, 147)

	method num4() = new Key(11, 148)

	method num5() = new Key(12, 149)

	method num6() = new Key(13, 150)

	method num7() = new Key(14, 151)

	method num8() = new Key(15, 152)

	method num9() = new Key(16, 153)

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

	method minus() = new Key(69)

	method n() = new Key(42)

	method o() = new Key(43)

	method p() = new Key(44)

	method plus() = new Key(81)

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
	 */	
	method onPressDo(action) {
		keyCodes.forEach{ key => game.whenKeyPressedDo(key, action) } //TODO: Implement native
	}
}
