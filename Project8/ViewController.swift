//
//  ViewController.swift
//  Project8
//
//  Created by Melissa  Garrett on 2/11/17.
//  Copyright © 2017 MelissaGarrett. All rights reserved.
//

import UIKit
import GameplayKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswer: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton]() // the 20 buttons, each with a label containing characters
    var activatedButtons = [UIButton]() // the buttons already used/guessed
    var solutions = [String]() // the 7 answers as complete strings, one string per index
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score \(score)"
        }
    }
    
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Creating outlets/actions for the 20 buttons instead of through Storyboard.
        // for each button with a tag of 1001, append to letterButtons array and add target method
        for subview in view.subviews where subview.tag == 1001 {
            let btn = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
        
        loadLevel()
    }
    
    func letterTapped(btn: UIButton) {
        currentAnswer.text = currentAnswer.text! + btn.titleLabel!.text!
        activatedButtons.append(btn)
        btn.isHidden = true
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        // Only continue if the answer submitted was correct
        if let solutionPosition = solutions.index(of: currentAnswer.text!) {
            activatedButtons.removeAll()
            
            // Use solutionPosition to find matching string to replace the hint on the UI
            var splitClues = answersLabel.text!.components(separatedBy: "\n") // it's one long string
            splitClues[solutionPosition] = currentAnswer.text! // ex "7 letters" becomes "Twitter"
            answersLabel.text = splitClues.joined(separator: "\n") // re-write the whole string to UI
            
            currentAnswer.text = ""
            score += 1
            
            // User won that level by getting all 7 correct
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        }
    }
    
    // User taps Clear after an incorrect guess is submitted
    @IBAction func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        
        for btn in activatedButtons {
            btn.isHidden = false
        }
        
        activatedButtons.removeAll()
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = Bundle.main.path(forResource: "level\(level)", ofType: "txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath) {
                var lines = levelContents.components(separatedBy: "\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: lines) as! [String]
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionString += "\(solutionWord.characters.count) letters\n" // the hint
                    solutions.append(solutionWord) // complete words without the '|'
                    
                    let bits = answer.components(separatedBy: "|")
                    letterBits += bits // an array with 2- and 3-character groupings for buttons
                }
            }
        }
        
        // configure the buttons and labels
        
        // these are one big long string, with one clue or answer on each line of text fields
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: letterBits) as! [String]
        
        // assign letter groupings to each button
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterBits.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }
    
    // Start a new game after current game was won
    func levelUp(action: UIAlertAction) {
        // Uncomment this after adding additional level.txt files
        //level += 1
        
        solutions.removeAll(keepingCapacity: true)
        
        loadLevel()
        
        for btn in letterButtons {
            btn.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

