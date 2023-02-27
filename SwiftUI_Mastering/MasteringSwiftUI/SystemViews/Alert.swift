//
//  Mastering SwiftUI
//  Copyright (c) KxCoding <help@kxcoding.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI

struct View_Alert: View {
    @State private var result = ""

    @State private var showAlert = false
    @State private var showImageAlert = false

    @State private var imageData: ImageData? = nil

    var body: some View {
        VStack {
            Text(result)
                .font(.largeTitle)

            Button(action: {
//                showAlert.toggle()

                imageData = ImageData.sample
                showImageAlert.toggle()
            }, label: {
                Text("Show Alert")
            })
            .padding()
//            .alert(isPresented: $showAlert, content: {
//                Alert(
//                    title: Text("Alert"),
//                    message: Text("Message"),
//                    dismissButton: .default(Text("OK"))
//                )
//
//                Alert(
//                    title: Text("Alert"),
//                    message: Text("Message"),
//                    primaryButton: .destructive(
//                        Text("Delete"),
//                        action: {
//                            self.result = "Deleted"
//                        }
//                    ),
//                    secondaryButton: .cancel({
//                        self.result = "Cancelled"
//                    })
//                )
//            })
        }
//        .alert("경고장", isPresented: $showAlert) {
//            Button("확인") {
//                result = "확인"
//            }
//
//            Button("취소", role: .cancel) {
//                result = "취소"
//            }

//            Button("삭제", role: .destructive) {
//                result = "삭제"
//            }

//            Button("취소", role: .cancel) {
//                result = "취소"
//            }
//        } message: {
//            Text("조심하세요!")
//        }
        .alert("경고", isPresented: $showImageAlert, presenting: imageData, actions: { data in
            Button("필터 적용") {
                result = data.filters.joined(separator: ", ") + " 필터를 적용합니다."
            }

            Button("삭제", role: .destructive) {
                result = "\(data.name) 삭제"
            }

            Button("취소", role: .cancel) {
                result = "취소"
            }
        }, message: { data in
            Text("\(data.name) 파일에서 어떤 작업을 할까요?\n\n\(data.date)")
        })
    }
}

struct Alert_Previews: PreviewProvider {
    static var previews: some View {
        View_Alert()
    }
}
