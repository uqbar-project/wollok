package org.uqbar.project.wollok.tests.game.mock

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.interpreter.core.WollokObject

import static org.mockito.Mockito.*

@Accessors
class VisualComponentMock extends VisualComponent {
	Position _position
	Image image
	List<String> attributes

	new(Position position, Image image) {
		super(mock(WollokObject))
		this._position = position
		this.image = image
	}
	
	override Image getImage() {
		image
	}

	override Position getPosition() {
		_position
	}

	override setPosition(Position position) {
		_position = position
	}
	
}
