package org.uqbar.project.wollok.game

import com.badlogic.gdx.utils.Json

import java.io.IOException
import java.nio.charset.Charset
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths

import org.uqbar.project.wollok.game.gameboard.Gameboard

class GameboardFactory {
	
	def static setGame(Gameboard gameboard) {
		loadConfig().configure(gameboard)
	}
	
	def static loadConfig(){
		var Json json = new Json()
		var String text = readFile("config.json", StandardCharsets.UTF_8)
		json.fromJson(typeof(GameConfiguration), text)
	}
	
	def static readFile(String path, Charset encoding) throws IOException {
	  var byte[] encoded = Files.readAllBytes(Paths.get(path));
	  return new String(encoded, encoding);
	}
}
