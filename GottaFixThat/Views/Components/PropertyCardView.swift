//
//  PropertyCardView.swift
//  GottaFixThat
//
//  Created on 1/27/26.
//

import SwiftUI
import SwiftData

struct PropertyCardView: View {
    let property: Property
    @Environment(\.colorScheme) private var colorScheme

    private var titleColor: Color {
        colorScheme == .dark ? .white : .blueDark
    }

    private var cardBackgroundColor: Color {
        colorScheme == .dark ? .blueNight : Color(.systemBackground)
    }

    private var chevronColor: Color {
        colorScheme == .dark ? .greenAccent : .blueMedium
    }

    var body: some View {
        VStack(spacing: 0) {
            // Property Image
            propertyImage
                .aspectRatio(16/10, contentMode: .fill)
                .frame(height: 180)
                .clipped()

            // Property Info Section
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(titleColor)

                    Text("\(property.itemCount) items")
                        .font(.subheadline)
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.78) : .secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(chevronColor)
            }
            .padding()
            .background(cardBackgroundColor)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }

    @ViewBuilder
    private var propertyImage: some View {
        if let assetName = property.assetImageName {
            Image(assetName)
                .resizable()
        } else if let imageData = property.imageData,
                  let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image(systemName: "house.fill")
                .resizable()
                .padding(40)
                .foregroundStyle(.secondary)
                .background(Color(.secondarySystemBackground))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach(Property.sampleProperties, id: \.id) { property in
            PropertyCardView(property: property)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
