//
//  ViewController.swift
//  PitchDetection
//
//  Created by Josh Morrison on 8/24/20.
//  Copyright © 2020 Josh Morrison. All rights reserved.
//

import UIKit
import AudioKit

class myPitch: UIViewController {
    
    @IBOutlet weak var pitchDetectionLabel: UILabel!
    @IBOutlet weak var frequencyDebugLabel: UILabel!
    @IBOutlet weak var amplitudeDebugLabel: UILabel!
    
    let Notes = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]
    
    var timer = Timer()
    let noiseGateThreshold: Double = 0.1 // The threshold to determine at what loudness the microphone will begin picking up sound
    let timerCycle:Double = 0.05 // the amount of time between each time the function to determinePitch() is called
    let frequencyError:Double = 1 // the room for error on the frequency calculations

    let mic = AKMicrophone()

    lazy var tracker = AKFrequencyTracker(mic, hopSize: 4_096, peakCount: 20)
    lazy var silence = AKBooster(tracker, gain: 0)


    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = silence
        do {
            try AudioKit.start()
            pitchDetection()
            Timer.scheduledTimer(withTimeInterval: self.timerCycle, repeats: true) { timer in // Timer executes every 1/10 of a second
                if(self.tracker.amplitude > self.noiseGateThreshold){ // The amplitude is the loudness of the noise. Therefore, if th eloudness of the noise in the microphone is greater than the given threshold then the microphone will pick it up. (noise gate)
                    self.pitchDetection()
                }else{
                    self.amplitudeDebugLabel.text = "amplitude: 0.00"
                }
            }
        }catch{
            print("error")
        }
        
    }

    func pitchDetection(){
        frequencyDebugLabel.text = "frequency: " + String(tracker.frequency)
        amplitudeDebugLabel.text = "amplitude: " + String(tracker.amplitude)
        
        // Calculate the octave of the note
        var noteOctaveLowerBound: [Double] = []
        var noteOctaveUpperBound: [Double] = []
        var octave: Int = 0
        for i in 0...8{
            noteOctaveLowerBound.append(16.25 * pow(2.0,Double(i)))
            noteOctaveUpperBound.append(30.87 * pow(2.0,Double(i)))
        }
        
        //print("noteOctaveLowerBound: ", noteOctaveLowerBound)
        //print("noteOctaveUpperBound: ", noteOctaveUpperBound)
        
        for i in 0...8 {
            if(tracker.frequency >= noteOctaveLowerBound[i] && tracker.frequency <= noteOctaveUpperBound[i]){
                octave = i
                print("Ocatave: ", i)
            }
        }
        
        // Get middle A of the octave we are on
        let middleA = 440 * pow(2, (octave - 5))
        print("middleA: ", middleA)
        
        // Calculate the frequency from middleA
        var octaveFrequencies: [Double] = []
        for i in 3...14{
            let middleACalculation = middleA * pow(2, i / 12)
            octaveFrequencies.append(middleACalculation)
        }
        
        print("octaveFrequencies: ", octaveFrequencies)
        
        // Find the closest value in the octaveFrequencies array
        var smallestValue:Double = 0
        var biggestValue:Double = 10000
        for each in octaveFrequencies{
            //let upperNLower: [Double] = []
            if(tracker.frequency >= each && each > smallestValue){
                smallestValue = each
            }
            if(tracker.frequency <= each && each < biggestValue){
                biggestValue = each
            }
        }
        var closest:Double = 0
        let closestBig = abs(biggestValue - tracker.frequency)
        let closestSmall = abs(smallestValue - tracker.frequency)
        if(closestBig < closestSmall){
            closest = biggestValue
        }else{
            closest = smallestValue
        }
        print("BIG: ", biggestValue)
        print("SMALL: ", smallestValue)
        print("CLOSEST: ", closest)
        
        // Get the index of the closest value
        let index = octaveFrequencies.firstIndex(of: closest)
        print(index)
        pitchDetectionLabel.text = Notes[index ?? 0]
        
        
        
//        if(tracker.frequency.truncatingRemainder(dividingBy: 16.25) <= self.frequencyError){
//            pitchDetectionLabel.text = "C"
//            print(16.25 * pow(2.0,Double(octave)))
//            //print("C: ", tracker.frequency.truncatingRemainder(dividingBy: 16.25))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 17.32) <= self.frequencyError){
//            pitchDetectionLabel.text = "C#"
//            print(17.32 * pow(2.0,Double(octave)))
//            //print("C#: ", tracker.frequency.truncatingRemainder(dividingBy: 17.32))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 18.35) <= self.frequencyError){
//            pitchDetectionLabel.text = "D"
//            print(18.35 * pow(2.0,Double(octave)))
//            //print("D: ", tracker.frequency.truncatingRemainder(dividingBy: 18.35))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 19.45) <= self.frequencyError){
//            pitchDetectionLabel.text = "D#"
//            print(19.45 * pow(2.0,Double(octave)))
//            //print("D#: ", tracker.frequency.truncatingRemainder(dividingBy: 19.45))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 20.60) <= self.frequencyError){
//            pitchDetectionLabel.text = "E"
//            print(20.60 * pow(2.0,Double(octave)))
//            //print("E: ", tracker.frequency.truncatingRemainder(dividingBy: 20.60))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 21.83) <= self.frequencyError){
//            pitchDetectionLabel.text = "F"
//            print(21.83 * pow(2.0,Double(octave)))
//            //print("F: ", tracker.frequency.truncatingRemainder(dividingBy: 21.83))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 23.12) <= self.frequencyError){
//            pitchDetectionLabel.text = "F#"
//            print(23.12 * pow(2.0,Double(octave)))
//            //print("F#: ", tracker.frequency.truncatingRemainder(dividingBy: 23.12))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 24.50) <= self.frequencyError){
//            pitchDetectionLabel.text = "G"
//            print(24.50 * pow(2.0,Double(octave)))
//            //print("G: ", tracker.frequency.truncatingRemainder(dividingBy: 24.50))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 25.96) <= self.frequencyError){
//            pitchDetectionLabel.text = "G#"
//            print(25.96 * pow(2.0,Double(octave)))
//            //print("G#: ", tracker.frequency.truncatingRemainder(dividingBy: 25.96))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 27.50) <= self.frequencyError){
//            pitchDetectionLabel.text = "A"
//            print(27.50 * pow(2.0,Double(octave)))
//            //print("A: ", tracker.frequency.truncatingRemainder(dividingBy: 27.50))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 29.14) <= self.frequencyError){
//            pitchDetectionLabel.text = "A#"
//            print(29.14 * pow(2.0,Double(octave)))
//            //print("A#: ", tracker.frequency.truncatingRemainder(dividingBy: 29.14))
//        }else if(tracker.frequency.truncatingRemainder(dividingBy: 30.87) <= self.frequencyError){
//            pitchDetectionLabel.text = "B"
//            print(30.87 * pow(2.0,Double(octave)))
//            //print("B: ", tracker.frequency.truncatingRemainder(dividingBy: 30.87))
//        }
    }
    
}

