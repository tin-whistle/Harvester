import Foundation

extension DateFormatter {
    static let harvestDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE d MMM",
                                                        options: 0,
                                                        locale: Locale.autoupdatingCurrent)
        return formatter
    }()
}

extension DateComponentsFormatter {
    static let harvestTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}

extension Double {
    func hourComponentFromHours() -> Int {
        Int(rounded(.towardZero))
    }

    func minuteComponentFromHours() -> Int {
        let wholeHours = rounded(.towardZero)
        return Int(((self - wholeHours) * 60).rounded(.toNearestOrEven))
    }

    func formattedHours() -> String {
        return "\(hourComponentFromHours()):\(String(format: "%02d", minuteComponentFromHours()))"
    }
}
