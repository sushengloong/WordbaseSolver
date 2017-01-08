//
//  ViewController.swift
//  WordbaseSolver
//
//  Created by Sheng Loong Su on 23/12/16.
//  Copyright © 2016 Su Sheng Loong. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    var words: [String]!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        let wordsLoader = WordsLoader()
        words = wordsLoader.loadFromFile().filter{ $0.characters.count >= 3 }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func browse(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let heightToCrop = CGFloat(440.0)
        let rect = CGRect(x: 0.0, y: heightToCrop, width: image.size.width, height: image.size.height - heightToCrop)
        let imageRef = image.cgImage!.cropping(to: rect)!
        image = UIImage(cgImage: imageRef)
        
        image = OpenCVWrapper.convert(image)
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        
        dismiss(animated: true, completion: nil)
        
        DispatchQueue.background(background: {
            let boardCharacters = self.performOCR(image: self.imageView.image!)
            
            let stopwatch = Stopwatch()
            let foundWords = self.searchWords(boardCharacters: boardCharacters)
            print("Search took \(stopwatch.elapsedTimeString())")
            
            print(foundWords)
        }, completion: {})
    }
    
    func performOCR(image: UIImage) -> [[Character]] {
        let tesseract = G8Tesseract(language: "eng")!
        tesseract.setVariableValue("ABCDEFGHIJKLMNOPQRSTUVWXYZ", forKey: kG8ParamTesseditCharWhitelist)
        tesseract.engineMode = .tesseractOnly
        tesseract.image = image
        tesseract.recognize()
        
        let text = tesseract.recognizedText!
//        let text = ["ENIONIMESA",
//                    "XESPOSOTOS",
//                    "CTELTFRURE",
//                    "AVANHESLON",
//                    "SHOUKSLWET",
//                    "IRCEOCHORN",
//                    "EHEGRICRUS",
//                    "NCLAIAGODP",
//                    "TOTITILRAE",
//                    "SERTVLTAIT",
//                    "WNMAEYEPSH",
//                    "ORGDTKITRG",
//                    "BAESOILUIF"].joined(separator: "\n")
        
        print(text)
        return text.components(separatedBy: "\n")
            .filter{ !$0.isEmpty }
            .map{ Array($0.characters) }
    }
    
    func searchWords(boardCharacters: [[Character]]) -> [String] {
        let N = words.count
        var foundWords = [String]()
        for i in 0..<N {
            let word = words[i]
            print("\(i+1) of \(N): \(word)")
            
            if containsWord(boardCharacters: boardCharacters, word: word) {
                print("***** Found in board! *****")
                foundWords.append(word)
            }
        }
        return foundWords
    }
    
    //https://github.com/bilash/boggle-solver/blob/master/Boggler.java
    func containsWord(boardCharacters: [[Character]], word: String) -> Bool {
        let dx = [1, 1, 0, -1, -1, -1, 0, 1]
        let dy = [0, 1, 1, 1, 0, -1, -1, -1]
        
        let characters = Array(word.characters)
        
        var dp = (0..<characters.count).map { _ in (0..<13).map { _ in (0..<10).map { _ in false }  } }
        
        for k in 0..<characters.count {
            for i in 0..<13 {
                for j in 0..<10 {
                    if (k == 0) {
                        dp[k][i][j] = true
                    } else {
                        for l in 0..<8 {
                            let x = i + dx[l]
                            let y = j + dy[l]
                            
                            if x >= 0 && x < 13
                                && y >= 0 && y < 10
                                && dp[k - 1][x][y]
                                && boardCharacters[i][j] == characters[k] {
                                dp[k][i][j] = true
                                if k == characters.count - 1 {
                                    return true
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        return false
    }

}

