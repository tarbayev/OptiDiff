// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "OptiDiff",
  platforms: [
    .iOS(.v11)
  ],
  products: [
    .library(name: "OptiDiff", targets: ["OptiDiff"]),
    .library(name: "OptiDiff-UI", targets: ["OptiDiff-UI"])
  ],
  targets: [
    .target(
      name: "OptiDiff",
      dependencies: [],
      path: "Sources/Diff"
    ),
    .target(
      name: "OptiDiff-UI",
      dependencies: ["OptiDiff"],
      path: "Sources/UI"
    ),
    .testTarget(
      name: "OptiDiffTests",
      dependencies: ["OptiDiff"],
      path: "Tests/"
    )
  ]
)
