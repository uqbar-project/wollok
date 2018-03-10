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
import java.util.Map
import com.badlogic.gdx.graphics.Texture.TextureFilter

class Window {
	val patch = new NinePatch(new Texture(Gdx.files.internal("speech.png")), 30, 60, 40, 50)
	val defaultImage = new Texture(Gdx.files.internal("wko.png")) //TODO: Merge with WollokConventionExtensions DEFAULT_IMAGE
	val notFoundText = "IMAGE\nNOT\nFOUND"
	val textBitmap = new BitmapFont()
	val batch = new SpriteBatch()
	val font = new BitmapFont()
	val glyphLayout = new GlyphLayout()
	val OrthographicCamera camera
	
	val Map<String, Texture> textures = newHashMap
	
	new(OrthographicCamera camera) {
		this.camera = camera
	}
	
	def draw(Image image, Position position) {
		drawIn(image, position.xinPixels, position.yinPixels, image.width, image.height)
	}
	
	def fullDraw(Image image, Position position) {
		drawIn(image, position.xinPixels, position.yinPixels, Gdx.graphics.width, Gdx.graphics.height)
	}
	
	def drawIn(Image image, int x, int y, int width, int heigth) {
		val texture = image.texture
		if (texture != null) //TODO: Think a better implementation
			batch.draw(texture, x, y, width, heigth)
		else
			drawNotFoundImage(x, y, width, heigth)
	}
	
	def drawNotFoundImage(int x, int y, int width, int heigth) {
		batch.draw(defaultImage, x, y, width, heigth)
		write(notFoundText, Color.BLACK, x - 80, y + 50)
	}
	
	def writeAttributes(String text, Position position, Color color) {
		write(text, color, position.xinPixels - 80, position.yinPixels)
	}
	
	def write(String text, Color color, int x, int y) {
		glyphLayout.reset()
		glyphLayout.setText(font, text, color, 215, 3, true)
		font.draw(batch, glyphLayout, x, y)
	}
	
	def drawBallon(String text, Position position, Color color) {		
		val baseWidth = 75
		var newText = text
		var plusWidth = 0	
		glyphLayout.reset
		this.setText(newText, baseWidth, color)
		
		while(glyphLayout.height > 29) {
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

	def Texture texture(Image it) {
		val texture = textures.get(path)
		if (texture === null && !textures.containsKey(path)) {
			path.addTexture
			it.texture
		} 
		else texture
	}
	
	def addTexture(String path) {
		val file = Gdx.files.internal(path)
			
		if (!file.exists) 
			textures.put(path, null)
		else {			
			val texture = new Texture(file)
			texture.setFilter(TextureFilter.Linear, TextureFilter.Linear)
			textures.put(path, texture)
		}
	}
}