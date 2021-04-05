//
//  ViewControllerScreen2.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 16.01.2021.
//

import UIKit

protocol protocolScreen2Delegate{
    func changeCategoryClosePopUp()
    func changeCategoryOpenPopUp(_ tag: Int)
    func tableViewScreen2Update(row: Int)
    //функции возврата
    func getScreen2MenuArray() -> [Screen2MenuData]
    func returnDelegateScreen2TableViewCellNote() -> protocolScreen2TableViewCellNoteDelegate
    func returnNewOperation() -> ListOfOperations
    //функции обновления newOperation
    func setAmountInNewOperation(amount: Double)
    func setCategoryInNewOperation(category: String)
    func setNoteInNewOperation(note: String)
    func setDateInNewOperation(date: Date)
    func showDatePicker()
    func testAction()
}

struct Screen2MenuData {
    let name: String
    let text: String
}

class ViewControllerScreen2: UIViewController, UITextViewDelegate {

    //MARK: - объявление аутлетов
    
    @IBOutlet var screen2SegmentControl: UISegmentedControl!
    @IBOutlet var tableViewScreen2: UITableView!
    @IBOutlet var screen2CurrencyStatus: UIButton!
    @IBOutlet var containerBottom: UIView!
    @IBOutlet var constraintContainerBottomPoint: NSLayoutConstraint!
    @IBOutlet var constraintContainerBottomHeight: NSLayoutConstraint!
    @IBOutlet var textFieldAmount: UITextField!
    
    
    //MARK: - делегаты и переменные
    
    var tapOfChangeCategoryOpenPopUp: UITapGestureRecognizer?
    var tapOutsideTextViewToGoFromTextView: UITapGestureRecognizer?
    let blurView =  UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var newOperation: ListOfOperations = ListOfOperations()
    let datePicker = UIDatePicker()
    
    var delegateScreen1: protocolScreen1Delegate?
    var delegateScreen2Container: protocolScreen2ContainerDelegate?
    var delegateScreen2TableViewCellCategory: protocolScreen2TableViewCellCategory?
    var delegateScreen2TableViewCellNote: protocolScreen2TableViewCellNoteDelegate?
    var delegateScreen2TableViewCellDate: protocolScreen2TableViewCellDateDelegate?
    
    
    //MARK: - переходы
    
    @IBAction func buttonToAddNewOperation(_ sender: Any) {
        
        if newOperation.category != "" {
            
            //set Amount
            if screen2SegmentControl.selectedSegmentIndex == 0 {
                setAmountInNewOperation(amount: Double(textFieldAmount.text ?? "0")!)
            }
            else if screen2SegmentControl.selectedSegmentIndex == 1 {
                setAmountInNewOperation(amount: -Double(textFieldAmount.text ?? "0")!)
            }
            
            
            //set Date
            if delegateScreen2TableViewCellDate?.returnDateTextField().text == "Today" {
                let dateNow = Date.init()
                setDateInNewOperation(date: dateNow)
            }
            else {
                setDateInNewOperation(date: datePicker.date)
            }
            
            
            //set Note
            if delegateScreen2TableViewCellNote?.returnNoteView().text! == "Placeholder" {
                setNoteInNewOperation(note: "")
            }
            else {
                setNoteInNewOperation(note: (delegateScreen2TableViewCellNote?.returnNoteView().text!)!)
            }
            
            print("newOperation.amount= \(newOperation.amount), newOperation.category= \(newOperation.category), newOperation.date= \(newOperation.date), newOperation.note= \(newOperation.note),")
            delegateScreen1?.addOperationInRealm(newAmount: newOperation.amount, newCategory: newOperation.category, newNote: newOperation.note, newDate: newOperation.date)
            delegateScreen1?.screen1AllUpdate()
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func buttonCloseScreen2(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewControllerScreen2Container, segue.identifier == "segueToScreen2Container"{
            delegateScreen2Container = vc
            vc.delegateScreen2 = self
        }
    }
    
    
    //MARK: - DatePicker
    
    func createAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Select date1", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Установть дату", style: .default, handler: { _ in self.donePressed() }))
        alert.view.addSubview(datePicker)
        
        let alertHeightConstraint = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: datePicker.frame.height + 60)
        let alertWidthConstraint = NSLayoutConstraint(item: alert.view!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: datePicker.frame.width)
        
//        let datePickertCentrYConstraint = NSLayoutConstraint(item: datePicker, attribute: .centerY, relatedBy: .equal, toItem: alert, attribute: .centerY, multiplier: 1, constant: 0)
        
        alert.view.addConstraint(alertHeightConstraint)
        alert.view.addConstraint(alertWidthConstraint)
        datePicker.frame.origin.y = 20
