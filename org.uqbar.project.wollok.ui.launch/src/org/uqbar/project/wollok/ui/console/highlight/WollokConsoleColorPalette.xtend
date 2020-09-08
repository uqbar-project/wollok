package org.uqbar.project.wollok.ui.console.highlight

import org.eclipse.swt.graphics.RGB
import static extension org.uqbar.project.wollok.utils.OperatingSystemUtils.*
import static extension org.uqbar.project.wollok.utils.WEclipseUtils.*

/**
 * 
 * @author jfernandes
 */
class WollokConsoleColorPalette {
    public static val PALETTE_VGA   = "paletteVGA"
    public static val PALETTE_WINXP = "paletteXP"
    public static val PALETTE_MAC   = "paletteMac"
    public static val PALETTE_PUTTY = "palettePuTTY"
    public static val PALETTE_XTERM = "paletteXTerm"

    // http://en.wikipedia.org/wiki/ANSI_escape_code
    val static RGB[] paletteVGA_light = #[
        new RGB(  0,   0,   0), // black
        new RGB(170,   0,   0), // red
        new RGB(  0, 170,   0), // green
        new RGB(170,  85,   0), // brown/yellow
        new RGB(  0,   0, 170), // blue
        new RGB(170,   0, 170), // magenta
        new RGB(  0, 102, 102), // cyan
        new RGB(170, 170, 170), // gray
        new RGB( 85,  85,  85), // dark gray
        new RGB(255,  85,  85), // bright red
        new RGB( 85, 255,  85), // bright green
        new RGB(255, 255,  85), // yellow
        new RGB( 85,  85, 255), // bright blue
        new RGB(255,  85, 255), // bright magenta
        new RGB( 85, 255, 255), // bright cyan
        new RGB(255, 255, 255)  // white
    ]

    val static RGB[] paletteVGA_dark = #[
        new RGB(  0,   0,   0), // black
        new RGB(170,   0,   0), // red
        new RGB(  0, 170,   0), // green
        new RGB(170,  85,   0), // brown/yellow
        new RGB(  0,   0, 170), // blue
        new RGB(170,   0, 170), // magenta
        new RGB( 10, 246, 250), // cyan
        new RGB(170, 170, 170), // gray
        new RGB( 85,  85,  85), // dark gray
        new RGB(255,  85,  85), // bright red
        new RGB( 85, 255,  85), // bright green
        new RGB(255, 255,  85), // yellow
        new RGB( 85,  85, 255), // bright blue
        new RGB(255,  85, 255), // bright magenta
        new RGB( 85, 255, 255), // bright cyan
        new RGB(255, 255, 255)  // white
    ]

    val static RGB[] paletteXP = #[
        new RGB(  0,   0,   0), // black
        new RGB(128,   0,   0), // red
        new RGB(  0, 128,   0), // green
        new RGB(128, 128,   0), // brown/yellow
        new RGB(  0,   0, 128), // blue
        new RGB(128,   0, 128), // magenta
        new RGB(  0, 102, 102), // cyan
        new RGB(192, 192, 192), // gray
        new RGB(128, 128, 128), // dark gray
        new RGB(255,   0,   0), // bright red
        new RGB(  0, 255,   0), // bright green
        new RGB(255, 255,   0), // yellow
        new RGB(  0,   0, 255), // bright blue
        new RGB(255,   0, 255), // bright magenta
        new RGB(  0, 255, 255), // bright cyan
        new RGB(255, 255, 255)  // white
    ]

    val static RGB[] paletteMac = #[
        new RGB(  0,   0,   0), // black
        new RGB(194,  54,  33), // red
        new RGB( 37, 188,  36), // green
        new RGB(173, 173,  39), // brown/yellow
        new RGB( 73,  46, 225), // blue
        new RGB(211,  56, 211), // magenta
        new RGB( 51, 102, 102), // cyan
        new RGB(203, 204, 205), // gray
        new RGB(129, 131, 131), // dark gray
        new RGB(252,  57,  31), // bright red
        new RGB( 49, 231,  34), // bright green
        new RGB(234, 236,  35), // yellow
        new RGB( 88,  51, 255), // bright blue
        new RGB(249,  53, 248), // bright magenta
        new RGB( 20, 240, 240), // bright cyan
        new RGB(233, 235, 235)  // white
    ]
    static val RGB[] palettePuTTY = #[
        new RGB(  0,   0,   0), // black
        new RGB(187,   0,   0), // red
        new RGB(  0, 187,   0), // green
        new RGB(187, 187,   0), // brown/yellow
        new RGB(  0,   0, 187), // blue
        new RGB(187,   0, 187), // magenta
        new RGB(  0, 102, 102), // cyan
        new RGB(187, 187, 187), // gray
        new RGB( 85,  85,  85), // dark gray
        new RGB(255,  85,  85), // bright red
        new RGB( 85, 255,  85), // bright green
        new RGB(255, 255,  85), // yellow
        new RGB( 85,  85, 255), // bright blue
        new RGB(255,  85, 255), // bright magenta
        new RGB( 85, 255, 255), // bright cyan
        new RGB(255, 255, 255)  // white
    ]

    static val RGB[] paletteXTerm_light = #[
        new RGB(  0,   0,   0), // black
        new RGB(205,   0,   0), // red
        new RGB(  0, 205,   0), // green
        new RGB(205, 205,   0), // brown/yellow
        new RGB(  0,   0, 238), // blue
        new RGB(205,   0, 205), // magenta
        new RGB(  0, 102, 102), // cyan
        new RGB(229, 229, 229), // gray
        new RGB(127, 127, 127), // dark gray
        new RGB(255,   0,   0), // bright red
        new RGB(  0, 255,   0), // bright green
        new RGB(255, 255,   0), // yellow
        new RGB( 92,  92, 255), // bright blue
        new RGB(255,   0, 255), // bright magenta
        new RGB(  0, 255, 255), // bright cyan
        new RGB(255, 255, 255)  // white
    ]
    
    static val RGB[] paletteXTerm_dark = #[
        new RGB(  0,   0,   0), // black
        new RGB(205,   0,   0), // red
        new RGB(  0, 205,   0), // green
        new RGB(205, 205,   0), // brown/yellow
        new RGB(  0,   0, 238), // blue
        new RGB(205,   0, 205), // magenta
        new RGB(  0, 205, 205), // cyan
        new RGB(229, 229, 229), // gray
        new RGB(127, 127, 127), // dark gray
        new RGB(255,   0,   0), // bright red
        new RGB(  0, 255,   0), // bright green
        new RGB(255, 255,   0), // yellow
        new RGB( 92,  92, 255), // bright blue
        new RGB(255,   0, 255), // bright magenta
        new RGB(  0, 255, 255), // bright cyan
        new RGB(255, 255, 255)  // white
    ]
    
    
    static var palette            = paletteXP
    static var currentPaletteName = PALETTE_WINXP

    def static int safe256(int value, int modulo) {
        val result = value * 256 / modulo
        if (result < 256) result else 255
    }

    def static getColor(Integer index) {
        if (null === index)
            return null

        if (index >= 0 && index < palette.length) // basic, 16 color palette
            return palette.get(index)

        if (index >= 16 && index < 232) { // 6x6x6 color matrix
            var color = index - 16
            val blue = color % 6
            
            color = color / 6
            val green = color % 6
            val red = color / 6

            return new RGB(safe256(red, 6), safe256(green, 6), safe256(blue, 6))
        }

        if (index >= 232 && index < 256) { // grayscale
            val gray = safe256(index - 232, 24)
            return new RGB(gray, gray, gray)
        }

        null
    }

    def static String getPalette() {
        currentPaletteName
    }

    def static void setPalette(String paletteName) {
        currentPaletteName = paletteName
        println("current palette name " + currentPaletteName)
        if (PALETTE_VGA.equalsIgnoreCase(paletteName))
            palette = if (environmentHasDarkTheme) paletteVGA_dark else paletteVGA_light
        else if (PALETTE_WINXP.equalsIgnoreCase(paletteName))
            palette = paletteXP
        else if (PALETTE_MAC.equalsIgnoreCase(paletteName))
            palette = paletteMac
        else if (PALETTE_PUTTY.equalsIgnoreCase(paletteName))
            palette = palettePuTTY
        else if (PALETTE_XTERM.equalsIgnoreCase(paletteName))
            palette = if (environmentHasDarkTheme) paletteXTerm_dark else paletteXTerm_light
        else {
            if (isOsWindows)
                setPalette(PALETTE_WINXP)
            else if (isOsMac)
                setPalette(PALETTE_MAC)
            else
                setPalette(PALETTE_XTERM)
        }
    }

}