//
//  ScanViewController.swift
//  CBDemo
//
//  Created by 이원빈 on 5/9/25.
//

import UIKit
import CoreBluetooth

class ScanViewController: UIViewController {
  
  // MARK: - UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "검색된 주변기기"
    label.textColor = .black
    return label
  }()
  
  lazy var tableView: UITableView = {
    let tv = UITableView(frame: .zero, style: .plain)
    tv.translatesAutoresizingMaskIntoConstraints = false
    tv.backgroundColor = .systemGray6
    return tv
  }()
  
  // MARK: - Properties
  var peripheralList: [(peripheral: CBPeripheral, RSSI: Float)] = []
  
  // MARK: - Life Cycle
  init() {
    super.init(nibName: nil, bundle: nil)
    setupViewHierarchy()
    setupViewLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    
    peripheralList = []
    serial.delegate = self
    serial.startScan()
  }
}

// MARK: - TableView Settings

extension ScanViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return peripheralList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ScanTableViewCell", for: indexPath) as? ScanTableViewCell else {
      return UITableViewCell()
    }
    let periperalName = peripheralList[indexPath.row].peripheral.name ?? "Unknown"
    cell.updatePeripheralName(name: periperalName)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    serial.stopScan()
    let selectedPeripheral = peripheralList[indexPath.row].peripheral
    serial.connectToPeripheral(selectedPeripheral)
  }
}
  
// MARK: - BluetoothSerialDelegate

extension ScanViewController: BluetoothSerialDelegate {
  
  func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {
    for existing in peripheralList {
      if existing.peripheral.identifier == peripheral.identifier { return }
    }
    let fRSSI = RSSI?.floatValue ?? 0.0
    peripheralList.append((peripheral, fRSSI))
    peripheralList.sort { $0.RSSI > $1.RSSI }
    tableView.reloadData()
  }
  
  func serialDidConnectPeripheral(peripheral: CBPeripheral) {
    let connectSuccessAlert = UIAlertController(title: "연결 성공", message: "\(peripheral.name ?? "알수없음")연결되었습니다.", preferredStyle: .actionSheet)
    let confirm = UIAlertAction(title: "확인", style: .default) { _ in self.dismiss(animated: true) }
    connectSuccessAlert.addAction(confirm)
    serial.delegate = nil
    present(connectSuccessAlert, animated: true)
  }
}

// MARK: - Setup Layout

private extension ScanViewController {
  
  func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(
      ScanTableViewCell.self,
      forCellReuseIdentifier: "ScanTableViewCell"
    )
  }
  
  func setupViewHierarchy() {
    view.addSubview(titleLabel)
    view.addSubview(tableView)
  }
  
  func setupViewLayout() {
    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
