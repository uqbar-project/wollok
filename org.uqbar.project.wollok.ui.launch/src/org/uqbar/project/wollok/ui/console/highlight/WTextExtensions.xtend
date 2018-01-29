package org.uqbar.project.wollok.ui.console.highlight

import java.util.List
import org.eclipse.swt.custom.StyleRange
import org.eclipse.swt.graphics.Color
import org.eclipse.swt.graphics.RGB

/**
 * Utility extension methods for manipulating text in editors or consoles
 * in eclipse.
 * For example for styles, highlighting etc.
 * 
 * @author jfernandes
 * @author dodain
 * 
 */
class WTextExtensions {

	/** 
	 * Merges the given new style into the list of styles.
	 * It performs all the movements and splitups to make sure there are no overlaps.
	 * The new style is considered priority so it will "win" over the existing ones.
	 */
	def static merge(List<StyleRange> ranges, StyleRange newStyle) {
		val List<StyleRange> _ranges = newArrayList(ranges)
		val sorted = _ranges.sortBy[start]
		val toAppend = newArrayList

		// overlapping before
		val before = sorted.filter[start < newStyle.start && end > newStyle.start]
		// reduce end (from right)
		before.filter[end.between(newStyle)].forEach[length = newStyle.start - start]

		// larger than original -> split in 2
		before.filter[end > newStyle.end].forEach [ range |
			toAppend.add(range.clone as StyleRange => [
				val newLength = range.end - newStyle.end
				start = newStyle.end
				length = newLength
			])
			range.length = newStyle.start - range.start
		]


		val after = sorted.filter[start >= newStyle.start]
		// exceeding to right -> reduce start (from left)
		val rangesAfterStyle = after.filter[end > newStyle.end].sortBy [ start ]
		if (!rangesAfterStyle.isEmpty) {
			rangesAfterStyle.fold(newStyle.end - rangesAfterStyle.head.start, 
				[acum, style |
					if (acum > 0) {
						style.start += acum  
						val total = acum - style.length
						style.length -= acum
						total
					} else {
						0
					}
				])
		}

		// between -> remove
		_ranges.removeAll(after.filter[length <= 0].toList)
		_ranges.removeAll(after.filter[end <= newStyle.end].toList)
		_ranges.addAll(toAppend)
		// add new one
		_ranges.add(newStyle)

		// now adding all ranges sorted by start
		ranges.clear
		ranges.addAll(_ranges.sortBy [ start ])
	}

	def static end(StyleRange it) { start + length }

	def static between(int position, StyleRange range) { position >= range.start && position <= range.end }

	def static newColor(int r, int g, int b) { new Color(null, new RGB(r, g, b)) }

}
