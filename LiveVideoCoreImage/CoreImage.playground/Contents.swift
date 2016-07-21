//: Playground - noun: a place where people can play

import UIKit
import CoreImage

let names = CIFilter.filterNamesInCategories(nil)


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

if let path = NSBundle.mainBundle().pathForResource("mountain", ofType: "jpg"),
    let uiInputImage = UIImage(contentsOfFile: path),
    let cgInputImage = uiInputImage.CGImage,
    let filter = filter,
    let additionFilter = additionFilter,
    let edgeWorkFilter = edgeWorkFilter {
    
    let ciInputImage = CIImage(CGImage: cgInputImage)
    filter.setValue(ciInputImage, forKey: kCIInputImageKey)
    edgeWorkFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
    
    let filterImage = UIImage(CIImage: (filter.outputImage)!)
    let edgeWorkImage = UIImage(CIImage: (edgeWorkFilter.outputImage)!)
    
    additionFilter.setValue(filter.outputImage, forKey: kCIInputBackgroundImageKey)
    additionFilter.setValue(edgeWorkFilter.outputImage, forKey: kCIInputImageKey)
    
    let outputImage = UIImage(CIImage: (additionFilter.outputImage)!)
    
}
