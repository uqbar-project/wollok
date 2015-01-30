package org.uqbar.wollok.rpg.scenes;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.uqbar.vainilla.Game;
import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.GameScene;
import com.uqbar.vainilla.appearances.Sprite;
import com.uqbar.vainilla.colissions.Circle;
import com.uqbar.vainilla.colissions.CollisionDetector;
import java.awt.Graphics2D;
import java.io.File;
import java.io.InputStream;
import java.lang.reflect.Constructor;
import java.net.URI;
import java.net.URL;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Properties;
import java.util.function.Consumer;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.interpreter.SysoutWollokInterpreterConsole;
import org.uqbar.project.wollok.interpreter.WollokInterpreter;
import org.uqbar.project.wollok.interpreter.WollokInterpreterStandalone;
import org.uqbar.project.wollok.interpreter.context.EvaluationContext;
import org.uqbar.project.wollok.interpreter.context.WVariable;
import org.uqbar.project.wollok.interpreter.core.WollokObject;
import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions;
import org.uqbar.project.wollok.wollokDsl.WClass;
import org.uqbar.project.wollok.wollokDsl.WFile;
import org.uqbar.project.wollok.wollokDsl.WMethodContainer;
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral;
import org.uqbar.vainilla.components.behavior.VainillaExtensions;
import org.uqbar.vainilla.components.collision.Collidable;
import resource.Resource;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class WollokRPGScene extends GameScene {
  private final static String CONFIG_FILE = "WollokGame.properties";
  
  private final Properties wollokActorAssociation = new Properties();
  
  public WollokRPGScene(final Game game) {
    this.setGame(game);
    this.loadConfiguration();
    GameComponent<GameScene> _createBackground = this.createBackground();
    this.addComponent(_createBackground);
    this.createComponentsFromWollokWorld();
  }
  
  public void loadConfiguration() {
    try {
      InputStream in = null;
      try {
        Class<? extends WollokRPGScene> _class = this.getClass();
        InputStream _resourceAsStream = _class.getResourceAsStream(WollokRPGScene.CONFIG_FILE);
        in = _resourceAsStream;
        this.wollokActorAssociation.load(in);
      } finally {
        boolean _notEquals = (!Objects.equal(in, null));
        if (_notEquals) {
          in.close();
        }
      }
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public void createComponentsFromWollokWorld() {
    try {
      Class<? extends WollokRPGScene> _class = this.getClass();
      URL _resource = _class.getResource("example.wlk");
      URI _uRI = _resource.toURI();
      File _file = new File("target/classes/org/uqbar/wollok/rpg/scenes/example.wlk");
      File _file_1 = new File("target/classes/org/uqbar/wollok/rpg/scenes/warriors.wlk");
      final WFile program = WollokInterpreterStandalone.parse(_uRI, 
        Collections.<File>unmodifiableList(CollectionLiterals.<File>newArrayList(_file, _file_1)));
      SysoutWollokInterpreterConsole _createWollokConsole = this.createWollokConsole();
      final WollokInterpreter interpreter = new WollokInterpreter(_createWollokConsole);
      interpreter.interpret(program);
      EvaluationContext _currentContext = interpreter.getCurrentContext();
      Iterable<WVariable> _allReferenceNames = _currentContext.allReferenceNames();
      final Function1<WVariable, Object> _function = new Function1<WVariable, Object>() {
        public Object apply(final WVariable it) {
          EvaluationContext _currentContext = interpreter.getCurrentContext();
          String _name = it.getName();
          return _currentContext.resolve(_name);
        }
      };
      Iterable<Object> _map = IterableExtensions.<WVariable, Object>map(_allReferenceNames, _function);
      Iterable<WollokObject> _filter = Iterables.<WollokObject>filter(_map, 
        WollokObject.class);
      final Consumer<WollokObject> _function_1 = new Consumer<WollokObject>() {
        public void accept(final WollokObject wo) {
          WMethodContainer _kind = wo.getKind();
          GameComponent<?> _createActor = WollokRPGScene.this.createActor(_kind, wo);
          final Procedure1<GameComponent<?>> _function = new Procedure1<GameComponent<?>>() {
            public void apply(final GameComponent<?> it) {
              Game _game = WollokRPGScene.this.getGame();
              int _displayWidth = _game.getDisplayWidth();
              int _randomBetween = XTendUtilExtensions.randomBetween(0, _displayWidth);
              it.setX(_randomBetween);
              Game _game_1 = WollokRPGScene.this.getGame();
              int _displayHeight = _game_1.getDisplayHeight();
              int _randomBetween_1 = XTendUtilExtensions.randomBetween(0, _displayHeight);
              it.setY(_randomBetween_1);
            }
          };
          GameComponent<?> _doubleArrow = ObjectExtensions.<GameComponent<?>>operator_doubleArrow(_createActor, _function);
          WollokRPGScene.this.addComponent(_doubleArrow);
        }
      };
      _filter.forEach(_function_1);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  public SysoutWollokInterpreterConsole createWollokConsole() {
    return new SysoutWollokInterpreterConsole();
  }
  
  public GameComponent<?> createActor(final WMethodContainer kind, final WollokObject wo) {
    try {
      Class<?> _actorClass = this.actorClass(kind);
      Constructor<?> _constructor = _actorClass.getConstructor(WollokObject.class);
      Object _newInstance = _constructor.newInstance(wo);
      return ((GameComponent<?>) _newInstance);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  protected Class<?> _actorClass(final WClass clazz) {
    try {
      String _name = clazz.getName();
      String _property = this.wollokActorAssociation.getProperty(_name);
      return Class.forName(_property);
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  protected Class<?> _actorClass(final WObjectLiteral obj) {
    throw new UnsupportedOperationException("Not yet!");
  }
  
  public GameComponent<GameScene> createBackground() {
    Sprite _sprite = Resource.getSprite("terrain.png");
    return new GameComponent<GameScene>(_sprite, 0, 0);
  }
  
  public void takeStep(final Graphics2D graphics) {
    VainillaExtensions.antialiasingOn(graphics);
    super.takeStep(graphics);
    Iterable<Collidable> _collidables = this.getCollidables();
    Collidable[] _clone = ((Collidable[])Conversions.unwrapArray(_collidables, Collidable.class)).clone();
    final Consumer<Collidable> _function = new Consumer<Collidable>() {
      public void accept(final Collidable it) {
        WollokRPGScene.this.verifyComponentCollides(it);
      }
    };
    ((List<Collidable>)Conversions.doWrapArray(_clone)).forEach(_function);
  }
  
  public void verifyComponentCollides(final Collidable c) {
    List<Collidable> _collisions = this.collisions(c);
    final Consumer<Collidable> _function = new Consumer<Collidable>() {
      public void accept(final Collidable it) {
        c.collidesWith(it);
      }
    };
    _collisions.forEach(_function);
  }
  
  public boolean isCollision(final Collidable a, final Collidable b) {
    Circle _circ = a.getCirc();
    Circle _circ_1 = b.getCirc();
    return CollisionDetector.INSTANCE.collidesCircleAgainstCircle(_circ, _circ_1);
  }
  
  public Iterable<Collidable> getCollidables() {
    List<GameComponent<?>> _components = this.getComponents();
    return Iterables.<Collidable>filter(_components, Collidable.class);
  }
  
  public List<Collidable> collisions(final Collidable c) {
    Iterable<Collidable> _collidables = this.getCollidables();
    final Function1<Collidable, Boolean> _function = new Function1<Collidable, Boolean>() {
      public Boolean apply(final Collidable it) {
        return Boolean.valueOf((!Objects.equal(it, c)));
      }
    };
    Iterable<Collidable> _filter = IterableExtensions.<Collidable>filter(_collidables, _function);
    final Function1<Collidable, Boolean> _function_1 = new Function1<Collidable, Boolean>() {
      public Boolean apply(final Collidable it) {
        return Boolean.valueOf(WollokRPGScene.this.isCollision(c, it));
      }
    };
    Iterable<Collidable> _filter_1 = IterableExtensions.<Collidable>filter(_filter, _function_1);
    return IterableExtensions.<Collidable>toList(_filter_1);
  }
  
  public Class<?> actorClass(final WMethodContainer obj) {
    if (obj instanceof WObjectLiteral) {
      return _actorClass((WObjectLiteral)obj);
    } else if (obj instanceof WClass) {
      return _actorClass((WClass)obj);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(obj).toString());
    }
  }
}
