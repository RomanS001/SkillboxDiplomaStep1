//
//  SettingTableVCDate.swift
//  MoneyManager
//
//  Created by Roman on 06.03.2021.
//

import UIKit

protocol protocolSettingTableVCDate {
  func returnDateTextField() -> UILabel
}


class SettingTableVCDate: UITableViewCell {
  @IBOutlet var labelDate: UILabel!
  @IBOutlet var labelSelectDate: UILabel!
  @IBOutlet var buttonSelectDate: UIButton!

  // MARK: - делегаты и переменные
  var vcSettingDelegate: protocolVCSetting?
  var indexRow: Int = 0

  // MARK: - переходы

  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }


  @objc func startEditing() {
    vcSettingDelegate?.openAlertDatePicker()
    print("startEditing")
  }


  func startCell(indexRow: Int) {
    self.indexRow = indexRow
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none

    if vcSettingDelegate!.returnNewOperation().date != 0 {
      labelSelectDate.text = dateFormatter.string(from: Date.init(timeIntervalSince1970: vcSettingDelegate!.returnNewOperation().date))
      labelSelectDate.textColor = .black
    } else {
      labelSelectDate.text = vcSettingDelegate!.returnScreen2MenuArray()[indexRow].text
    }

    // textFieldSelectDate.tintColor = UIColor.clear //делает курсор бесцветным, но не убирает его
    labelDate.text = vcSettingDelegate!.returnScreen2MenuArray()[indexRow].name
    self.isUserInteractionEnabled = true

    let gesture = UITapGestureRecognizer(target: self, action: #selector(startEditing))
    self.addGestureRecognizer(gesture)
  }

  func setTag(tag: Int) {
    indexRow = tag
  }
}


extension SettingTableVCDate: protocolSettingTableVCDate {
  func returnDateTextField() -> UILabel {
    print("textViewDeselect")
    return labelSelectDate
  }
}