//        datePicker.addConstraint(datePickertCentrYConstraint)
        return alert
    }
    
    
    func createDatePicker(){
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
    }
    
    func donePressed(){
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        newOperation.date = datePicker.date
        tableViewScreen2Update(row: 2)
        self.view.endEditing(true)
    }
    
    
    //MARK: - клики
    
    
    @IBAction func textFieldAmountEditingDidBegin(_ sender: Any) {
        if textFieldAmount.textColor == UIColor.opaqueSeparator {
            textFieldAmount.text = nil
            
            switch screen2SegmentControl.selectedSegmentIndex {
            case 0:
                textFieldAmount.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
            case 1:
                textFieldAmount.textColor = UIColor.red
            default:
                break
            }
        }
        print("func textViewDidBeginEditing")
    }
    
    @IBAction func textFieldAmountEditingDidEnd(_ sender: Any) {
        if textFieldAmount.text == "" {
            textFieldAmount.text = "0"
            textFieldAmount.textColor = UIColor.opaqueSeparator
        }
        textFieldAmount.resignFirstResponder()
        print("func textFieldAmountEditingDidEnd")
    }
    
    
//    @IBAction func textFieldActionEditingChanged(_ sender: Any) {
//        print("textFieldActionEditingChanged")
//    }
    
    
    @IBAction func screen2SegmentControlAction(_ sender: Any) {
        textFieldAmount.endEditing(true)
        delegateScreen2TableViewCellDate?.tapOutsideDateTextViewEditToHide()
        delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
        switch screen2SegmentControl.selectedSegmentIndex {
        case 0:
            screen2CurrencyStatus.setTitle("+$", for: .normal)
            screen2CurrencyStatus.setTitleColor(UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1)), for: .normal)
            textFieldAmount.textColor = UIColor(cgColor: CGColor.init(srgbRed: 0.165, green: 0.671, blue: 0.014, alpha: 1))
        case 1:
            screen2CurrencyStatus.setTitle("-$", for: .normal)
            screen2CurrencyStatus.setTitleColor(UIColor.red, for: .normal)
            textFieldAmount.textColor = UIColor.red
        default:
            break
        }
    }
    
    @objc func screen2TapHandler(tap: UITapGestureRecognizer){
        if tap.state == UIGestureRecognizer.State.ended {
                print("Tap TextView ended")
            let pointOfTap = tap.location(in: self.view)
            
            //Tap inside noteTextView
            if delegateScreen2TableViewCellNote!.returnNoteView().frame.contains(pointOfTap) {
                textFieldAmount.endEditing(true)
                delegateScreen2TableViewCellDate?.tapOutsideDateTextViewEditToHide()
                print("Tap inside noteTextView")
            }
            
            //Tap inside in dateTextView
            else if delegateScreen2TableViewCellDate!.returnDateTextField().frame.contains(pointOfTap) {
                textFieldAmount.endEditing(true)
                delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
                print("Tap inside in dateTextView")
            }
            
            //Tap inside in textFieldAmount
            else if textFieldAmount.frame.contains(pointOfTap){
                print("Tap inside in textFieldAmount")
                delegateScreen2TableViewCellDate?.tapOutsideDateTextViewEditToHide()
                delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
            }
            else {
                
                //Tap outside noteTextView and dateTextView and textFieldAmount
                textFieldAmount.endEditing(true)
                delegateScreen2TableViewCellDate?.tapOutsideDateTextViewEditToHide()
                delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
                print("Tap outside noteTextView and dateTextView and textFieldAmount")
            }
//            tableViewScreen2Update(row: 1)
//            tableViewScreen2Update(row: 2)
//            tableViewScreen2Update(row: 3)
            
//            tableViewScreen2.reloadData()
//            newOperation.note = (delegateScreen2TableViewCellNote?.returnNoteView().text)!
//            print("newOperation.note= \(newOperation.note)")
//            delegateScreen2TableViewCellNote!.tapOutsideNoteTextViewEditToHide()
        }
    }
    
    @objc func handlerToHideContainer(tap: UITapGestureRecognizer){
        if tap.state == UIGestureRecognizer.State.ended {
            print("Tap ended")
            let pointOfTap = tap.location(in: self.view)
            if containerBottom.frame.contains(pointOfTap) {
                print("Tap inside Container")
            }
            else {
                print("Tap outside Container")
                changeCategoryClosePopUp()
            }
        }
    }
    
    
    //MARK: - данные
    
    var screen2MenuArray: [Screen2MenuData] = []
    let Screen2MenuList0 = Screen2MenuData(name: "Header", text: "")
    let Screen2MenuList1 = Screen2MenuData(name: "Category", text: "Select category")
    let Screen2MenuList2 = Screen2MenuData(name: "Date", text: "Today")
    let Screen2MenuList3 = Screen2MenuData(name: "Notes", text: "")
    
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy/MM/dd HH:mm"
    //        let today = formatter.date(from: "2021/02/22 17:45")
    //        let yesterday = formatter.date(from: "2021/02/23 13:15")
    //        let a2DaysBefore = formatter.date(from: "2021/02/24 10:05")
    //
    //        Persistence.shared.addOperations(amount: 1200, category: "Salary", note: "Первая заметка", date: today!)
    //        Persistence.shared.addOperations(amount: -600, category: "Coffee", note: "Вторая заметка", date: yesterday!)
    //        Persistence.shared.addOperations(amount: -200, category: "Lease payable", note: "Третья очень очень большая заметка. Третья очень очень большая заметка. Третья очень очень большая заметка. Третья очень очень большая заметка. Третья очень очень большая заметка. Третья очень очень большая заметка. Третья очень очень большая заметка. Третья очень очень большая заметка.", date: a2DaysBefore!)
    
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screen2MenuArray = [Screen2MenuList0, Screen2MenuList1, Screen2MenuList2, Screen2MenuList3]
        
        self.view.insertSubview(self.blurView, belowSubview: self.containerBottom)
        self.blurView.backgroundColor = .clear
        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.blurView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.blurView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.blurView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
        self.blurView.isHidden = true
        
        self.view.layoutIfNeeded()
        print("screen2MenuArray.count: \(screen2MenuArray.count)")
        
        self.tapOutsideTextViewToGoFromTextView = UITapGestureRecognizer(target: self, action: #selector(self.screen2TapHandler(tap:)))
        self.view.addGestureRecognizer(self.tapOutsideTextViewToGoFromTextView!)
        
        createDatePicker()
    }
}


