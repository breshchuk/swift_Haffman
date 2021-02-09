//
//  BinaryTree.swift
//  oit1
//
//  Created by dimam on 29.10.20.
//

import Foundation

enum BinaryTree  {
  case empty
  indirect case node(BinaryTree, String, BinaryTree)
}

extension BinaryTree: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .node(left, value, right):
      return "value: \(value), left = [\(left.description)], right = [\(right.description)]"
    case .empty:
      return ""
    }
  }
}
  
extension BinaryTree {
    
    @discardableResult
    func search<T: StringProtocol>(searchValue: T, str: inout String) -> BinaryTree? {
      switch self {
      case .empty:
        return nil
      case let .node(left, value, right):
        if searchValue == value {
          return self
        }
            switch left {
            case let .node(_, v, _) where v.contains(searchValue):
                str.append("0")
                return left.search(searchValue: searchValue,str: &str)
            default:
                break
            }
            switch right {
            case let .node(_, v, _) where v.contains(searchValue):
                str.append("1")
                return right.search(searchValue: searchValue,str: &str)
            default:
                break
        }
      }
        return self
    }
}
