//
//  ViewController.swift
//  Skillbox_diploma_step1
//
//  Created by Roman on 07.01.2021.
//


import UIKit
import RealmSwift

protocol protocolScreen1Delegate{
    func findAmountOfHeaders() //подсчёт заголовков с датами в основнй таблице экрана
    func screen1AllUpdate() //обновление данных на всэм экрана
    func actionsOperationsOpenPopUpScreen1(_ tag: Int) //открывает PopUp-окно конкретной операции
    func actionsOperationsClosePopUpScreen1() //закрывает PopUp-окно конкретной операции
    func editOperation(tag: Int) //переход в редактирование выбранной операции на втором экране
    
    //realm
    func addOperationInRealm(newAmount: Double, newCategory: String, newNote: String, newDate: Date)
    func editOperationInRealm(newAmount: Double, newCategory: String, newNote: String, newDate: Date, id: Int)
    func deleteOperationInRealm(tag: Int)
    func deleteCategoryInRealm(id: Int)
    func editCategoryInRealm(newName: String, newIcon: String, id: Int)
    
    //функции возврата
    func returnNewTableDataArray() -> [DataOfOperations] //возвращает данные, которые отображаются в данный момент
    func returnArrayForIncrease() -> [Int] //возвращает инкремент каждой ячейки основной таблице. Показывает количество заголовков до конкретной ячейки.
    func returnDaysForSorting() -> Int
    func returnGraphData() -> [GraphData]
}


class DataOfOperations{
    var amount: Double
    var category: String
    var note: String
    var date: Date
    var id: Int
    
    init(amount1: Double, category1: String, note1: String, date1: Date, id1: Int) {
        self.amount = amount1
        self.category = category1
        self.note = note1
        self.date = date1
        self.id = id1
    }
}
    
    
class GraphData {
    var date: Date
    var cumulativeAmount: Double
    
    init(newDate: Date, newAmount: Double) {
        date = newDate
        cumulativeAmount = newAmount
    }
}


class ViewController: UIViewController {
    
    
    //MARK: - объявление аутлетов
    
    @IBOutlet var tableViewScreen1: UITableView!
    @IBOutlet var buttonDaily: UIView!
    @IBOutlet var buttonWeekly: UIView!
    @IBOutlet var buttonMonthly: UIView!
    @IBOutlet var buttonYearly: UIView!
    @IBOutlet var topMenuButtonStrip: UIView!
    @IBOutlet var labelDaily: UILabel!
    @IBOutlet var labelWeekly: UILabel!
    @IBOutlet var labelMothly: UILabel!
    @IBOutlet var labelYearly: UILabel!
    @IBOutlet var bottomPopInView: UIView!
    @IBOutlet var labelAmountOfIncome: UILabel!
    @IBOutlet var labelAmountOfExpenses: UILabel!
    @IBOutlet var constraintTopMenuBottomStrip: NSLayoutConstraint!
    @IBOutlet var containerBottomOperationScreen1: UIView!
    @IBOutlet var constraintContainerBottomPoint: NSLayoutConstraint!
    @IBOutlet var containerBottomGraphScreen1: UIView!
    @IBOutlet var screen1MiniGraph: UIView!
    @IBOutlet var screen1BottomMenu: UIView!
    @IBOutlet var scrollViewFromBottomPopInView: UIScrollView!
    @IBOutlet var graphFromBottomPopInView: UIView!
    @IBOutlet var buttonScreen1NewOperation: UIButton!
    @IBOutlet var buttonScreen1ShowGraph: UIButton!
    @IBOutlet var buttonScreen1ShowList: UIButton!
    
    
    
    //MARK: - делегаты и переменные
    
    
    var tapOfActionsOperationsOpenPopUpScreen1: UITapGestureRecognizer?
    var delegateScreen2: protocolScreen2Delegate?
    private var delegateScreen1Container: protocolScreen1ContainerOperation?
    private var delegateScreen1GraphContainer: protocolScreen1ContainerGraph?
    
    var dataArrayOfOperationsOriginal: [DataOfOperations] = [] //хранение оригинала данных из Realm
    var dataArrayOfOperations: [DataOfOperations] = [] //хранение модифицированных данных из Realm для конкретного режима отоборажения
    var arrayForIncrease: [Int] = [0] //показывает количество заголовков с новой датой в таблице, которое предшествует конкретной операции
    var graphDataArray: [GraphData] = []
    var daysForSorting: Int = 30
    var tagForEdit: Int = 0
    var screen1StatusGrapjDisplay = false
    
    
    //MARK: - объекты
    
