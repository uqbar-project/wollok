package org.uqbar.wollok.rpg.components;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.events.constants.Key;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.Functions.Function2;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.uqbar.project.wollok.interpreter.core.WollokObject;
import org.uqbar.project.wollok.ui.utils.XTendUtilExtensions;
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration;
import org.uqbar.vainilla.components.behavior.Behavior;
import org.uqbar.vainilla.components.behavior.VainillaExtensions;
import org.uqbar.vainilla.components.collision.Collidable;
import org.uqbar.wollok.rpg.WollokMovingGameComponent;
import org.uqbar.wollok.rpg.WollokObjectView;
import org.uqbar.wollok.rpg.components.CollisionBubble;
import org.uqbar.wollok.rpg.components.TextOption;
import org.uqbar.wollok.rpg.scenes.WollokRPGScene;

/**
 * A behavior that handles collisions with other objects.
 * In that case it presents a menu to send messages to either of them
 * passing the other as argument.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class SendMessageOnCollision extends Behavior<WollokMovingGameComponent> {
  private final static int leftPadding = 5;
  
  private final static int rightPadding = 5;
  
  private final static int topPadding = 5;
  
  private final static int lineSpacing = 3;
  
  private List<? extends GameComponent> collisionComponents;
  
  private WollokObjectView collidingWith;
  
  public void update(final DeltaState s) {
    final List<Collidable> collisions = VainillaExtensions.collidingComponents(this.component);
    boolean _isEmpty = collisions.isEmpty();
    if (_isEmpty) {
      this.disposeMenu();
    } else {
      boolean _equals = Objects.equal(this.collisionComponents, null);
      if (_equals) {
        final Collidable other = IterableExtensions.<Collidable>head(collisions);
        List<GameComponent> _createCollisionDialog = this.createCollisionDialog(other);
        this.collisionComponents = _createCollisionDialog;
        final Procedure1<GameComponent> _function = new Procedure1<GameComponent>() {
          public void apply(final GameComponent it) {
            WollokRPGScene _scene = SendMessageOnCollision.this.component.getScene();
            _scene.addComponent(it);
          }
        };
        IterableExtensions.forEach(this.collisionComponents, _function);
      } else {
        this.checkIfOptionSelected(s);
      }
    }
  }
  
  public void checkIfOptionSelected(final DeltaState state) {
    boolean _isKeyPressed = state.isKeyPressed(Key.ZERO);
    if (_isKeyPressed) {
      Iterable<WMethodDeclaration> _allModelMethods = this.allModelMethods();
      WMethodDeclaration _get = ((WMethodDeclaration[])Conversions.unwrapArray(_allModelMethods, WMethodDeclaration.class))[0];
      this.invokeOnModel(_get);
    }
  }
  
  public void invokeOnModel(final WMethodDeclaration m) {
    WollokObject _model = this.component.getModel();
    String _name = m.getName();
    WollokObject _model_1 = this.collidingWith.getModel();
    _model.call(_name, _model_1);
  }
  
  public void removeFrom(final WollokMovingGameComponent c) {
    this.disposeMenu();
    super.removeFrom(c);
  }
  
  public void disposeMenu() {
    boolean _notEquals = (!Objects.equal(this.collisionComponents, null));
    if (_notEquals) {
      final Procedure1<GameComponent> _function = new Procedure1<GameComponent>() {
        public void apply(final GameComponent it) {
          it.destroy();
        }
      };
      IterableExtensions.forEach(this.collisionComponents, _function);
    }
    this.collisionComponents = null;
  }
  
  public List<GameComponent> createCollisionDialog(final Collidable collidable) {
    List<GameComponent> _xblockexpression = null;
    {
      this.collidingWith = ((WollokObjectView) collidable);
      final Collection<TextOption> opts = this.createMessagesOptions();
      final int maxWidth = ((((int) XTendUtilExtensions.<TextOption>maxBy(opts, new Function1<TextOption, Double>() {
        public Double apply(final TextOption it) {
          return Double.valueOf(it.getWidth());
        }
      }).getWidth()) + SendMessageOnCollision.leftPadding) + SendMessageOnCollision.rightPadding);
      final Function2<Double, TextOption, Double> _function = new Function2<Double, TextOption, Double>() {
        public Double apply(final Double a, final TextOption o) {
          double _height = o.getHeight();
          return Double.valueOf((((a).doubleValue() + SendMessageOnCollision.lineSpacing) + _height));
        }
      };
      Double _fold = IterableExtensions.<TextOption, Double>fold(opts, Double.valueOf(0d), _function);
      final double optsHeight = ((_fold).doubleValue() + (SendMessageOnCollision.topPadding * 2));
      double _rightOf = VainillaExtensions.rightOf(this.component);
      double _y = this.component.getY();
      final CollisionBubble bubble = new CollisionBubble(((int) _rightOf), ((int) _y), maxWidth, ((int) optsHeight));
      final Function2<GameComponent<?>, TextOption, GameComponent<?>> _function_1 = new Function2<GameComponent<?>, TextOption, GameComponent<?>>() {
        public GameComponent<?> apply(final GameComponent<?> previous, final TextOption it) {
          TextOption _xblockexpression = null;
          {
            TextOption _head = IterableExtensions.<TextOption>head(opts);
            boolean _equals = Objects.equal(it, _head);
            if (_equals) {
              double _y = bubble.getY();
              double _plus = (_y + SendMessageOnCollision.topPadding);
              it.alignTopTo(_plus);
              double _x = bubble.getX();
              double _plus_1 = (_x + SendMessageOnCollision.leftPadding);
              it.alignLeftTo(_plus_1);
            } else {
              double _y_1 = previous.getY();
              double _height = previous.getHeight();
              double _plus_2 = (_y_1 + _height);
              double _plus_3 = (_plus_2 + SendMessageOnCollision.lineSpacing);
              it.alignTopTo(_plus_3);
              double _x_1 = bubble.getX();
              double _plus_4 = (_x_1 + SendMessageOnCollision.leftPadding);
              it.alignLeftTo(_plus_4);
            }
            _xblockexpression = it;
          }
          return _xblockexpression;
        }
      };
      IterableExtensions.<TextOption, GameComponent<?>>fold(opts, ((GameComponent<?>) bubble), _function_1);
      Iterable<GameComponent> _plus = Iterables.<GameComponent>concat(Collections.<CollisionBubble>unmodifiableList(Lists.<CollisionBubble>newArrayList(bubble)), opts);
      _xblockexpression = IterableExtensions.<GameComponent>toList(_plus);
    }
    return _xblockexpression;
  }
  
  public Collection<TextOption> createMessagesOptions() {
    Iterable<WMethodDeclaration> _allModelMethods = this.allModelMethods();
    final Function2<Integer, WMethodDeclaration, TextOption> _function = new Function2<Integer, WMethodDeclaration, TextOption>() {
      public TextOption apply(final Integer i, final WMethodDeclaration m) {
        CharSequence _createText = SendMessageOnCollision.this.createText(m, (i).intValue());
        String _string = _createText.toString();
        return new TextOption(0, 0, _string);
      }
    };
    return XTendUtilExtensions.<WMethodDeclaration, TextOption>map(_allModelMethods, _function);
  }
  
  public Iterable<WMethodDeclaration> allModelMethods() {
    WollokObject _model = this.component.getModel();
    return _model.allMethods();
  }
  
  public CharSequence createText(final WMethodDeclaration m, final int i) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("(");
    _builder.append(i, "");
    _builder.append(") ");
    String _name = m.getName();
    String _phrase = XTendUtilExtensions.toPhrase(_name);
    _builder.append(_phrase, "");
    return _builder;
  }
}
