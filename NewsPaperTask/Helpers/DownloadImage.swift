//
//  DownloadImage.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import Foundation
import UIKit

func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error downloading image: \(error)")
            completion(nil)
            return
        }
        
        guard let data = data, let image = UIImage(data: data) else {
            print("Error converting data to image")
            completion(nil)
            return
        }
        
        DispatchQueue.main.async {
            completion(image)
        }
    }
    task.resume()
}
