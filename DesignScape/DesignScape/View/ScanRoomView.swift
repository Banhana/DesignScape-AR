//
//  ScanRoomView.swift
//  DesignScape
//
//  Created by Minh Huynh on 2/8/24.
//

import SwiftUI

struct ScanRoomView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var roomController = ScanRoomController.instance
    
    @State private var doneScanning: Bool = false
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            ScanRoomViewRepresentable().onAppear(perform: {
                roomController.startSession()
            })
            .ignoresSafeArea()
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }){
                    ZStack(alignment: .center){
                        Color("Grey")
                            .opacity(0.5)
                        Image("arrow-back")
                            .frame(width: 16, height: 12)
                    }
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)
                }
                Spacer()
                if doneScanning == false {
                    Button(action: {
                        roomController.stopSession()
                        self.doneScanning = true
                    }, label: {
                        ZStack(alignment: .center){
                            Color("Grey")
                                .opacity(0.5)
                            Text("Done")
                                .font(Font.custom("Cambay-Regular", size: 14)
                                    .weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.top, 3)
                        }
                        .frame(width: 60, height: 32)
                        .cornerRadius(8)
                        
                        
                    })
                }
                //                ZStack(alignment: .center){
                //                    Color("Grey")
                //                        .opacity(0.5)
                //                    Image("cross")
                //                        .resizable()
                //                        .frame(width: 16, height: 16)
                //                        .scaledToFit()
                //                }
                //                .frame(width: 32, height: 32)
                //                .cornerRadius(8)
            }
            .padding(30)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ScanRoomView()
}
