//
//  String+Extensions.swift
//  Eteration iOS Case Study
//
//  Created by Ege Girsen on 24.07.2025.
//

extension String {
    var toDouble: Double? {
        Double(self.replacingOccurrences(of: ",", with: "."))
    }
}
