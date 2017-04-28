// import Swift
// import Foundation
// // // enum X {
// // //   enum Y {
// // //     case nils
// // //   }
// // //
// // //   case p(Y)
// // // }
// // //
// // // enum Z {
// // //   enum Y {
// // //     case pelle
// // //   }
// // //   case p(Y)
// // // }
// // //
// // // let x: X = .p(.nils)
// // // let z: Z = .p(.pelle)
// // //
// // // enum P {
// // //
// // // }
// // //
// // // enum U {
// // //
// // //
// // // }
// // //
// // // enum R: U, P {
// // //
// // // }
// //
// // class ABS {
// //
// // }
// //
// // extension ABS {
// //   static let hello = "ok"
// // }
//
// enum X {
//   case y(String)
//   case p
// }
//
// print(type(of: X.y))
//
// func x(y: (String) -> X) {
//
// }
// //
// // x(y: X.y)
//
// // print(String(describing: X.y("OKOK")))
// // let i = X.y("aa")
// let i = X.p
// print(String(describing: i).components(separatedBy: ["("])[0])

// let x = (1, 2)
//
// func y(_ a: Int, _ b: Int) {
//   print(a)
//   print(b)
// }
//
// y(x)

func hello(a: Int = 0, b: Int = 1, c: Int = 20) {
  print(a + b + c)
}

hello(b: 10)
hello(a: 2, b: 10)
hello(c: 2)
