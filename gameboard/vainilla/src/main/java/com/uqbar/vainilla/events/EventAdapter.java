package com.uqbar.vainilla.events;

import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.geom.Point2D;
import com.uqbar.vainilla.Game;
import com.uqbar.vainilla.events.constants.Key;
import com.uqbar.vainilla.events.constants.MouseButton;

public class EventAdapter implements MouseMotionListener, MouseListener, KeyListener {

	private Game game;

	// ****************************************************************
	// ** CONSTRUCTORS
	// ****************************************************************

	public EventAdapter(Game game) {
		this.setGame(game);
	}

	// ****************************************************************
	// ** EVENT HANDLING
	// ****************************************************************

	@Override
	public void mouseDragged(MouseEvent e) {
		this.getGame().pushEvent(new MouseMovedEvent(new Point2D.Double(e.getPoint().getX(), e.getPoint().getY())));
	}

	@Override
	public void mouseMoved(MouseEvent e) {
		this.getGame().pushEvent(new MouseMovedEvent(new Point2D.Double(e.getPoint().getX(), e.getPoint().getY())));
	}

	@Override
	public void mouseClicked(MouseEvent e) {
	}

	@Override
	public void mouseEntered(MouseEvent e) {
	}

	@Override
	public void mouseExited(MouseEvent e) {
	}

	@Override
	public void mousePressed(MouseEvent e) {
		this.getGame().pushEvent(new MousePressedEvent(
			new Point2D.Double(e.getPoint().getX(), e.getPoint().getY()),
			MouseButton.fromMouseButtonCode(e.getButton()))
			);
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		this.getGame().pushEvent(new MouseReleasedEvent(
			new Point2D.Double(e.getPoint().getX(), e.getPoint().getY()),
			MouseButton.fromMouseButtonCode(e.getButton()))
			);
	}

	@Override
	public void keyPressed(KeyEvent e) {
		Key key = Key.fromKeyCode(e.getKeyCode() != KeyEvent.VK_UNDEFINED ? e.getKeyCode() : (int) e.getKeyChar());

		this.getGame().pushEvent(new KeyPressedEvent(key));
	}

	@Override
	public void keyReleased(KeyEvent e) {
		Key key = Key.fromKeyCode(e.getKeyCode() != KeyEvent.VK_UNDEFINED ? e.getKeyCode() : (int) e.getKeyChar());

		this.getGame().pushEvent(new KeyReleasedEvent(key));
	}

	@Override
	public void keyTyped(KeyEvent e) {
	}

	// ****************************************************************
	// ** ACCESSORS
	// ****************************************************************

	protected Game getGame() {
		return this.game;
	}

	protected void setGame(Game game) {
		this.game = game;
	}
}