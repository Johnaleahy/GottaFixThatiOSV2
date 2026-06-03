//
//  SquareCheckboxView.swift
//  GottaFixThat
//
//  Created on 4/3/26.
//

import SwiftUI

struct SquareCheckboxView: View {
    let isChecked: Bool
    var size: CGFloat = 22

    var body: some View {
        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(isChecked ? Color.greenAccent : Color.grayMedium)
    }
}

#Preview {
    HStack(spacing: 20) {
        SquareCheckboxView(isChecked: false)
        SquareCheckboxView(isChecked: true)
    }
    .padding()
}
