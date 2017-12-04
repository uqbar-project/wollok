package org.uqbar.project.wollok.utils

class OperatingSystemUtils {
	
	def static isOsWindows() {
		val os = System.getProperty("os.name")
        os === null || os.toUpperCase.startsWith("WIN")
	}
	
	def static isOsMac() {
		val os = System.getProperty("os.name")
        os !== null && os.toUpperCase.startsWith("MAC")
	}
	
	def static isOsLinux() {
		val os = System.getProperty("os.name")
        os !== null && #["NIX", "NUX", "AIX", "SUNOS"].exists [ os.toUpperCase.startsWith(it) ]
	}
	
}