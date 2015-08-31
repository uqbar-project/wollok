package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.InputProcessor
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.scenes.scene2d.ui.Button
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.Label.LabelStyle
import com.badlogic.gdx.scenes.scene2d.ui.ScrollPane
import com.badlogic.gdx.scenes.scene2d.ui.Table
import java.util.Collection
import org.uqbar.project.wollok.game.VisualComponent

class GameboardInputProcessor implements InputProcessor {

	override boolean keyDown(int keycode) {
		return false;
	}

	override boolean keyUp(int keycode) {
		return false;
	}

	override boolean keyTyped(char character) {
		return false;
	}

	override boolean touchDown(int x, int y, int pointer, int button) {

		var Collection<VisualComponent> lista = Gameboard.getInstance.getComponentsInPosition(x, y)
		System.out.println("Click en " + x + "," + y + " con boton" + button)
		System.out.println("Hay " + lista.size + " elementos")
		if (button == 1) {
			//Gameboard.getInstance.getStage.addActor(MenuBuilder.buildMenu(x, y))
		}
		return true;
	}

	override boolean touchUp(int x, int y, int pointer, int button) {
		return false;
	}

	override boolean touchDragged(int x, int y, int pointer) {
		return false;
	}

	override boolean mouseMoved(int x, int y) {
		return false;
	}

	override boolean scrolled(int amount) {
		return false;
	}

}

public class MenuBuilder {

	def static ScrollPane buildMenu(int x, int y) {
		var BitmapFont font = new BitmapFont();
		font.setUseIntegerPositions(false);

		var LabelStyle lStyle = new LabelStyle();
		lStyle.font = font;

		var Table mainTable = new Table();
		mainTable.defaults().width(80);

		var ScrollPane scrollPane = new ScrollPane(mainTable);
		scrollPane.setFillParent(false);
		scrollPane.setX(x);
		scrollPane.setY(y);

		var Button b1 = new Button();
		b1.add(new Label("Move", lStyle));
		b1.left();
		mainTable.add(b1);
		mainTable.row();

		var Button b2 = new Button();
		b2.add(new Label("Attack", lStyle));
		b2.left();
		mainTable.add(b2);
		mainTable.row();

		return scrollPane;
	}
}
