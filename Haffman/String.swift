//
//  String.swift
//  oit1
//
//  Created by dimam on 18.12.20.
//

import Foundation

extension String {
    func pad(string : String, toSize: Int) -> String {
      var padded = string
      for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
      }
        return padded
    }
}
