//
//  AppUtils.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/12/24.
//

class AppUtils {
    static let shared = AppUtils()
    
    private init() {}
    
    func saveImageToFile(imagePath: String) {
        guard let image = UIImage(contentsOfFile: imagePath) else { return }
        
        // 计算自适应的高度
        let targetSize = calculateAspectRatioSize(image: image, targetWidth: 100)
        
        // 缩放图像
        let resizedImage = resizeImage(image: image, targetSize: targetSize)
        
        let fileURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: widgetGroupId
        )?.appendingPathComponent("sharedImage.png")
        
        if let data = resizedImage.pngData() {
            do {
                try data.write(to: fileURL!)
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        // 提取图片主颜色
        if let color = image.dominantColor() {
            let userDefaults = UserDefaults(suiteName: widgetGroupId)
            userDefaults?.set("\(color.red),\(color.green),\(color.blue)", forKey: "bgColor")
            userDefaults?.synchronize()
        }
    }
    
    func calculateAspectRatioSize(image: UIImage, targetWidth: CGFloat) -> CGSize {
        let aspectRatio = image.size.height / image.size.width
        let targetHeight = targetWidth * aspectRatio
        return CGSize(width: targetWidth, height: targetHeight)
    }

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension UIImage {
    func dominantColor() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 1
        let height = 1
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(cgImage.width), height: CGFloat(cgImage.height)))
        guard let data = context.data else { return nil }
        let pixel = data.bindMemory(to: UInt8.self, capacity: 3)
        return (red: CGFloat(pixel[0]), green: CGFloat(pixel[1]), blue: CGFloat(pixel[2]))
    }
}
