package org.uqbar.project.wollok.validation

import org.uqbar.project.wollok.Messages

/**
 * Severity for validator's checks
 * 
 * @author jfernandes
 */
enum CheckSeverity {
	ERROR,
	WARN,
	INFO
}

class CheckSeverityUtils {
	def static getI18nizedValue(CheckSeverity s) {
		switch(s) {
			case ERROR: Messages.CheckSeverity_ERROR
			case WARN: Messages.CheckSeverity_WARN
			case INFO: Messages.CheckSeverity_INFO
		}
	}
}