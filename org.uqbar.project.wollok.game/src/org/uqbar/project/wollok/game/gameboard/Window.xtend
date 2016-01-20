package org.uqbar.project.wollok.game.gameboard

import com.badlogic.gdx.Gdx
import com.badlogic.gdx.graphics.Color
import com.badlogic.gdx.graphics.GL20
import com.badlogic.gdx.graphics.OrthographicCamera
import com.badlogic.gdx.graphics.Texture
import com.badlogic.gdx.graphics.g2d.BitmapFont
import com.badlogic.gdx.graphics.g2d.GlyphLayout
import com.badlogic.gdx.graphics.g2d.NinePatch
import com.badlogic.gdx.graphics.g2d.SpriteBatch
import org.uqbar.project.wollok.game.Image
import org.uqbar.project.wollok.game.Position

class Window {
	val patch = new NinePatch(new Texture(Gdx.files.internal("speech.png")), 30, 60, 40, 50)
	val textBitmap = new BitmapFont()
	val batch = new SpriteBatch()
	val font = new BitmapFont()
	val glyphLayout = new GlyphLayout()
	OrthographicCamera camera
	
	new(OrthographicCamera camera) {
		this.camera = camera
	}
	
	def draw(Image image, Position position) {
		drawIn(image, position.xinPixels, position.yinPixels)
	}
	
	def drawIn(Image image, int x, int y) {
		batch.draw(image.texture, x, y)
	}
	
	def writeAttributes(String text, Position position, Color color) {
		glyphLayout.reset()
		glyphLayout.setText(font, text, color, 220, 3, true)
		font.draw(batch, glyphLayout, position.xinPixels - 80, position.yinPixels)
	}
	
	def drawBallon(String text, Position position, Color color) {		
		val baseWidth = 75
		var newText = text
		
		if (text.length > 50)
			newText = text.substring(0,49) + "..."
		
		var plusWidth = 0	
		glyphLayout.reset
		this.setText(newText, baseWidth, color)
		
		while(glyphLayout.height > 29){
			glyphLayout.reset
			plusWidth += 10
			this.setText(newText, baseWidth + plusWidth, color)
		}
		
		var	x = position.getXinPixels() + 40
		var y = position.getYinPixels() + 40
		this.patch.draw(batch, x, y, 100 + plusWidth, 85)
		this.textBitmap.draw(batch, glyphLayout, x + 10, y + 75)
	}

	def setText(String text, int width, Color color) {
		glyphLayout.setText(this.textBitmap, text, color, width, 3, true)
	}
		
	def clear() {
		Gdx.gl.glClearColor(1, 1, 1, 1);
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		batch.setProjectionMatrix(camera.combined);
		batch.begin();
	}
	
	def end() {
		batch.end()
	}
	
	def dispose() {
		batch.dispose()
	}

	
}