package org.uqbar.project.wollok.launch

class WollokLauncherExtensions {
	
	public static String SPACE_ENCODED = "{__SPACE__}"

	def static encode(String option) {
		option.replace(" ", SPACE_ENCODED)
	}

	def static decode(String option) {
		option.replace(SPACE_ENCODED, " ")
	}
	
}