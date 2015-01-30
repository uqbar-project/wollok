package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.GameComponent;
import com.uqbar.vainilla.GameScene;
import java.util.Iterator;
import java.util.List;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.uqbar.project.wollok.interpreter.core.WollokObject;
import org.uqbar.project.wollok.interpreter.core.WollokObjectListener;
import org.uqbar.vainilla.components.behavior.Behavior;
import org.uqbar.wollok.rpg.components.PropertyChanged;

/**
 * @author jfernandes
 */
@SuppressWarnings("all")
public class FeedbackPropertyChanges extends Behavior implements WollokObjectListener {
  private WollokObject model;
  
  private List<PropertyChanged> bufferedEvents = CollectionLiterals.<PropertyChanged>newArrayList();
  
  public FeedbackPropertyChanges(final WollokObject object) {
    this.model = object;
    this.model.addFieldChangedListener(this);
  }
  
  public void removeFrom(final GameComponent c) {
    this.model.removeFieldChangedListener(this);
    super.removeFrom(c);
  }
  
  public synchronized void update(final DeltaState s) {
    final Iterator<PropertyChanged> ite = this.bufferedEvents.iterator();
    while (ite.hasNext()) {
      {
        final PropertyChanged e = ite.next();
        ite.remove();
        GameScene _scene = this.component.getScene();
        _scene.addComponent(e);
      }
    }
  }
  
  public synchronized void fieldChanged(final String fieldName, final Object oldValue, final Object newValue) {
    PropertyChanged _propertyChanged = new PropertyChanged(this.component, fieldName, oldValue, newValue);
    this.bufferedEvents.add(_propertyChanged);
  }
}
