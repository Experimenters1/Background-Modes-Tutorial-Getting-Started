//
//  ViewController.swift
//  BackgroundTimer
//
//  Created by Huy Vu on 1/22/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startStop: UIButton!
    
    @IBOutlet weak var reset: UIButton!
    
    var timerCounting:Bool = false //Một biến Bool để kiểm tra xem đồng hồ có đang chạy hay không.
    
    //startTime và stopTime: Biến để lưu thời gian bắt đầu và thời gian dừng của đồng hồ.
    var startTime:Date?
    var stopTime:Date?
    
    let userDefaults = UserDefaults.standard //Đối tượng UserDefaults để lưu trữ dữ liệu giữa các lần chạy ứng dụng.
    
    //START_TIME_KEY, STOP_TIME_KEY, COUNTING_KEY: Chuỗi làm key để lưu trữ dữ liệu vào UserDefaults.
    let START_TIME_KEY = "startTime"
    let STOP_TIME_KEY = "stopTime"
    let COUNTING_KEY = "countingKey"
    
    var scheduledTimer: Timer! // Đối tượng Timer được sử dụng để cập nhật giá trị thời gian đồng hồ mỗi 0.1 giây.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Khôi phục giá trị của startTime, stopTime, và timerCounting từ UserDefaults.
        startTime = userDefaults.object(forKey: START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: STOP_TIME_KEY) as? Date
        timerCounting = userDefaults.bool(forKey: COUNTING_KEY)
        
//        Nếu đồng hồ đang chạy (timerCounting là true), thì gọi hàm startTimer(). Ngược lại, dừng đồng hồ và hiển thị thời gian đã trôi qua từ startTime đến stopTime.
        if timerCounting
        {
            startTimer()
        }
        else
        {
            stopTimer()
            if let start = startTime
            {
                if let stop = stopTime
                {
                    let time = calcRestartTime(start: start, stop: stop)
                    let diff = Date().timeIntervalSince(time)
                    setTimeLabel(Int(diff))
                }
            }
        }
        
       //Ngược lại, bắt đầu đồng hồ và lưu thời gian bắt đầu.
    }

    @IBAction func startStopAction1(_ sender: Any) {
        
//        Nếu đồng hồ đang chạy (timerCounting là true), dừng đồng hồ và lưu thời gian dừng (setStopTime(date: Date())).
        if timerCounting
        {
            setStopTime(date: Date())
            stopTimer()
        }
        else
        {
            if let stop = stopTime
            {
                let restartTime = calcRestartTime(start: startTime!, stop: stop)
                setStopTime(date: nil)
                setStartTime(date: restartTime)
            }
            else
            {
                setStartTime(date: Date()) //Ngược lại, bắt đầu đồng hồ và lưu thời gian bắt đầu.
            }
            
            startTimer()
        }
    }
    
    func calcRestartTime(start: Date, stop: Date) -> Date
    {//Hàm tính thời gian mới để bắt đầu đồng hồ sau khi tạm dừng.
        let diff = start.timeIntervalSince(stop)
        return Date().addingTimeInterval(diff)
    }
    
    func startTimer()
    {  //Bắt đầu đồng hồ bằng cách sử dụng Timer để gọi hàm refreshValue mỗi 0.1 giây.
        //Thiết lập giao diện người dùng để hiển thị trạng thái đang chạy.
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(refreshValue), userInfo: nil, repeats: true)
        setTimerCounting(true)
        startStop.setTitle("STOP", for: .normal)
        startStop.setTitleColor(UIColor.red, for: .normal)
        startStop.titleLabel?.font = UIFont.systemFont(ofSize: 100)
    }
    
    @objc func refreshValue()
    { //Gọi mỗi khi Timer kích hoạt, cập nhật giá trị thời gian hiển thị trên timeLabel.
        if let start = startTime
        {
            let diff = Date().timeIntervalSince(start)
            setTimeLabel(Int(diff))
        }
        else
        {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    func setTimeLabel(_ val: Int)
    { //Chuyển đổi giây thành giờ, phút, giây và cập nhật giá trị trên timeLabel.
        let time = secondsToHoursMinutesSeconds(val)
        let timeString = makeTimeString(hour: time.0, min: time.1, sec: time.2)
        timeLabel.text = timeString
    }
    
    
//    Các hàm tiện ích để chuyển đổi giây thành giờ, phút, giây và tạo chuỗi hiển thị thời gian.
    
    func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int)
    {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    func makeTimeString(hour: Int, min: Int, sec: Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hour)
        timeString += ":"
        timeString += String(format: "%02d", min)
        timeString += ":"
        timeString += String(format: "%02d", sec)
        return timeString
    }
    
    func stopTimer()
    { //Dừng đồng hồ và cập nhật giao diện người dùng để hiển thị trạng thái dừng.
        if scheduledTimer != nil
        {
            scheduledTimer.invalidate()
        }
        setTimerCounting(false)
        startStop.setTitle("START", for: .normal)
        startStop.setTitleColor(UIColor.systemGreen, for: .normal)
        startStop.titleLabel?.font = UIFont.systemFont(ofSize: 40)
    }
    
    @IBAction func resetAction1(_ sender: Any) { //Đặt lại thời gian đồng hồ, lưu trữ lại vào UserDefaults và dừng đồng hồ.
        setStopTime(date: nil)
        setStartTime(date: nil)
        timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
    }
    
    //Các hàm để lưu trữ thời gian bắt đầu, thời gian dừng và trạng thái đồng hồ vào UserDefaults.
    
    func setStartTime(date: Date?)
    {
        startTime = date
        userDefaults.set(startTime, forKey: START_TIME_KEY)
    }
    
    func setStopTime(date: Date?)
    {
        stopTime = date
        userDefaults.set(stopTime, forKey: STOP_TIME_KEY)
    }
    
    func setTimerCounting(_ val: Bool)
    {
        timerCounting = val
        userDefaults.set(timerCounting, forKey: COUNTING_KEY)
    }
}

