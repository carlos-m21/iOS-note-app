import SwiftUI
import AVFoundation
import CoreMedia

struct MainListRow: View {
    @EnvironmentObject var fontManager: FontManager
    var data: Folder

    @State var rowHeight: CGFloat = 0
    var body: some View {
        HStack {
            Image(systemName: "folder").foregroundColor(.yellow)
            Text(data.title)
                .font(fontManager.appfont)
            Spacer()
            Text("\(data.count)").padding(.trailing, 8)
        }
        .frame(minHeight: self.rowHeight)  // set height as max height
        .background(
            GeometryReader{ (proxy) in
                Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
        })
        .onPreferenceChange(SizePreferenceKey.self) { (preferences) in
            let currentSize: CGSize = preferences
            if (currentSize.height > self.rowHeight) {
                self.rowHeight = currentSize.height
            }
        }
    }
}


struct NoteRow: View {
    @State var rowHeight: CGFloat = 0
    @EnvironmentObject var fontManager: FontManager

    var data: Note
    var isSelected: Bool
    var isLoop: Bool
    var isEdit: Bool
    var onEdit: (Bool) -> () = {_ in}
    var onTap: (Bool) -> () = {_ in}

    var body: some View {
        HStack {
            HStack {
                Text(data.text)
                    .font(fontManager.appfont)
                    .foregroundColor(isSelected ? Color.blue: Color(.label))
                    .frame(minHeight: self.rowHeight)
                Spacer()
            }
            .background(
                GeometryReader{ (proxy) in
                    Color(.secondarySystemGroupedBackground).preference(key: SizePreferenceKey.self, value: proxy.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { (preferences) in
                let currentSize: CGSize = preferences
                if (currentSize.height > self.rowHeight) {
                    self.rowHeight = currentSize.height
                }
            }
            .onTapGesture {
                onTap(isSelected)
            }
            if data.file != "" {
                if !isEdit {
                    HStack {
                        Text(getLength(data.file))
                            .font(.caption)
                            .foregroundColor(isSelected ? Color.blue: Color(.label))

                        Image(systemName: "repeat")
                            .foregroundColor(isLoop && isSelected ? Color.blue: Color(.label))
                            .onTapGesture {
                                print("Tap repeat")
                                print("isLoop -> \(isLoop)")
                                onEdit(true)
                            }
                    }
                }
            }
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: Value = .zero

    static func reduce(value: inout Value, nextValue: () -> Value) {
        _ = nextValue()
    }
}

struct SelectionRow: View {
    var folder: Folder
    var isSelected: Bool
    var action: () -> Void
    @State var rowHeight: CGFloat = 0
    var body: some View {
        Button(action: self.action) {
            HStack {
                Image(systemName: "folder").foregroundColor(.yellow)
                Text(folder.title)
                Spacer()
                Text("\(folder.count)").padding(.trailing, 8)
                if self.isSelected {
                    Image(systemName: "checkmark").padding(.leading, 8)
                }
            }
            .frame(minHeight: self.rowHeight)  // set height as max height
            .background(
                GeometryReader{ (proxy) in
                    Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { (preferences) in
                let currentSize: CGSize = preferences
                if (currentSize.height > self.rowHeight) {
                    self.rowHeight = currentSize.height
                }
            }
        }
    }
}

struct SelectionFontRow: View {
    var font: String
    var isSelected: Bool
    var action: () -> Void
    @State var rowHeight: CGFloat = 0
    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(font)
                    .font(Font.custom(font, size: 14))
                Spacer()
                if self.isSelected {
                    Image(systemName: "checkmark").padding(.leading, 8)
                }
            }
            .frame(minHeight: self.rowHeight)  // set height as max height
            .background(
                GeometryReader{ (proxy) in
                    Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            })
            .onPreferenceChange(SizePreferenceKey.self) { (preferences) in
                let currentSize: CGSize = preferences
                if (currentSize.height > self.rowHeight) {
                    self.rowHeight = currentSize.height
                }
            }
        }
    }
}


