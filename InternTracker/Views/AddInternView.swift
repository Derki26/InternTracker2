import SwiftUI

struct AddInternView: View {
    var onSave: (Intern) -> Void

    var body: some View {
        InternFormView(mode: .add, onSave: onSave)
    }
}

