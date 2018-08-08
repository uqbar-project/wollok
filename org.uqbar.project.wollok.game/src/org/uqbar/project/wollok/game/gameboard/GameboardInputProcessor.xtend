package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.InputProcessor
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.scenes.scene2d.ui.Button
import com.badlogic.gdx.scenes.scene2d.ui.Label
import com.badlogic.gdx.scenes.scene2d.ui.Label.LabelStyle
import com.badlogic.gdx.scenes.scene2d.ui.ScrollPane
import com.badlogic.gdx.scenes.scene2d.ui.Table
import org.uqbar.project.wollok.game.VisualComponent
import org.uqbar.project.wollok.game.WGPosition

class GameboardInputProcessor implements InputProcessor {

	override boolean keyDown(int keycode) {
		false
	}

	override boolean keyUp(int keycode) {
		false
	}

	override boolean keyTyped(char character) {
		false
	}

	override boolean touchDown(int x, int y, int pointer, int button) {
		val inverseY = Gameboard.getInstance().pixelHeight() - y
		val position = new WGPosition(x / Gameboard.CELLZISE, inverseY / Gameboard.CELLZISE )
		
		val Iterable<VisualComponent> lista = Gameboard.getInstance.getComponentsInPosition(position)
		
		//System.out.println("Click en " + x + "," + y + " con boton" + button)
		//System.out.println("Hay " + lista.size + " elementos")
		if (button == 1) {
			//Gameboard.getInstance.getStage.addActor(MenuBuilder.buildMenu(x, y))
		}
		true
	}

	override boolean touchUp(int x, int y, int pointer, int button) {
		false
	}

	override boolean touchDragged(int x, int y, int pointer) {
		false
	}

	override boolean mouseMoved(int x, int y) {
		false
	}

	override boolean scrolled(int amount) {
		false
	}

}

public class MenuBuilder {

	def static ScrollPane buildMenu(int x, int y) {
		val font = new BitmapFont() => [
			useIntegerPositions = false
		]

		val lStyle = new LabelStyle()
		lStyle.font = font

		val mainTable = new Table() => [
			defaults().width(80)
		]

		val scrollPane = new ScrollPane(mainTable) => [
			fillParent = false
			setX = x
			setY = y
		]

		mainTable => [
			add(new Button() => [
					add(new Label("Move", lStyle))
					left
				])
			row	
			add(new Button() => [
					add(new Label("Attack", lStyle))
					left
				])
			row
		]
		scrollPane
	}
}
