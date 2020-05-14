//
//  SecondViewController.swift
//  SimonSays_Memory
//
//  Created by Sydney Ripsky on 5/14/20.
//  Copyright © 2020 Two Berliners. All rights reserved.
//


    
    import UIKit
    import AVFoundation

    let kDelayBetweenStages = 0.75
    let kPlayDuration = 0.4
    let kHighScoreKey = "HighScore"


    class SecondViewController: UIViewController {

      @IBOutlet weak var highScoreLabel: UILabel!

      @IBOutlet weak var progressBarBackView: UIView!
      @IBOutlet weak var progressBarFrontView: UIView!

     
      @IBOutlet weak var startBtn: UIButton!
      @IBOutlet weak var darkModeSwitch: UISwitch!

        @IBOutlet weak var btn0: UIButton!
        @IBOutlet weak var btn1: UIButton!
        @IBOutlet weak var btn2: UIButton!
        @IBOutlet weak var btn3: UIButton!
        
        
        
        let userDefault = UserDefaults.standard
      var correctAnswers: [Int] = []
      var userInputs: [Int] = []
      var playedIdx = 0
      var inputIdx = 0
      var stage = 0
      var highScore: Int {
        get {
          return userDefault.integer(forKey: kHighScoreKey)
        }
        set {
          userDefault.set(newValue, forKey: kHighScoreKey)
          userDefault.synchronize()
          highScoreLabel.text = "\(newValue)"
        }
      }

      var isCorrectAnswer: Bool {
        return userInputs == correctAnswers
      }
      var timeLimit: Double = 8
      
      override func viewDidLoad() {
        super.viewDidLoad()
        highScoreLabel.text = "\(highScore)"
        enableAllBtns(false)


        func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        for v in [startBtn] {
          guard let v = v else { return }
          v.layer.cornerRadius = v.frame.height / 2
        }


      }
      }

      @IBAction func startBtnTapped(_ sender: UIButton) {
        enableStartBtn(false)
        newGame()
        nextStage()
      }

      func newGame() {
        correctAnswers.removeAll()
        playedIdx = 0
        stage = 0
        clearUserInputs()
      }

      func clearUserInputs() {
        userInputs.removeAll()
        inputIdx = 0
      }

      func nextStage() {
        clearUserInputs()
        correctAnswers.append(Int(arc4random_uniform(4)))
        print("correctAnswer \(correctAnswers)")

        DispatchQueue.main.asyncAfter(deadline: .now() + kDelayBetweenStages) {
          self.stage += 1
          self.timeLimit += 1.5
          print("timeLimit: \(self.timeLimit)")
          self.startBtn.setTitle("\(self.stage)", for: .normal)
        }

        playedIdx = 0
        enableAllBtns(false)
        DispatchQueue.main.asyncAfter(deadline: .now() + (kDelayBetweenStages + 1.0)) {
          self.playAnswer()
        }
      }

      func playAnswer() {
        guard playedIdx < correctAnswers.count else {
          playedIdx = 0
          enableAllBtns(true)
            return
        }

        let answer = correctAnswers[playedIdx]
        let btn = btnFromAnswer(answer)
        flashBtn(btn) {_ in
          self.playedIdx += 1
          self.playAnswer()
        }
      }

      func flashBtn(_ btn: UIButton, completion: ((Bool) -> Void)? = nil) {
        btn.alpha = 0.3
        let answer = answerFromBtn(btn)
        UIView.animate(
          withDuration: kPlayDuration,
          delay: 0.0,
          options: .curveEaseInOut,
          animations: {
            btn.alpha = 1
          },
          completion: completion
        )
      }

      @IBAction func btnDown(_ sender: UIButton) {
        let guess = answerFromBtn(sender)
        sender.alpha = 0.3
      }

      @IBAction func btnUp(_ sender: UIButton) {
        let guess = answerFromBtn(sender)
        userInputs.append(guess)
        print("userInputs: \(userInputs)")

        if guess == correctAnswers[inputIdx] {
          inputIdx += 1
          if isCorrectAnswer {
            nextStage()
          }
        } else {
          endGame()
        }

        sender.alpha = 1
      }

      func endGame() {
        enableAllBtns(false)
        enableStartBtn(true)
        
        timeLimit = 8
        let finalScore = stage - 1
        let highestScore = finalScore > highScore ? finalScore : highScore
        highScore = highestScore
        startBtn.setTitle("\(finalScore)", for: .normal)
        print("gameEnd")
        displayMessage(message: "You lost!")
       
      }


      func answerFromBtn(_ from: UIButton) -> Int {
        return from.tag
      }

      func btnFromAnswer(_ from: Int) -> UIButton {
        switch from {
        case 0:
          return btn0
        case 1:
          return btn1
        case 2:
          return btn2
        case 3:
          return btn3
        default:
          fatalError()
        }
      }

      func enableAllBtns(_ enabled: Bool) {
        btn0.isEnabled = enabled
        btn1.isEnabled = enabled
        btn2.isEnabled = enabled
        btn3.isEnabled = enabled
      }

      func enableStartBtn(_ enabled: Bool) {
        startBtn.isEnabled = enabled
      }

        func displayMessage(message: String) {
            let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Reset", style: .default)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
            self.startBtn.setTitle("Go", for: .normal)
        }



    }


