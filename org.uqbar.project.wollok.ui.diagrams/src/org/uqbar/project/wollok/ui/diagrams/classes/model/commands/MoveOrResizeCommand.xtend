package org.uqbar.project.wollok.ui.diagrams.classes.model.commands;

import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.commands.Command
import org.eclipse.gef.requests.ChangeBoundsRequest
import org.uqbar.project.wollok.ui.diagrams.classes.model.Shape

import static org.eclipse.gef.RequestConstants.*

/**
 * @author jfernandes
 */
class MoveOrResizeCommand extends Command {
	private final Rectangle newBounds;
	private Rectangle oldBounds;
	private final ChangeBoundsRequest request;
	private final Shape shape;

	new(Shape shape, ChangeBoundsRequest req, Rectangle newBounds) {
		if (shape == null || req == null || newBounds == null)
			throw new IllegalArgumentException
		this.shape = shape
		this.request = req
		this.newBounds = newBounds.copy
		label = "move / resize"
	}

	override canExecute() {
		val type = request.getType
		return REQ_MOVE == type || REQ_MOVE_CHILDREN == type || REQ_RESIZE == type || REQ_RESIZE_CHILDREN == type
	}

	override execute() {
		oldBounds = new Rectangle(shape.location, shape.size)
		redo
	}

	override redo() {
		shape.size = newBounds.size
		shape.location = newBounds.location
	}

	override undo() {
		shape.size = oldBounds.size
		shape.setLocation = oldBounds.location
	}
}
