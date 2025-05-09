//
//  BluetoothSerial.swift
//  CBDemo
//
//  Created by 이원빈 on 5/8/25.
//

import CoreBluetooth


protocol BluetoothSerialDelegate: AnyObject {
  func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?)
  func serialDidConnectPeripheral(peripheral: CBPeripheral)
}

extension BluetoothSerialDelegate {
  func serialDidDiscoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber?) {}
  func serialDidConnectPeripheral(peripheral: CBPeripheral) {}
}

var serial: BluetoothSerial!

class BluetoothSerial: NSObject {
  
  // MARK: - Properties
  /// 블루투스 주변 기기를 검색하고 연결하는 역할
  var centralManager: CBCentralManager!
  /// 현재 연결을 시도 중인 주변 기기
  var pendingPeripheral: CBPeripheral?
  /// 현재 연결된 주변 기기. 기기와 통신을 시작하게 되면 이 객체를 이용
  var connectedPeripheral: CBPeripheral?
  /// 데이터를 주변기기에 보내기 위한 characteristic을 저장하는 변수
  weak var writeCharacteristic: CBCharacteristic?
  /// 데이터를 주변 기기에 보내는 type을 설정. withResponse는 데이터를 보내면 이에 대한 답장이 오는 경우, withoutResponse는 답장이 없는 경우
  private var writeType: CBCharacteristicWriteType = .withResponse
  
  /// 주변기기가 가지고있는 서비스 UUID를 의미. 거의 모든 HM-10모듈이 기본적으로 'FFE0'을 갖고있음. 하나의 기기는 여러 서비스를 가질 수 있음.
  var serviceUUID = CBUUID(string: "FFE0")
  /// 주변기기가 가지고있는 characteristic UUID를 의미. 하나의 서비스는 여러 characteristic을 가질 수 있음.
  var characteristicUUID = CBUUID(string: "FFE1")
  
  var delegate: BluetoothSerialDelegate?
  
  // MARK: - Initializer
  override init() {
    super.init()
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
  }
  
  // MARK: - Methods
  
  /// 기기 검색 시작. 연결이 가능한 모든 주변 기기를 serviceUUID를 통해 검색
  func startScan() {
    guard centralManager.state == .poweredOn else { return }
    
    /// CBCentralManager의 메서드인 scanForPeripherals(withServices:options:)를 호출하여 연결가능한 기기들을 검색.
//    centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    centralManager.scanForPeripherals(withServices: nil, options: nil)
    
//    let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
    let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [])
    for peripheral in peripherals {
      // TODO: 검색된 기기들
      delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
    }
  }
  
  func stopScan() {
    centralManager.stopScan()
  }
  
  func connectToPeripheral(_ peripheral: CBPeripheral) {
    pendingPeripheral = peripheral
    centralManager.connect(peripheral, options: nil)
  }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothSerial: CBCentralManagerDelegate {
  
  /// central 기기의 블루투스가 켜져있는지, 꺼져있는지 등에 대한 상태가 변화할 때 마다 호출. 블루투스 켜짐: .poweredOn, 꺼짐: .poweredOff
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    pendingPeripheral = nil
    connectedPeripheral = nil
  }
  
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    /// RSSI 는 기기의 신호 강도를 의미
    /// 기기가 검색될 때마다 필요한 코드를 여기서 작성
    delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: RSSI)
  }
  
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.delegate = self
    pendingPeripheral = nil
    connectedPeripheral = peripheral
    
//    peripheral.discoverServices([serviceUUID])
    peripheral.discoverServices(nil)
  }
}

// MARK: - CBPeripheralDelegate

extension BluetoothSerial: CBPeripheralDelegate {
  
  /// 서비스 검색에 성공 시 호출되는 메서드
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
    for service in peripheral.services! {
      peripheral.discoverCharacteristics([characteristicUUID], for: service)
    }
  }
  
  /// characteristic 검색에 성공 시 호출되는 메서드
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
    for characteristic in service.characteristics! {
      if characteristic.uuid == characteristicUUID {
        /// 해당 기기의 데이터 구독 시작
        peripheral.setNotifyValue(true, for: characteristic)
        /// 데이터를 보내기 위한 characteristic을 저장
        writeCharacteristic = characteristic
        /// characteristic의 속성에 따라 데이터를 보내는 type을 설정
        writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
        /// 연결된 기기와 통신을 시작하기 위해 delegate 메서드 호출
        delegate?.serialDidConnectPeripheral(peripheral: peripheral)
      }
    }
  }
  
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
    /// writeType이 .withResponse인 경우에만 호출되는 메서드
    /// 응답을 처리하는 코드를 작성 (Optional)
  }
  
  func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?) {
    /// 블루투스 기기의 신호 강도를 요청하는 peripheral,readRSSI() 가 호출하는 함수.
    /// 신호 강도와 관련된 데이터를 처리하는 코드를 작성 (Optional)
  }
}

