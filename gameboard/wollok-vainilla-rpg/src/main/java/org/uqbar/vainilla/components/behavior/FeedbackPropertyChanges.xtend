package org.uqbar.vainilla.components.behavior

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.GameComponent
import java.util.List
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.interpreter.core.WollokObjectListener
import org.uqbar.wollok.rpg.components.PropertyChanged

/**
 * 
 * @author jfernandes
 */
class FeedbackPropertyChanges extends Behavior implements WollokObjectListener {
	WollokObject model
	List<PropertyChanged> bufferedEvents = newArrayList()
	
	new(WollokObject object) {
		model = object
		model.addFieldChangedListener(this)
	}
	
	override removeFrom(GameComponent c) {
		model.removeFieldChangedListener(this)
		super.removeFrom(c)
	}
	
	override synchronized update(DeltaState s) {
		val ite = bufferedEvents.iterator
		while (ite.hasNext()) {
			val e = ite.next
			ite.remove
			component.scene.addComponent(e)
		}
	}
	
	override synchronized fieldChanged(String fieldName, Object oldValue, Object newValue) {
		bufferedEvents.add(new PropertyChanged(component, fieldName, oldValue, newValue))
	}
	
}