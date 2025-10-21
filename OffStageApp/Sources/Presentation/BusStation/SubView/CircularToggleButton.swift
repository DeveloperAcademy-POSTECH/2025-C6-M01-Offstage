//
//  CircularToggleButton.swift
//  OffStage
//
//  Created by Murphy on 10/21/25.
//
import SwiftUI

struct CircularToggleButton: View {
    @Binding var isOn: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.1)) {
                isOn.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(isOn ? Color.blue : Color.clear)
                    .stroke(Color.gray.opacity(0.4))
                    .frame(width: 48, height: 48)

                if !isOn {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 48, height: 48)
                }
                Image(systemName: isOn ? "pin.fill" : "pin")
                    .foregroundColor(isOn ? .white : .gray.opacity(0.6))
                    .font(.system(size: 24, weight: .regular))
            }
        }
    }
}
