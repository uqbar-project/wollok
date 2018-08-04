package org.uqbar.project.wollok.launch

import org.eclipse.xtext.validation.Issue

/**
 * Strategy object for handling parser or static check
 * analysis error from the WollokChecker/Launcher.
 * 
 * For example if in jsonoutput mode then the errors will be 
 * displayed as JSON in the console.
 * 
 * @author jfernandes
 */
interface WollokLauncherIssueHandler {
	/** will be called for each issue found */
	def void handleIssue(Issue issue)
	
	/** 
	 * Will be called after all checks have been executed and at least one of them
	 * failed with error.
	 * This lets you do something at tear down.
	 */
	def void finished()
}

/**
 * Default handler prints to console a line per issue.
 * The sublime plugin depends on this format !
 * 
 * @author jfernandes
 */
class DefaultWollokLauncherIssueHandler implements WollokLauncherIssueHandler {
	
	override handleIssue(Issue issue) {
		println(issue.formattedIssue)
	}
	
	def String formattedIssue(Issue it) {
		// COLUMN: investigate how to calculate the column number from the offset !
		'''[«severity»] «uriToProblem?.trimFragment?.toFileString»:«lineNumber»:«if (offset === null) 1 else offset» «severity?.name» «message»'''
	}
	
	override finished() {}
	
}

