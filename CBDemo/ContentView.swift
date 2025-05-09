//
//  ContentView.swift
//  CBDemo
//
//  Created by 이원빈 on 5/8/25.
//

import SwiftUI

struct ContentView: View {
  @State private var isNextViewActive = false
  
  var body: some View {
    NavigationStack {
      
      VStack {
        Image(systemName: "globe")
          .imageScale(.large)
          .foregroundStyle(.tint)
        
        Text("Hello, world!")
        
        Button {
          print("button Tapped")
          isNextViewActive = true
        } label: {
          Text("블루투스 검색시작")
        }
        .navigationDestination(isPresented: $isNextViewActive) {
          ScanView()
        }
      }
      .padding()
      .onAppear {
        serial = BluetoothSerial.init()
      }
    }
  }
}

#Preview {
  ContentView()
}

/*
 
 Central : 중앙
 Peripheral : 주변 기기
 
 
 
 */
