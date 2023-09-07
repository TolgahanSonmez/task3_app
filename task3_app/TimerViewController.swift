//
//  ViewController.swift
//  task3_app
//
//  Created by Tolgahan Sonmez on 29.08.2023.
//

import UIKit

class TimerViewController: UIViewController, UNUserNotificationCenterDelegate{
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var label_Timer: UILabel!
    @IBOutlet weak var button_play: UIButton!
    @IBOutlet weak var button_set: UIButton!
    var timer: Timer?
    var remainingTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        label_Timer.layer.borderWidth = 2
        button_play.layer.cornerRadius = 20
        button_set.layer.cornerRadius = 18
        //Permission
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    let minutes = Array(00...59)
    let seconds = Array(00...59)

    @IBAction func setButtonTapped(_ sender: UIButton) {
        timer?.invalidate()
        timer = nil
        button_play.setTitle("Play", for: .normal)
        pickerView.isUserInteractionEnabled = true
        label_Timer.text = "00:00"
        button_set.isEnabled = false
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            button_play.setTitle("Play", for: .normal)
            pickerView.isUserInteractionEnabled = true
        } else {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            let minutes = selectedRow
            let seconds = pickerView.selectedRow(inComponent: 1)
            remainingTime = (minutes * 60) + seconds
        if remainingTime > 0 {
                startTimer()
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        button_play.setTitle("Stop", for: .normal)
        button_set.isEnabled = true
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotification(after: TimeInterval(self.remainingTime))
            }
        }
    }
    
    @objc func updateTimer() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateTimerLabel()
        } else {
            endTimer()
        }
    }

    func updateTimerLabel() {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        label_Timer.text = String(format: "%02d:%02d", minutes, seconds)
    }

    func endTimer() {
        timer?.invalidate()
        timer = nil
        button_play.setTitle("Play", for: .normal)
        pickerView.isUserInteractionEnabled = true
        label_Timer.text = "00:00"
        let backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        DispatchQueue.global(qos: .background).async {
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
    
    func scheduleNotification(after timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Timer"
        content.body = "Timer has elapsed!!"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "timerNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

extension TimerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? minutes.count : seconds.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let minutes = minutes[row] < 10 ? "0\(minutes[row])" : "\(minutes[row])"
            return minutes
        } else {
            let seconds = seconds[row] < 10 ? "0\(seconds[row])" : "\(seconds[row])"
            return seconds
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedMinute = minutes[pickerView.selectedRow(inComponent: 0)]
        let selectedSecond = seconds[pickerView.selectedRow(inComponent: 1)]
        
        let formattedMinute = String(format: "%02d", selectedMinute)
        let formattedSecond = String(format: "%02d", selectedSecond)
        label_Timer.text = "\(formattedMinute) : \(formattedSecond)"
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 70
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
}
