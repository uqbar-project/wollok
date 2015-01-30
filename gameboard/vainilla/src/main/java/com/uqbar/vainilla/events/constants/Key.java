package com.uqbar.vainilla.events.constants;

import java.util.HashMap;
import java.util.Map;

// TODO: LEFT_SHIFT(), RIGHT_SHIFT, ALT, ALT_GR, etc... e.getLocation()
// TODO: NO ES ALTISIMAMENTE CHOTO TENER ESTO ASI? QUE PASA CON LOS OTROS TIPOS DE TECLADO? QUIERO MANEJARLO DE OTRA FORMA?
// TODO: TECLADO NUMERICO
// TODO?: ALPHANUMERIC, ALPHABETIC, NUMERIC, ARROWS
public enum Key {
	A(65), B(66), C(67), D(68), E(69), F(70), G(71), H(72), I(73), J(74), K(75), L(76), M(77), N(78), Ñ(209), //
	O(79), P(80), Q(81), R(82), S(83), T(84), U(85), V(86), W(87), X(88), Y(89), Z(90), //
	ZERO(48), ONE(49), TWO(50), THREE(51), FOUR(52), FIVE(53), SIX(54), SEVEN(55), EIGHT(56), NINE(57), //
	OPEN_BRACKET(161), CLOSE_BRACKET(162), COMMA(44), DOT(46), MINUS(45), PLUS(521), ACCENT(129), QUOTE(222), //
	BACKSPACE(8), TAB(9), ENTER(10), ESC(27), SPACE(32), SHIFT(16), CTRL(17), ALT(18), //
	F1(112), F2(113), F3(114), F4(115), F5(116), F6(117), F7(118), F8(119), F9(120), F10(121), F11(122), F12(123), //
	INSERT(155), SUPR(127), PAUSE(19), PGUP(33), PGDN(34), //
	LEFT(37), UP(38), RIGHT(39), DOWN(40), //
	ANY(0);

	private static final Map<Integer, Key> EQUIVALENCES = new HashMap<Integer, Key>() {
		{
			for (Key key : Key.values()) {
				this.put(key.getKeyCode(), key);
			}
		}
	};

	private int keyCode;

	// ****************************************************************
	// ** STATICS
	// ****************************************************************

	public static Key fromKeyCode(int code) {
		return EQUIVALENCES.containsKey(code) ? EQUIVALENCES.get(code) : ANY;
	}

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	private Key(int keyCode) {
		this.setKeyCode(keyCode);
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	public int getKeyCode() {
		return this.keyCode;
	};

	private void setKeyCode(int keyCode) {
		this.keyCode = keyCode;
	}
}