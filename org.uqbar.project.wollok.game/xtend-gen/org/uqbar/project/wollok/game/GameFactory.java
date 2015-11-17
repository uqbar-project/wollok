package org.uqbar.project.wollok.game;

import com.badlogic.gdx.utils.Json;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.uqbar.project.wollok.game.Component;
import org.uqbar.project.wollok.game.GameConfiguration;
import org.uqbar.project.wollok.game.gameboard.Gameboard;

@SuppressWarnings("all")
public class GameFactory {
  private Gameboard gameboard;
  
  public void exampleJson() {
    GameConfiguration config = new GameConfiguration();
    config.setGameboardHeight(5);
    config.setGameboardTitle("sokoban");
    config.setGameboardWidth(5);
    config.setImageCharacter("jugador.png");
    config.setImageGround("flying_bird.png");
    config.setArrowListener(true);
    Component _component = new Component("pared.png", true, false);
    config.addComponent(_component);
    Component _component_1 = new Component("caja.png", true, true);
    config.addComponent(_component_1);
    this.makeJson(config);
  }
  
  public void makeJson(final GameConfiguration aConfig) {
    Json json = new Json();
    String _prettyPrint = json.prettyPrint(aConfig);
    System.out.println(_prettyPrint);
  }
  
  public GameConfiguration loadJson() {
    try {
      GameConfiguration _xblockexpression = null;
      {
        Json json = new Json();
        String text = this.readFile("config.json", StandardCharsets.UTF_8);
        GameConfiguration config = json.<GameConfiguration>fromJson(GameConfiguration.class, text);
        _xblockexpression = this.gameboard.setConfiguration(config);
      }
      return _xblockexpression;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void setGame(final Gameboard aGameboard) {
    this.gameboard = aGameboard;
    this.loadJson();
    GameConfiguration _configuration = aGameboard.getConfiguration();
    _configuration.build(aGameboard);
  }
  
  public String readFile(final String path, final Charset encoding) throws IOException {
    Path _get = Paths.get(path);
    byte[] encoded = Files.readAllBytes(_get);
    return new String(encoded, encoding);
  }
}