    let blurViewScreen1 =  UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    
    //MARK: - переходы
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ViewControllerScreen2, segue.identifier == "segueToScreen2" {
            delegateScreen2 = vc
            vc.delegateScreen1 = self
        }
        if let vc = segue.destination as? ViewControllerScreen1ContainerOperation, segue.identifier == "segueToScreen1Container"{
            delegateScreen1Container = vc
            vc.delegateScreen1 = self
        }
        if let vc = segue.destination as? ViewControllerScreen1ContainerGraph, segue.identifier == "segueToScreen1GraphContainer"{
            delegateScreen1GraphContainer = vc
            vc.delegateScreen1 = self
        }
        if let vc = segue.destination as? ViewControllerScreen2, segue.identifier == "segueToScreen2ForEdit"{
            vc.screen2StatusEditing = true
            vc.delegateScreen1 = self
            delegateScreen2 = vc
            delegateScreen2?.setAmountInNewOperation(amount: dataArrayOfOperations[tagForEdit].amount)
            delegateScreen2?.setCategoryInNewOperation(category: dataArrayOfOperations[tagForEdit].category)
            delegateScreen2?.setDateInNewOperation(date: dataArrayOfOperations[tagForEdit].date)
            delegateScreen2?.setNoteInNewOperation(note: dataArrayOfOperations[tagForEdit].note)
            delegateScreen2?.setIDInNewOperation(id: tagForEdit)
        }
        
    }
    
    
    //MARK: - клики
    
    
    @IBAction func buttonActionScreen1NewOperation(_ sender: Any) {
        performSegue(withIdentifier: "segueToScreen2", sender: nil)
    }
    
    
    @IBAction func buttonActionScreen1ShowGraph(_ sender: Any) {
        print("screen1StatusGrapjDisplay= \(screen1StatusGrapjDisplay)")
        if screen1StatusGrapjDisplay == false {
            UIView.transition(
            from: scrollViewFromBottomPopInView,
            to: graphFromBottomPopInView,
            duration: 1.0,
            options: [.transitionFlipFromLeft, .showHideTransitionViews],
            completion: nil
          )
            screen1StatusGrapjDisplay = true
            buttonScreen1ShowGraph.setImage(UIImage.init(named: "Left-On"), for: .normal)
            buttonScreen1ShowList.setImage(UIImage.init(named: "Right-Off"), for: .normal)
        }

    }
    
    
    @IBAction func buttonActionScreen1ShowList(_ sender: Any) {
        if screen1StatusGrapjDisplay == true {
            UIView.transition(
            from: graphFromBottomPopInView,
            to: scrollViewFromBottomPopInView,
            duration: 1.0,
            options: [.transitionFlipFromRight, .showHideTransitionViews],
            completion: nil
            )
            screen1StatusGrapjDisplay = false
            buttonScreen1ShowGraph.setImage(UIImage.init(named: "Left-Off"), for: .normal)
            buttonScreen1ShowList.setImage(UIImage.init(named: "Right-On"), for: .normal)
        }
//        screen1StatusGrapjDisplay.toggle()
    }
    
    
    func changeDaysForSorting(){
        borderLineForMenu(days: daysForSorting)
        screen1TableUpdateSorting(days: daysForSorting)
        daysForSortingRealmUpdate()
        countingIncomesAndExpensive()
        delegateScreen1GraphContainer?.containerGraphUpdate()
    }
    
    
    @IBAction func buttonDailyGesture(_ sender: Any) {
        daysForSorting = 1
        changeDaysForSorting()
    }
    
    
    @IBAction func buttonWeeklyGesture(_ sender: Any) {
        daysForSorting = 7
        changeDaysForSorting()
    }
    
    
    @IBAction func buttonMonthlyGesture(_ sender: Any) {
        daysForSorting = 30
        changeDaysForSorting()
    }
    
    
    @IBAction func buttonYearlyGesture(_ sender: Any) {
        daysForSorting = 365
        changeDaysForSorting()
    }
    
    
    @objc func switchScreen1GraphContainer(tap: UITapGestureRecognizer){
        if tap.state == UIGestureRecognizer.State.ended {
            print("Tap Graph ended")
//            let pointOfTap = tap.location(in: self.view)
//            if containerBottomOperationScreen1.frame.contains(pointOfTap) {
//                print("Tap inside Container")
//            }
//            else {
//                print("Tap outside Container")
//                actionsOperationsClosePopUpScreen1()
//            }
        }
    }
    
    
    @objc func handlerToHideContainerScreen1(tap: UITapGestureRecognizer){
        if tap.state == UIGestureRecognizer.State.ended {
            print("Tap ended")
            let pointOfTap = tap.location(in: self.view)
            if containerBottomOperationScreen1.frame.contains(pointOfTap) {
                print("Tap inside Container")
            }
            else {
                print("Tap outside Container")
                actionsOperationsClosePopUpScreen1()
            }
        }
    }
    

    //MARK: - верхнее меню
    
    func topMenuHighliter(specifyLabel: UILabel){
        specifyLabel.font = UIFont.systemFont(ofSize: specifyLabel.font.pointSize, weight: .bold)
        switch specifyLabel {
        case labelDaily:
            labelWeekly.font = UIFont.systemFont(ofSize: labelWeekly.font.pointSize, weight: .medium)
            labelMothly.font = UIFont.systemFont(ofSize: labelMothly.font.pointSize, weight: .medium)
            labelYearly.font = UIFont.systemFont(ofSize: labelYearly.font.pointSize, weight: .medium)
            print("111")
        case labelWeekly:
            labelDaily.font = UIFont.systemFont(ofSize: labelDaily.font.pointSize, weight: .medium)
            labelMothly.font = UIFont.systemFont(ofSize: labelMothly.font.pointSize, weight: .medium)
            labelYearly.font = UIFont.systemFont(ofSize: labelYearly.font.pointSize, weight: .medium)
            print("222")
        case labelMothly:
            labelDaily.font = UIFont.systemFont(ofSize: labelDaily.font.pointSize, weight: .medium)
            labelWeekly.font = UIFont.systemFont(ofSize: labelWeekly.font.pointSize, weight: .medium)
            labelYearly.font = UIFont.systemFont(ofSize: labelYearly.font.pointSize, weight: .medium)
            print("333")
        case labelYearly:
            labelDaily.font = UIFont.systemFont(ofSize: labelDaily.font.pointSize, weight: .medium)
            labelWeekly.font = UIFont.systemFont(ofSize: labelWeekly.font.pointSize, weight: .medium)
            labelMothly.font = UIFont.systemFont(ofSize: labelMothly.font.pointSize, weight: .medium)
            print("444")
        default:
            print("Error with higlightLabel")
        }
    }
    
    func borderLineForMenu(days: Int) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            switch days {
            case 1:
                self.constraintTopMenuBottomStrip.constant = self.buttonDaily.frame.origin.x + 10
                self.topMenuHighliter(specifyLabel: self.labelDaily)
                print("borderForMenuBottom 1")
            case 7:
                self.constraintTopMenuBottomStrip.constant = self.buttonWeekly.frame.origin.x + 10
                print("borderForMenuBottom 7")
                self.topMenuHighliter(specifyLabel: self.labelWeekly)
            case 30:
                self.constraintTopMenuBottomStrip.constant = self.buttonMonthly.frame.origin.x + 10
                self.topMenuHighliter(specifyLabel: self.labelMothly)
                print("borderForMenuBottom 30")
            case 365:
                self.constraintTopMenuBottomStrip.constant = self.buttonYearly.frame.origin.x + 10
                self.topMenuHighliter(specifyLabel: self.labelYearly)
                print("borderForMenuBottom 365")
            default:
                print("Error with borderForMenuBotton")
            }
        }, completion: {isCompleted in })
    }
    
    func countingIncomesAndExpensive() {
        var income: Double = 0
        var expensive: Double = 0
        for n in dataArrayOfOperations.filter( { $0.amount > 0 } ) {
            income += n.amount
        }
        for n in dataArrayOfOperations.filter( { $0.amount < 0 } ) {
            expensive += n.amount
        }
        
        if income.truncatingRemainder(dividingBy: 1) == 0 {
            labelAmountOfIncome.text = "$\(String(format: "%.0f", income))"
        }
        else {
            labelAmountOfIncome.text = "$\(String(format: "%.2f", income))"
        }
        if expensive.truncatingRemainder(dividingBy: 1) == 0 {
            labelAmountOfExpenses.text = "$\(String(format: "%.0f", expensive))"
        }
        else {
            labelAmountOfExpenses.text = "$\(String(format: "%.2f", expensive))"
        }
    }
    
    
    //MARK: - таблица списка операций
    
    func tableNumberOfRowsInSection() -> Int{
        if dataArrayOfOperations.count == 0 { return 1 }
        arrayForIncrease = [1]
        var previousDay: Int = 0
        var counter: Int = 0
        
        for x in dataArrayOfOperations {
            if Calendar.current.component(.day, from: x.date) != previousDay{
                if counter != 0 {
                    //Расчёт множителя, который компенсирует наличие header'ов в таблице
                    arrayForIncrease.append(arrayForIncrease.last!)
                    arrayForIncrease.append(arrayForIncrease.last! + 1)
                }
                previousDay = Calendar.current.component(.day, from: x.date)
            }
            else {
                arrayForIncrease.append(arrayForIncrease.last!)
            }
            counter += 1
        }
        arrayForIncrease.append(arrayForIncrease.last!)
        
        
        //-----------------------------------------------------------
        //Данные для передачи в график
        //Cохраняет кумулятивную сумму операций за каждый день из расчёта
        
//        let formatterPreviousDate = DateFormatter()
        //        formatterPreviousDate.dateStyle = .full
        
        
        for n in dataArrayOfOperations{
            for x in graphDataArray {
                if n.date == x.date {
                    graphDataArray.filter({$0.date == n.date}).first?.cumulativeAmount += n.amount
                }
                else {
                    graphDataArray.append(GraphData.init(newDate: n.date, newAmount: n.amount))
                }
            }
        }
        graphDataArray.filter({$0.date > $1.date})
        

//                if formatterPreviousDate.string(from: x.date) == formatterPreviousDate.string(from: n.){
//                    return
//                }
//            }
//        }
        
        
//        var cumulativeSumOfDay: Double = 0
//        counter = 0
//        var previousAmount: Double = 0
//        graphDataArray = []
//
//        var previousDayNew: Date = Date.init()
//        let formatterPreviousDate = DateFormatter()
//        formatterPreviousDate.dateStyle = .full
//        formatterPreviousDate.timeStyle = .none
//
//        //Расчёт данных для графика
//        for x in dataArrayOfOperations {
//            if Calendar.current.component(.day, from: x.date) != previousDay{
//                if counter != 0 {
//                    graphDataArray.append(GraphData(date: x.date, amount: cumulativeSumOfDay))
//                }
//                cumulativeSumOfDay = x.amount
//                previousDayNew = Calendar.current.component(, from: <#T##Date#>)
//            }
//            //Если следующая операция в этот же день
//            else {
//                cumulativeSumOfDay += x.amount
//            }
//            counter += 1
//        }
//        if previousDay != Calendar.current.component(.day, from: dataArrayOfOperations.last!.date) {
//            graphDataArray.append(GraphData(date: dataArrayOfOperations.last!.date, amount: cumulativeSumOfDay))
//        }

        
        return arrayForIncrease.count
    }
    
    // Обновление сортировки
    func screen1TableUpdateSorting(days: Int){
        let newTime = Date() - TimeInterval.init(86400 * days)
        
        dataArrayOfOperations = dataArrayOfOperationsOriginal
        dataArrayOfOperations.sort(by: { $0.date > $1.date })
        
        graphDataArray = graphDataArray
            .sorted(by: {$0.date > $1.date})
            .filter( {$0.date >= newTime} )
    
        let temporarilyDate = dataArrayOfOperations.filter { $0.date >= newTime }
        dataArrayOfOperations = temporarilyDate
        self.tableViewScreen1.reloadData()
    }
    
    
    //MARK: - данные
    
    func screen1DataReceive(){
        dataArrayOfOperationsOriginal = []
        for n in Persistence.shared.getRealmDataOperations(){
            dataArrayOfOperationsOriginal.append(DataOfOperations(amount1: n.amount, category1: n.category, note1: n.note, date1: n.date, id1: n.id))
        }
        daysForSorting = Persistence.shared.returnDaysForSorting()
        print("daysForSorting in screen1DataReceive= \(Persistence.shared.returnDaysForSorting())")
        print("newTableDataArrayOriginal= \(dataArrayOfOperationsOriginal)")
    }
    
    func daysForSortingRealmUpdate(){
        Persistence.shared.updateDaysForSorting(daysForSorting: daysForSorting)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        borderLineForMenu(days: daysForSorting)
        screen1TableUpdateSorting(days: daysForSorting)
        self.view.layoutIfNeeded()
    }
    
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screen1AllUpdate()
        
        //округление углов на первом экране
        bottomPopInView.layer.cornerRadius = 20
        bottomPopInView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        bottomPopInView.clipsToBounds = true
