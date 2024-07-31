//
//  DownloadImage.swift
//  NewsPaperTask
//
//  Created by Leandro Oliveira on 2024-07-31.
//

import Foundation
import UIKit

func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(nil)
            return
        }
        
        guard let data = data, let image = UIImage(data: data) else {
            completion(nil)
            return
        }

        DispatchQueue.main.async {
            completion(image)
        }
    }.resume()
}
