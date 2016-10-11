

class TextDrawable {
	
    static func isIdeographic(value: UInt32) -> Bool {
        // https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_(Unicode_block)
        if (0x4E00 <= value && value <= 0x9FFF) {
            // Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS
            return true
        }
        
        if (0x3400 <= value && value <= 0x4DBF) {
            // Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A
            return true
        }
        
        if (0x20000 <= value && value <= 0x2A6DF) {
            // Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B
            return true
        }
        
        if (0x2A700 <= value && value <= 0x2B73F) {
            // Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_C
            return true
        }
        
        if (0x2B740 <= value && value <= 0x2B81F) {
            // Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_D
            return true
        }
        
        if (0x2B820 <= value && value <= 0x2CEAF) {
            // Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_E
            return true
        }
        
        if (0xFE30 <= value && value <= 0xFE4F) {
            // Character.UnicodeBlock.CJK_COMPATIBILITY_FORMS
            return true
        }
        
        if (0xF900 <= value && value <= 0xFAFF) {
            // Character.UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS
            return true
        }
        
        if (0x2E80 <= value && value <= 0x2EFF) {
            // Character.UnicodeBlock.CJK_RADICALS_SUPPLEMENT
            return true
        }
        
        if (0x3000 <= value && value <= 0x303F) {
            // Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION
            return true
        }
        
        if (0x3200 <= value && value <= 0x32FF) {
            // Character.UnicodeBlock.ENCLOSED_CJK_LETTERS_AND_MONTHS
            return true
        }
        
        return false
    }

}
