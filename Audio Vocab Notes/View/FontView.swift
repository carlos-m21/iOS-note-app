//
//  FontView.swift
//  Vocabulary Audio Notes
//
//  Created by welcome on 1/6/21.
//

import SwiftUI

struct FontView: View {
    @EnvironmentObject var fontManager: FontManager
    
    @State var selectedFont: String?
    @State var fontSize: CGFloat = 12
    
    
    var body: some View {
        VStack {
            Spacer(minLength: 16)
            Text("Note Text")
                .font(Font.custom(selectedFont != "" ? selectedFont!: fontManager.fontNames[0], size: fontSize))
                .frame(height: 80)
            Spacer(minLength: 8)
            Section(header: Text("Font Size")) {
                Slider(value: $fontSize, in: 10...24, step: 2, onEditingChanged: { (_) in
                    fontManager.fontSize = fontSize
                }, minimumValueLabel: Text("10"), maximumValueLabel: Text("24")) {
                    Text("")
                }.padding(.horizontal)
            }
            List {
                ForEach(fontManager.fontNames, id: \.self) { item in
                    SelectionFontRow(font: item, isSelected: item == self.selectedFont!) {
                        self.selectedFont = item
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .onDisappear(perform: {
            fontManager.appFontName = selectedFont ?? ""
        })
    }
    
}

struct CheckmarkModifier: ViewModifier {
    var checked: Bool = false
    func body(content: Content) -> some View {
        Group {
            if checked {
                ZStack(alignment: .trailing) {
                    content
                    Image(systemName: "checkmark")
                        .shadow(radius: 1)
                }
            } else {
                content
            }
        }
    }
}

struct FontView_Previews: PreviewProvider {
    static var previews: some View {
        FontView()
    }
}

struct FixedPicker: UIViewRepresentable {
    class Coordinator : NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        @Binding var selection: Int
        
        var initialSelection: Int?
        var titleForRow: (Int) -> String
        var rowCount: Int

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            rowCount
        }
        
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            titleForRow(row)
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.selection = row
        }
        
        init(selection: Binding<Int>, titleForRow: @escaping (Int) -> String, rowCount: Int) {
            self.titleForRow = titleForRow
            self._selection = selection
            self.rowCount = rowCount
        }
    }
    
    @Binding var selection: Int
    
    var rowCount: Int
    let titleForRow: (Int) -> String

    func makeCoordinator() -> FixedPicker.Coordinator {
        return Coordinator(selection: $selection, titleForRow: titleForRow, rowCount: rowCount)
    }

    func makeUIView(context: UIViewRepresentableContext<FixedPicker>) -> UIPickerView {
        let view = UIPickerView()
        view.delegate = context.coordinator
        view.dataSource = context.coordinator
        return view
    }
    
    func updateUIView(_ uiView: UIPickerView, context: UIViewRepresentableContext<FixedPicker>) {
        
        context.coordinator.titleForRow = self.titleForRow
        context.coordinator.rowCount = rowCount

        // This is the key part. If the updated value is the same as the one
        // we started with, we just ignore it.
        if context.coordinator.initialSelection != selection {
            uiView.selectRow(selection, inComponent: 0, animated: true)
            context.coordinator.initialSelection = selection
        }
    }
}

struct FastPicker_Previews: PreviewProvider {
    @State static var selection = 0
    static var previews: some View {
        FixedPicker(selection: $selection, rowCount: 500, titleForRow: {"\($0)"})
    }
}
