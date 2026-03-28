//
//  SplashView.swift
//  mydevice
//
//  Created by Mehmet Karagöz on 27/03/2026.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
            .overlay {
                Image("LaunchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
    }
}
