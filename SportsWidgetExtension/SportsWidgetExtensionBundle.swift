//
//  SportsWidgetExtensionBundle.swift
//  SportsWidgetExtension
//
//  Created by Jason Davison on 1/29/26.
//

import WidgetKit
import SwiftUI

@main
struct SportsWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        // Original static widget (uses app-selected teams)
        SportsScheduleWidget()
        // Configurable widget (allows widget-level team selection)
        ConfigurableSportsScheduleWidget()
    }
}