//        containerBottomGraphScreen1.clipsToBounds = true

        //Добавление Blur-эффекта
        self.view.insertSubview(self.blurViewScreen1, belowSubview: self.containerBottomOperationScreen1)
        self.blurViewScreen1.backgroundColor = .clear
        self.blurViewScreen1.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.blurViewScreen1.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.blurViewScreen1.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.blurViewScreen1.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            self.blurViewScreen1.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
        self.blurViewScreen1.isHidden = true
        
        self.view.layoutIfNeeded()
        
    }
}


//MARK: - additional protocols

extension ViewController: protocolScreen1Delegate{
    
    func returnGraphData() -> [GraphData] {
        return graphDataArray
    }
    
    
    func returnDaysForSorting() -> Int {
        return daysForSorting
    }
    
    
    func editCategoryInRealm(newName: String, newIcon: String, id: Int) {
        print("editCategoryInRealm")
        Persistence.shared.updateCategory(name: newName, icon: newIcon, idOfObject: delegateScreen2!.returnDataArrayOfCategory()[id].id)
    }
    
    
    func deleteCategoryInRealm(id: Int) {
        Persistence.shared.deleteCategory(idOfObject: delegateScreen2!.returnDataArrayOfCategory()[id].id)
    }
    
    
    func editOperation(tag: Int) {
        actionsOperationsClosePopUpScreen1()
        tagForEdit = tag
        performSegue(withIdentifier: "segueToScreen2ForEdit", sender: nil)
    }
    
    
    func deleteOperationInRealm(tag: Int) {
        actionsOperationsClosePopUpScreen1()
        Persistence.shared.deleteOperation(idOfObject: returnNewTableDataArray()[tag].id)
    }
    
    
    func addOperationInRealm(newAmount: Double, newCategory: String, newNote: String, newDate: Date) {
        Persistence.shared.addOperations(amount: newAmount, category: newCategory, note: newNote, date: newDate)
    }
    
    
    func editOperationInRealm(newAmount: Double, newCategory: String, newNote: String, newDate: Date, id: Int) {
        print("editOperationInRealm")
        Persistence.shared.updateOperations(amount: newAmount, category: newCategory, note: newNote, date: newDate, idOfObject: id)
    }
    
    
    func screen1AllUpdate() {
        screen1DataReceive()
        screen1TableUpdateSorting(days: daysForSorting)
        countingIncomesAndExpensive()
        changeDaysForSorting()
        
    }
    
