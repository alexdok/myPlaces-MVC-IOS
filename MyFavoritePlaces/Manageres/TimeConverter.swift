//
//  TimeConverter.swift
//  MyFavoritePlaces
//
//  Created by алексей ганзицкий on 22.08.2023.
//

import Foundation

class TimeConverter {

    func convertSecondsToHMS(seconds: Int) -> String {
         let hours = seconds / 3600
         let minutes = (seconds % 3600) / 60
         let seconds = (seconds % 3600) % 60
         return String(format: "%2dh %2dm %2ds", hours, minutes, seconds)
     }
}
