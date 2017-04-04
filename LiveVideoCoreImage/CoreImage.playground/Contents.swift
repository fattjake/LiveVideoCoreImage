//: Playground - noun: a place where people can play

import UIKit
import CoreImage

let names = CIFilter.filterNames(inCategories: nil)


for name in names {
    let filter = CIFilter(name: name)
    print(name)
//    print(filter?.attributes)
}

let filter = CIFilter(name: "CICrystallize")

let additionFilter = CIFilter(name:"CIAdditionCompositing")
let edgeWorkFilter = CIFilter(name:"CIEdgeWork")

print(filter?.attributes)
print(additionFilter?.attributes)

if let path = Bundle.main.path(forResource: "mountain", ofType: "jpg"),
    let uiInputImage = UIImage(contentsOfFile: path),
    let cgInputImage = uiInputImage.cgImage,
    let filter = filter,
    let additionFilter = additionFilter,
    let edgeWorkFilter = edgeWorkFilter {
    
    let ciInputImage = CIImage(cgImage: cgInputImage)
    filter.setValue(ciInputImage, forKey: kCIInputImageKey)
    edgeWorkFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
    
    let filterImage = UIImage(ciImage: (filter.outputImage)!)
    let edgeWorkImage = UIImage(ciImage: (edgeWorkFilter.outputImage)!)
    
    additionFilter.setValue(filter.outputImage, forKey: kCIInputBackgroundImageKey)
    additionFilter.setValue(edgeWorkFilter.outputImage, forKey: kCIInputImageKey)
    
    let outputImage = UIImage(ciImage: (additionFilter.outputImage)!)
    
}