    func returnArrayForIncrease() -> [Int]{
        return arrayForIncrease
    }
    

    func returnNewTableDataArray() -> [DataOfOperations] {
        return dataArrayOfOperations
    }
    
    
    func findAmountOfHeaders() {
        return
    }
    
    
    //MARK: - PopUp-окно операции
    
    
    func actionsOperationsOpenPopUpScreen1(_ tag: Int) {
        containerBottomOperationScreen1.layer.cornerRadius = 20
        delegateScreen1Container?.startCell(tag: tag)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.constraintContainerBottomPoint.constant = 50
            self.tapOfActionsOperationsOpenPopUpScreen1 = UITapGestureRecognizer(target: self, action: #selector(self.handlerToHideContainerScreen1(tap:)))
            self.view.addGestureRecognizer(self.tapOfActionsOperationsOpenPopUpScreen1!)
            self.blurViewScreen1.isHidden = false
            self.view.layoutIfNeeded()
        }, completion: {isCompleted in })
    }
    
    
    func actionsOperationsClosePopUpScreen1() {
//        tableViewScreen2Update(row: 1)
        UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIView.AnimationOptions(), animations: {
            self.constraintContainerBottomPoint.constant = -311
            self.blurViewScreen1.isHidden = true
            self.view.removeGestureRecognizer(self.tapOfActionsOperationsOpenPopUpScreen1!)
            self.view.layoutIfNeeded()
        }, completion: {isCompleted in })
    }
    
}


//MARK: - PopUp-окна


//MARK: - table Functionality
extension ViewController: UITableViewDelegate, UITableViewDataSource{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
////            objects.remove(at: indexPath.row)
////            tableView.deleteRows(at: [indexPath], with: .fade)
//            print("editingStyle == .delete")
//        } else if editingStyle == .insert {
//            print("editingStyle == .insert")
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableNumberOfRowsInSection()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataArrayOfOperations.isEmpty{
//            print("dataArrayOfOperations is empty")
            let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! Screen1TableViewCellHeader
            cell.delegateScreen1 = self
            cell.startCellEmpty()
            return cell

        }
        else{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! Screen1TableViewCellHeader
                cell.delegateScreen1 = self
                cell.setTag(tag: indexPath.row)
                cell.startCell()
                return cell
            }
            else if arrayForIncrease[indexPath.row] != arrayForIncrease[indexPath.row - 1] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "header") as! Screen1TableViewCellHeader
                cell.delegateScreen1 = self
                cell.setTag(tag: indexPath.row)
                cell.startCell2()
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "operation") as! Screen1TableViewCellOperation
                cell.delegateScreen1 = self
                cell.setTag(tag: indexPath.row)
                cell.startCell()
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
