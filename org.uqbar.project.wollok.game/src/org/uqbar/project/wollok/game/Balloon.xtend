package org.uqbar.project.wollok.game

import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.Gdx
import org.uqbar.project.wollok.game.gameboard.Gameboard
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import com.badlogic.gdx.graphics.g2d.BitmapFont

class Balloon {

	NinePatch patch

	new() {
		super()
		patch = new NinePatch(new Texture(Gdx.files.internal("assets/speech.png")), 30, 60, 40, 50)
	}

	def void draw(SpriteBatch batch, String text) {
		var textBitmap = new BitmapFont();
//		var lenght = text.length
//		var rows = lenght / 8
		
		var character = Gameboard.getInstance.getCharacter()
		var	x = character.getPosition().getXinPixels() + 40;
		var y = character.getPosition().getYinPixels() + 40;
		patch.draw(batch, x, y, 100, 85);
		
		textBitmap.setColor(0, 0, 0, 100);
		textBitmap.draw(batch, text, x + 10, y + 75, 75, 3, true);
	}
}
