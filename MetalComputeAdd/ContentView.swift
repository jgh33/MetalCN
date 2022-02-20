//
//  ContentView.swift
//  MetalComputeAdd
//
//  Created by 焦国辉 on 2022/2/20.
//

import SwiftUI

struct ContentView: View {
    var adder = Adder(with: MTLCreateSystemDefaultDevice()!)!
    @State var butonTitle = "compute"
    @State var textTitle = ""
    @State var checking = false
    
    var body: some View {
        VStack {
            Text(textTitle)
            Button(butonTitle) {
                if checking {
                    verify()
                } else {
                    compute()
                }
            }
            
            
        }
        .frame(width: 500, height: 500)
        
    }
    
    
    func compute() {
        adder.prepareData()
        adder.sendComputeCommand()
        textTitle = "Metal计算完成"
        butonTitle = "verify"
        checking = true
    }
    
    func verify() {
        let resoult = adder.verifyResults()
        if resoult {
            textTitle = "yyyyyy:metal计算结果与cpu计算结果一致"
        } else {
            textTitle = "xxxxxx:metal计算结果与cpu计算结果不一致"
        }
        butonTitle = "compute"
        checking = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
