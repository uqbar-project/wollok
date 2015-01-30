package org.uqbar.vainilla.components.behavior;

import com.uqbar.vainilla.DeltaState;
import com.uqbar.vainilla.GameComponent;
import org.uqbar.vainilla.components.behavior.Behavior;

/**
 * Makes the component live just for the given amount of time.
 * Then it will destroy it.
 * 
 * @author jfernandes
 */
@SuppressWarnings("all")
public class TimeBoxed extends Behavior {
  private long attachedTime;
  
  private long lifeSpanInMillis;
  
  public TimeBoxed(final long lifeSpanInMillis) {
    this.lifeSpanInMillis = lifeSpanInMillis;
  }
  
  public void attachedTo(final GameComponent c) {
    super.attachedTo(c);
    long _currentTimeMillis = System.currentTimeMillis();
    this.attachedTime = _currentTimeMillis;
  }
  
  public void update(final DeltaState s) {
    long _currentTimeMillis = System.currentTimeMillis();
    boolean _greaterEqualsThan = (_currentTimeMillis >= (this.attachedTime + this.lifeSpanInMillis));
    if (_greaterEqualsThan) {
      this.component.destroy();
    }
  }
}
