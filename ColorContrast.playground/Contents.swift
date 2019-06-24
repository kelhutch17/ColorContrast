import UIKit

extension UIColor {
  static let minContrastRatio: CGFloat = 7.0
  
  /// Calculates the brightness of the receiver
  /// Returns nil if the color space of the receiver is not compatible
  func brightnessValue() -> CGFloat? {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    
    if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
      return b
    }
    
    return nil
  }
  
  /// Returns an updated version of the receiver with an adjusted brightness component
  /// that ensures the receiver and otherColor meet the minContrastRatio
  func adjustedColorForBestContrast(withColor otherColor: UIColor) -> UIColor {
    guard let contrastRatio = self.contrastRatio(withColor: otherColor), contrastRatio < UIColor.minContrastRatio else {
      return self
    }
    
    guard let adjustedBrightness =
      self.brightnessToMeetMinContrast(withColor: otherColor) else {
        return self
    }
    return self.adjustedColor(withNewBrightness: adjustedBrightness)
  }
  
  /// Formula for calculating the contrast ratio of two colors is:
  /// (b1 + 0.05) / (b2 + 0.05)
  /// where b1 and b2 are the brightness values of two colors, and b1 > b2
  func contrastRatio(withColor otherColor: UIColor) -> CGFloat? {
    guard let b1 = self.brightnessValue(), let b2 = otherColor.brightnessValue() else {
      return nil
    }
    
    if b1 > b2 {
      return (b1 + 0.05) / (b2 + 0.05)
    } else {
      return (b2 + 0.05) / (b1 + 0.05)
    }
  }
  
  /// Returns the brightness value needed to adjust the receiver color to meet the minContrastRatio
  /// when compared to otherColor
  func brightnessToMeetMinContrast(withColor otherColor: UIColor) -> CGFloat? {
    guard let b1 = self.brightnessValue(), let b2 = otherColor.brightnessValue() else {
      return nil
    }
    
    if b1 > b2 {
      return UIColor.minContrastRatio * (b2 + 0.05) - 0.05
    } else {
      return ((b2 + 0.05) / UIColor.minContrastRatio) + 0.05
    }
  }
  
  /// Returns a copy of the receiver with the brightness component changed to be
  /// the passed in brightness value
  func adjustedColor(withNewBrightness brightness: CGFloat) -> UIColor {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
      return UIColor(hue: h, saturation: s, brightness: brightness, alpha: a)
    }
    return self;
  }
}

// Test the code!
// color1 represents the foreground color that we will adjust if the contrast ratio is not high enough between color1 and color2
// color2 is the background color that will only be compared to and not changed

// Check contrast of black on top of white. Adjust the black color if the contrast is < 7
var color1 = UIColor.black
var color2 = UIColor.white
color1.contrastRatio(withColor: color2)
color1.adjustedColorForBestContrast(withColor: color2)    // No adjustment needed since contrast is 21, which is > 7


// Check contrast of yellow on top of white. Adjust the yellow color if the contrast is < 7
color1 = UIColor.yellow
color2 = UIColor.white
color1.adjustedColorForBestContrast(withColor: color2)  // Darken the yellow so the contrast is 7


// Check contrast of white on top of white. Adjust the foreground white color if the contrast is < 7
color1 = UIColor.white
color2 = UIColor.white
color1.adjustedColorForBestContrast(withColor: color2)  // Darken the foreground white so the contrast is 7


// Check contrast of a dark purple on top of black. Adjust the foreground purple color if the contrast is < 7
color1 = UIColor(hue: 0.8, saturation: 1, brightness: 0.15, alpha: 1)
color2 = UIColor.black
color1.adjustedColorForBestContrast(withColor: color2)  // Lighten the foreground color so the contrast is 7
