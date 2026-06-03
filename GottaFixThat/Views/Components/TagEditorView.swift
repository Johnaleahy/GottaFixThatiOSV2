//
//  TagEditorView.swift
//  GottaFixThat
//
//  Created on 2/1/26.
//

import SwiftUI

struct TagEditorView: View {
    @Binding var tags: [String]
    @State private var newTag: String = ""
    @FocusState private var isAddingTag: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Existing tags as chips
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag: tag) {
                            removeTag(tag)
                        }
                    }
                }
            }

            // Add new tag
            HStack {
                TextField("Add tag...", text: $newTag)
                    .textInputAutocapitalization(.characters)
                    .focused($isAddingTag)
                    .onSubmit {
                        addTag()
                    }

                Button(action: addTag) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.greenAccent)
                }
                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespaces).uppercased()
        guard !trimmedTag.isEmpty, !tags.contains(trimmedTag) else {
            newTag = ""
            return
        }

        withAnimation {
            tags.append(trimmedTag)
        }
        newTag = ""
    }

    private func removeTag(_ tag: String) {
        withAnimation {
            tags.removeAll { $0 == tag }
        }
    }
}

// MARK: - Tag Chip View

struct TagChip: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.greenAccent.opacity(0.15))
        .foregroundColor(.greenAccent)
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}

#Preview {
    @Previewable @State var tags = ["KITCHEN", "URGENT", "PLUMBING"]

    Form {
        Section("Tags") {
            TagEditorView(tags: $tags)
        }
    }
}
