package org.uqbar.project.wollok.ui.console.highlight

import java.util.List
import java.util.regex.Matcher
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB

/**
 * Utility extension methods for manipulating text in editors or consoles
 * in eclipse.
 * For example for styles, highlighting etc.
 * 
 * @author jfernandes
 */
class WTextExtensions {
	
	/** 
	 * Merges the given new style into the list of styles.
	 * It performs all the movements and splitups to make sure there are no overlaps.
	 * The new style is considered priority so it will "win" over the existing ones.
	 */
	def static merge(List<StyleRange> ranges, StyleRange newStyle) {
		val sorted = ranges.sortBy[start]
		val toAppend = newArrayList
		
		// overlapping before
		val before = sorted.filter[start < newStyle.start && end > newStyle.start]
			// reduce end (from right)
			before.filter[end.between(newStyle)].forEach[ length = newStyle.start - start ]
			// larger than original -> split in 2
			before.filter[end > newStyle.end].forEach[
				toAppend.add(it.clone as StyleRange => [start = newStyle.end])
				length = newStyle.start - start
			]
		
		val after = sorted.filter[start >= newStyle.start]
			// exceeding to right -> reduce start (from left)
			after.filter[end > newStyle.end].forEach[ start = newStyle.end ]
		
		// between -> remove
		ranges.removeAll(after.filter[end <= newStyle.end].toList)
		ranges.addAll(toAppend)
		// finally add the new one
		ranges.add(newStyle)
	}
	
	def static end(StyleRange it) { start + length }
	def static between(int position, StyleRange range) { position >= range.start && position <= range.end }
	
	def static replace(String str, Matcher it, String replacement) {
		str.substring(0, start) + (replacement * (end - start)) + str.substring(end)
	}
	
	def static operator_multiply(String s, int n) { (1..n).map[' '].join }
	
	def static newColor(int r, int g, int b) {new Color(null, new RGB(r, g, b)) }
	
}