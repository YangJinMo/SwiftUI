//
//  AdaptiveSheetViewModifier.swift
//  Utils
//
//  Created by Jmy on 2023/11/15.
//

import SwiftUI

@available(iOS 15.0, *)
struct AdaptiveSheetViewModifier<T: View>: ViewModifier {
    let sheetContent: T
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool

    init(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> T) {
        sheetContent = content()
        self.detents = detents
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        _isPresented = isPresented
    }

    func body(content: Content) -> some View {
        ZStack {
            content

            CustomSheet_UI(isPresented: $isPresented, detents: detents, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: { sheetContent }).frame(width: 0, height: 0)
        }
    }
}

@available(iOS 15.0, *)
extension View {
    func adaptiveSheet<T: View>(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> T) -> some View {
        modifier(AdaptiveSheetViewModifier(isPresented: isPresented, detents: detents, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: content))
    }
}

@available(iOS 15.0, *)
struct CustomSheet_UI<Content: View>: UIViewControllerRepresentable {
    let content: Content
    @Binding var isPresented: Bool
    let detents: [UISheetPresentationController.Detent]
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool

    init(isPresented: Binding<Bool>, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.detents = detents
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        _isPresented = isPresented
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> CustomSheetViewController<Content> {
        let vc = CustomSheetViewController(coordinator: context.coordinator, detents: detents, prefersScrollingExpandsWhenScrolledToEdge: prefersScrollingExpandsWhenScrolledToEdge, prefersEdgeAttachedInCompactHeight: prefersEdgeAttachedInCompactHeight, content: { content })
        return vc
    }

    func updateUIViewController(_ uiViewController: CustomSheetViewController<Content>, context: Context) {
        guard uiViewController.isPresented != isPresented else {
            return
        }

        uiViewController.isPresented = isPresented
    }

    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var parent: CustomSheet_UI

        init(_ parent: CustomSheet_UI) {
            self.parent = parent
        }

        // Adjust the variable when the user dismisses with a swipe
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            if parent.isPresented {
                parent.isPresented = false
            }
        }
    }
}

@available(iOS 15.0, *)
class CustomSheetViewController<Content: View>: UIViewController {
    var isPresented: Bool = false {
        didSet {
            if isPresented {
                presentModalView()
            } else {
                dismissModalView()
            }
        }
    }

    let content: Content
    let coordinator: CustomSheet_UI<Content>.Coordinator
    let detents: [UISheetPresentationController.Detent]
    let prefersScrollingExpandsWhenScrolledToEdge: Bool
    let prefersEdgeAttachedInCompactHeight: Bool
    private var isLandscape: Bool = UIDevice.current.orientation.isLandscape

    init(coordinator: CustomSheet_UI<Content>.Coordinator, detents: [UISheetPresentationController.Detent] = [.medium(), .large()], prefersScrollingExpandsWhenScrolledToEdge: Bool = false, prefersEdgeAttachedInCompactHeight: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self.coordinator = coordinator
        self.detents = detents
        self.prefersEdgeAttachedInCompactHeight = prefersEdgeAttachedInCompactHeight
        self.prefersScrollingExpandsWhenScrolledToEdge = prefersScrollingExpandsWhenScrolledToEdge
        super.init(nibName: nil, bundle: .main)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func dismissModalView() {
        dismiss(animated: true, completion: nil)
    }

    private func presentModalView() {
        let hostingController = UIHostingController(rootView: content)
        hostingController.modalPresentationStyle = .popover
        hostingController.presentationController?.delegate = coordinator as UIAdaptivePresentationControllerDelegate
        hostingController.modalTransitionStyle = .coverVertical

        if let hostPopover = hostingController.popoverPresentationController {
            hostPopover.sourceView = super.view
            let sheet = hostPopover.adaptiveSheetPresentationController
            // As of 13 Beta 4 if .medium() is the only detent in landscape error occurs
            sheet.detents = (isLandscape ? [.large()] : detents)
            sheet.prefersScrollingExpandsWhenScrolledToEdge =
                prefersScrollingExpandsWhenScrolledToEdge
            sheet.prefersEdgeAttachedInCompactHeight =
                prefersEdgeAttachedInCompactHeight
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }

        if presentedViewController == nil {
            present(hostingController, animated: true, completion: nil)
        }
    }

    /// To compensate for orientation as of 13 Beta 4 only [.large()] works for landscape
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        if UIDevice.current.orientation.isLandscape {
            isLandscape = true
            presentedViewController?.popoverPresentationController?.adaptiveSheetPresentationController.detents = [.large()]
        } else {
            isLandscape = false
            presentedViewController?.popoverPresentationController?.adaptiveSheetPresentationController.detents = detents
        }
    }
}

@available(iOS 15.0, *)
struct CustomSheetParentView: View {
    @State private var isPresented = false

    var body: some View {
        VStack {
            Button("present sheet", action: {
                isPresented.toggle()
            })
            .adaptiveSheet(isPresented: $isPresented) {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(.clear)
                    .border(Color.blue, width: 3)
                    .overlay(Text("Hello, World!").frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onTapGesture {
                            isPresented.toggle()
                        }
                    )
            }
        }
    }
}

@available(iOS 15.0, *)
struct CustomSheetView_Previews: PreviewProvider {
    static var previews: some View {
        CustomSheetParentView()
    }
}
