package org.uqbar.wollok.rpg.components

import com.uqbar.vainilla.DeltaState
import com.uqbar.vainilla.GameComponent
import com.uqbar.vainilla.events.constants.Key
import java.util.List
import org.uqbar.project.wollok.wollokDsl.WMethodDeclaration
import org.uqbar.vainilla.components.behavior.Behavior
import org.uqbar.vainilla.components.collision.Collidable
import org.uqbar.wollok.rpg.WollokMovingGameComponent
import org.uqbar.wollok.rpg.WollokObjectView

import static extension org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*
import static extension org.uqbar.vainilla.components.behavior.VainillaExtensions.*

/**
 * A behavior that handles collisions with other objects.
 * In that case it presents a menu to send messages to either of them
 * passing the other as argument.
 * 
 * @author jfernandes
 */
class SendMessageOnCollision extends Behavior<WollokMovingGameComponent> {
	static val leftPadding = 5
	static val rightPadding = 5
	static val topPadding = 5
	static val lineSpacing = 3
	
	List<? extends GameComponent> collisionComponents
	var WollokObjectView collidingWith
	
	override update(DeltaState s) {
		val collisions = component.collidingComponents
		if (collisions.empty) {
			disposeMenu
		}
		else if (collisionComponents == null) {
			val other = collisions.head
			collisionComponents = createCollisionDialog(other)
			collisionComponents.forEach[ component.scene.addComponent(it) ]
		}
		else
			checkIfOptionSelected(s)
	}
	
	def checkIfOptionSelected(DeltaState state) {
		if (state.isKeyPressed(Key.ZERO))
			allModelMethods.get(0).invokeOnModel
	}
	
	def void invokeOnModel(WMethodDeclaration m) {
		component.model.call(m.name, collidingWith.model)
	}
	
	override removeFrom(WollokMovingGameComponent c) {
		disposeMenu
		super.removeFrom(c)
	}
	
	def void disposeMenu() {
		if (collisionComponents != null)
			collisionComponents.forEach[destroy]
			collisionComponents = null
	}
	
	def createCollisionDialog(Collidable collidable) {
		collidingWith = collidable as WollokObjectView
		
		val opts = createMessagesOptions()
		val maxWidth = opts.maxBy[width].width as int + leftPadding + rightPadding 
		val optsHeight = opts.fold(0d)[a, o| a + lineSpacing + o.height] + topPadding * 2
		
		val bubble = new CollisionBubble(component.rightOf as int, component.y as int, maxWidth, optsHeight as int)
		
		opts.fold(bubble as GameComponent<?>)[previous, it|
			if (it == opts.head) {
				alignTopTo(bubble.y + topPadding)
				alignLeftTo(bubble.x + leftPadding)
			}
			else {
				alignTopTo(previous.y + previous.height + lineSpacing)
				alignLeftTo(bubble.x + leftPadding)
			}
			it
		]
		(#[bubble] + opts).toList
	}
	
	def createMessagesOptions() {
		allModelMethods.map[i, m| new TextOption(0, 0, createText(m, i).toString) ]
	}
	
	def allModelMethods() {
		component.getModel.allMethods
	}
	
	def createText(WMethodDeclaration m, int i) '''(«i») «m.name.toPhrase»'''
	
}