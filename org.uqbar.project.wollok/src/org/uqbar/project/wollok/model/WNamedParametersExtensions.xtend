package org.uqbar.project.wollok.model

import java.util.List
import org.uqbar.project.wollok.wollokDsl.WAncestor
import org.uqbar.project.wollok.wollokDsl.WClass
import org.uqbar.project.wollok.wollokDsl.WConstructorCall
import org.uqbar.project.wollok.wollokDsl.WInitializer
import org.uqbar.project.wollok.wollokDsl.WMethodContainer
import org.uqbar.project.wollok.wollokDsl.WMixin
import org.uqbar.project.wollok.wollokDsl.WNamedObject
import org.uqbar.project.wollok.wollokDsl.WObjectLiteral

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.linearizeHierarchy

class WNamedParametersExtensions {
	def static hasParentParameters(WMethodContainer mc) {
		!mc.allInitializers.isEmpty
	}

	def static dispatch List<WInitializer> allInitializers(WClass it) {
		allParents.initializers
	}
	def static dispatch List<WInitializer> allInitializers(WNamedObject it) {
		allParents.initializers
	}
	def static dispatch List<WInitializer> allInitializers(WObjectLiteral it) {
		allParents.initializers
	}
	def static dispatch List<WInitializer> allInitializers(WMethodContainer mc) { newArrayList }
	
	def static List<WInitializer> initializers(List<WAncestor> it) {
		flatMap [ parentParameters?.initializers ?: newArrayList ].toList
	}
	
	def static List<WAncestor> allParents(WMethodContainer it) {
		linearizeHierarchy.flatMap [ plainParents ].toList
	}
	
	def static dispatch List<WAncestor> plainParents(WMethodContainer it) { newArrayList }
	def static dispatch List<WAncestor> plainParents(WObjectLiteral it) { parents }
	def static dispatch List<WAncestor> plainParents(WNamedObject it) { parents }
	def static dispatch List<WAncestor> plainParents(WClass it) { parents }
	def static dispatch List<WAncestor> plainParents(WMixin it) { parents }

	def static dispatch getAncestor(WAncestor it) { ref as WMethodContainer }
	def static dispatch getAncestor(WConstructorCall it) { classRef }	
}
