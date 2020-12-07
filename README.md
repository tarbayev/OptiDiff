# OptiDiff

A library for calculating optimal collection diffs using a [LIS](https://en.wikipedia.org/wiki/Longest_increasing_subsequence)-based algorithm 
with **O(n log₂ n)** worst case total time. It produces an optimal diff with minimal required changes, equivalent or very close 
to the result of Myers algorithm (which has a higher complexity of **O(n²)**) used in Swift standard library.


## Table View Animated Updates

`sectionedDifference` method produces a diff between sectioned collections, which can be used to perform animated updates in `UITableView`, 
using `performUpdates(with:animations:completion:)` extension method. 

Unlike many other libraries, this method performs updates in a **single** `performBatchUpdates` call. Therefore the updates look much smoother.


## Installation

The library supports *SwiftPackageManager* and *CocoaPods*.


Created by Nickolay Tarbayev (tarbayev-n@yandex.ru). Released under the **Unlicense** license, see [LICENSE](LICENSE.md) file for details.
