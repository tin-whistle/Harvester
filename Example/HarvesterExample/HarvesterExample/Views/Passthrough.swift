//
//  Passthrough.swift
//  HarvesterExample
//
//  Created by Paul Himes on 10/30/19.
//  Copyright © 2019 Paul Himes. All rights reserved.
//

import SwiftUI

struct Passthrough<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
    }
}

struct Passthrough_Previews: PreviewProvider {
    static var previews: some View {
        Passthrough {
            Text("Text")
        }
    }
}