//MARK: - additional protocols

extension ViewControllerScreen2: protocolScreen2Delegate{
    
    func testAction() {
        self.present(createAlert(), animated: true, completion: nil)
    }
    
    
    func showDatePicker() {
        self.view.addSubview(datePicker)
    }
    
    
    func tableViewScreen2Update(row: Int) {
        print("tableViewScreen2Update activated")
        let indexPath = IndexPath.init(row: row, section: 0)
        tableViewScreen2.reloadRows(at: [indexPath], with: .fade)
    }
    
    
    func setAmountInNewOperation(amount: Double) {
        newOperation.amount = amount
    }
    
    
    func setCategoryInNewOperation(category: String) {
        newOperation.category = category
    }
    
    
    func setDateInNewOperation(date: Date) {
        newOperation.date = date
    }
    
    
    func setNoteInNewOperation(note: String) {
        newOperation.note = note
    }
    
    
    func returnNewOperation() -> ListOfOperations{
        return newOperation
    }
    
    
    func returnDelegateScreen2TableViewCellNote() -> protocolScreen2TableViewCellNoteDelegate {
        return delegateScreen2TableViewCellNote!
    }
    
    
    //MARK: - окрытие PopUp-окна
    func changeCategoryOpenPopUp(_ tag: Int) {
//        containerBottom.layer.borderWidth = 3
//        containerBottom.layer.borderColor = UIColor.red.cgColor
        self.containerBottom.layer.cornerRadius = 20
        self.constraintContainerBottomHeight.constant = CGFloat(50*(self.screen2MenuArray.count+3))
        textFieldAmount.endEditing(true)
        delegateScreen2TableViewCellDate?.tapOutsideDateTextViewEditToHide()
        delegateScreen2TableViewCellNote?.tapOutsideNoteTextViewEditToHide()
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.constraintContainerBottomPoint.constant = 50
            self.tapOfChangeCategoryOpenPopUp = UITapGestureRecognizer(target: self, action: #selector(self.handlerToHideContainer(tap:)))
            self.view.addGestureRecognizer(self.tapOfChangeCategoryOpenPopUp!)
            self.blurView.isHidden = false
            self.view.layoutIfNeeded()
        }, completion: {isCompleted in })
        
    }
    
    
    //MARK: - закрытие PopUp-окна
    @objc func changeCategoryClosePopUp() {
        tableViewScreen2Update(row: 1)
//        self.tableViewScreen2Update()
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.constraintContainerBottomPoint.constant = -515
            self.blurView.isHidden = true
            self.view.removeGestureRecognizer(self.tapOfChangeCategoryOpenPopUp!)
            self.view.layoutIfNeeded()
        }, completion: {isCompleted in })
    }
    
    func getScreen2MenuArray() -> [Screen2MenuData] {
        return screen2MenuArray
    }
}


//MARK: - table Functionality

extension ViewControllerScreen2: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screen2MenuArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! Screen2TableViewCellHeader
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellCategory") as! Screen2TableViewCellCategory
            cell.delegateScreen2 = self
            cell.setTag(tag: indexPath.row)
            cell.startCell()
            
            self.delegateScreen2TableViewCellCategory = cell
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDate") as! Screen2TableViewCellDate
            cell.delegateScreen2 = self
            cell.setTag(tag: indexPath.row)
            cell.startCell()
            
            self.delegateScreen2TableViewCellDate = cell
            return cell
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellNote") as! Screen2TableViewCellNote
            cell.delegateScreen2 = self
            cell.setTag(tag: indexPath.row)
            cell.startCell()
            cell.textViewNotes.delegate = cell
            
            self.delegateScreen2TableViewCellNote = cell
            return cell
        }
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
//        if indexPath.row == 3 {
//            return 88
//        }
//        else{
//            return 44
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
