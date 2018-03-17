package org.uqbar.project.wollok

import org.eclipse.emf.ecore.EClass
import org.eclipse.osgi.util.NLS
import org.uqbar.project.wollok.wollokDsl.WMethodContainer

import static extension org.uqbar.project.wollok.model.WMethodContainerExtensions.*

/**
 * @author jfernandes
 */
class WollokModelUtils {

	def static humanReadableModelTypeName(EClass it) { if(name.startsWith("W")) name.substring(1) else name }

	def static methodNotFoundMessage(WMethodContainer container, String methodName, Object... parameters) {
		val fullMessage = methodName + "(" + parameters.join(",") + ")"
		val similarMethods = container.findMethodsByName(methodName)
		if (similarMethods.empty) {
			val caseSensitiveMethod = container.allMethods.findMethodIgnoreCase(methodName, parameters.size)
			if (caseSensitiveMethod !== null) {
				(NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_CASE_SENSITIVE,
					#[container.name, fullMessage, #[caseSensitiveMethod].convertToString]))
			} else {
				(NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST, container.name, fullMessage))
			}
		} else {
			val similarDefinitions = similarMethods.map[messageName].join(', ')
			(NLS.bind(Messages.WollokDslValidator_METHOD_DOESNT_EXIST_BUT_SIMILAR_FOUND,
					#[container.name, fullMessage, similarDefinitions]))
		}
	}
}
