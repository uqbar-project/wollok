package org.uqbar.wollok.rpg.scenes

import com.uqbar.vainilla.Game
import com.uqbar.vainilla.GameComponent
import com.uqbar.vainilla.GameScene
import com.uqbar.vainilla.colissions.CollisionDetector
import java.awt.Graphics2D
import java.io.File
import java.io.InputStream
import java.util.Properties
import org.uqbar.project.wollok.interpreter.SysoutWollokInterpreterConsole
import org.uqbar.project.wollok.interpreter.WollokInterpreter
import org.uqbar.project.wollok.interpreter.WollokInterpreterStandalone
import org.uqbar.project.wollok.interpreter.core.WollokObject
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral
import org.uqbar.vainilla.components.collision.Collidable
import resource.Resource

import static org.uqbar.project.wollok.ui.utils.XTendUtilExtensions.*

import static extension org.uqbar.vainilla.components.behavior.VainillaExtensions.*

/**
 * 
 * @author jfernandes
 */
class WollokRPGScene extends GameScene {
	static val CONFIG_FILE = "WollokGame.properties" // probably to be replaced by a custom DSL 
	val wollokActorAssociation = new Properties

	new(Game game) {
		this.game = game
		loadConfiguration
		addComponent(createBackground)
		createComponentsFromWollokWorld()
	}

	def loadConfiguration() {
		var InputStream in
		try {
			in = getClass.getResourceAsStream(CONFIG_FILE)
			wollokActorAssociation.load(in)
		} finally
			if (in != null)
				in.close
	}

	def createComponentsFromWollokWorld() {

		//HARDCODED classpath (2nd arg)
		val program = WollokInterpreterStandalone.parse(
			class.getResource("example.wlk").toURI,
			#[
				new File("target/classes/org/uqbar/wollok/rpg/scenes/example.wlk"),
				new File("target/classes/org/uqbar/wollok/rpg/scenes/warriors.wlk")
			]
		)
		val interpreter = new WollokInterpreter(createWollokConsole)
		interpreter.interpret(program)

		interpreter.currentContext.allReferenceNames.map[interpreter.currentContext.resolve(it.name)].filter(
			WollokObject).forEach [ wo |
			addComponent(
				createActor(wo.kind, wo) => [
					x = randomBetween(0, this.game.displayWidth)
					y = randomBetween(0, this.game.displayHeight)
				])
		]
	}

	def createWollokConsole() {

		// TODO: hacer una consolita en vainilla
		new SysoutWollokInterpreterConsole
	}

	def createActor(WMethodContainer kind, WollokObject wo) {
		actorClass(kind).getConstructor(WollokObject).newInstance(wo) as GameComponent<?>
	}

	def dispatch actorClass(WClass clazz) {
		Class.forName(wollokActorAssociation.getProperty(clazz.name))
	}

	//TODO other methods
	def dispatch actorClass(WObjectLiteral obj) {
		throw new UnsupportedOperationException("Not yet!")
	}

	def createBackground() {
		new GameComponent<GameScene>(Resource.getSprite("terrain.png"), 0, 0);
	}

	// mover esta logica de collidable a una superclase abstracta
	override takeStep(Graphics2D graphics) {
		graphics.antialiasingOn

		super.takeStep(graphics)
		collidables.clone.forEach[verifyComponentCollides]
	}

	def verifyComponentCollides(Collidable c) {
		c.collisions.forEach[c.collidesWith(it)]
	}

	def isCollision(Collidable a, Collidable b) {
		CollisionDetector.INSTANCE.collidesCircleAgainstCircle(a.circ, b.circ)
	}

	def getCollidables() { components.filter(Collidable) }

	def collisions(Collidable c) {
		collidables.filter[it != c].filter[isCollision(c, it)].toList
	}

}
