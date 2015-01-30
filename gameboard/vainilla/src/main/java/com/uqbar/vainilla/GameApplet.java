package com.uqbar.vainilla;

import java.applet.Applet;

@SuppressWarnings("serial")
public class GameApplet extends Applet {

	protected GamePlayer player;

	/**
	 * Sobreescribir si no se quiere usar la clase como parametro
	 * 
	 * @return
	 */
	protected Game buildGame() {
		try {
			return (Game) Class.forName(this.getParameter("gameClass"))
					.newInstance();
		} catch (RuntimeException e) {
			throw e;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public void init() {
		super.init();
		player = new GamePlayer(this.buildGame());
		this.add(player);
		this.setSize(player.getSize());
		new Thread(player).start();
		
	}

}
