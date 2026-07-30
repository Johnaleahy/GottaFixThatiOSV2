//
//  Color+Extension.swift
//  GottaFixThat
//
//  Created on 1/20/26.
//

import SwiftUI
import UIKit

extension Color {
    // Blues
    static let blueDark = Color(hex: "002e56")
    static let blueMedium = Color(hex: "597b9e")
    static let blueLight = Color(hex: "9dafc7")
    static let blueNight = Color(hex: "0c223d")

    // Grays
    static let grayDark = Color(hex: "404040")
    static let grayMedium = Color(hex: "bfbfbf")
    static let grayLight = Color(hex: "ebebeb")
    static let grayCard = Color(hex: "1f2d3d")

    // Greens
    static let greenAccent = Color(hex: "9aca3c")
    static let greenLight = Color(hex: "f2f7e8")

    static let dynamicPageBackground = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 12 / 255, green: 34 / 255, blue: 61 / 255, alpha: 1)
                : .systemGroupedBackground
        }
    )

    static let dynamicCardBackground = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 31 / 255, green: 45 / 255, blue: 61 / 255, alpha: 1)
                : .systemBackground
        }
    )

    static let dynamicHeaderCardBackground = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 18 / 255, green: 40 / 255, blue: 68 / 255, alpha: 1)
                : .systemBackground
        }
    )

    static let dynamicFieldBackground = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 23 / 255, green: 51 / 255, blue: 82 / 255, alpha: 1)
                : .secondarySystemBackground
        }
    )

    static let dynamicPrimaryText = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : .label
        }
    )

    static let dynamicSecondaryText = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.78)
                : .secondaryLabel
        }
    )

    static let dynamicTertiaryText = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 190 / 255, green: 204 / 255, blue: 220 / 255, alpha: 1)
                : .tertiaryLabel
        }
    )

    static let dynamicDivider = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(white: 1.0, alpha: 0.10)
                : .separator
        }
    )

    static let dynamicShadow = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor.black.withAlphaComponent(0.35)
                : UIColor.black.withAlphaComponent(0.12)
        }
    )
}

// Hex initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
