import SwiftUI
import SwiftSugar

//TODO: Revisit animations
/// [ ] Put in `phaseAnimator` and still not sure what's going on. Revisit it after watching WWDC videos. It works for now though.
public struct AlertLayer: View {

    @Binding var message: String
    @Binding var isPresented: Bool
    
    @State private var internalIsPresented: Bool = false
    @State private var presentTask: Task<Void, Error>? = nil
    @State private var presentAnimationStep = 0
    
    private let BottomRadius: CGFloat = 10
    private let MaxWidth: CGFloat = 500
    private let ContentHeight: CGFloat = 50
    private let HorizontalPadding: CGFloat = 10
    private let OffscreenYOffset: CGFloat = 120

    public var body: some View {
        GeometryReader { proxy in
            VStack {
                alert(proxy)
                Spacer()
            }
        }
        .onChange(of: isPresented, isPresentedChanged)
    }
    
    init(message: Binding<String>, isPresented: Binding<Bool>) {
        _message = message
        _isPresented = isPresented
    }
    
    enum PresentAnimationPhase: CaseIterable {
        case start, middle, end
    }
    
    private func isPresentedChanged(oldValue: Bool, newValue: Bool) {
        guard newValue == true else { return }
        isPresented = false
        presentTask?.cancel()
        presentTask = Task {
            await MainActor.run {
//                withAnimation(.bouncy) {
                withAnimation {
                    internalIsPresented = true
                }
            }
            
            try await sleepTask(3, tolerance: 0.1)
            
            await MainActor.run {
//                withAnimation(.snappy) {
                withAnimation(.snappy) {
                    internalIsPresented = false
                }
            }
        }
        
    }

    private var background: some View {
        var radii: RectangleCornerRadii {
            RectangleCornerRadii(
                topLeading: 0,
                bottomLeading: BottomRadius,
                bottomTrailing: BottomRadius,
                topTrailing: 0
            )
        }
        
//        return UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
//            .fill(Color.accentColor)
        
        return VStack(spacing: 0) {
            Spacer(minLength: 0)
//            Rectangle()
//                .fill(Color.accentColor.opacity(0.2))
//            UnevenRoundedRectangle(cornerRadii: radii, style: .continuous)
            RoundedRectangle(cornerRadius: BottomRadius, style: .continuous)
                .fill(Color.accentColor)
                .frame(height: ContentHeight)
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(message)
//                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Color(.systemBackground))
            .frame(height: ContentHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 10)
        }
    }
    
    private func alert(_ proxy: GeometryProxy) -> some View {
        HStack {
            Spacer(minLength: HorizontalPadding)
            ZStack {
                background
                content
            }
            .frame(maxWidth: MaxWidth, alignment: .center)
            Spacer(minLength: HorizontalPadding)
        }
        .frame(height: ContentHeight + proxy.safeAreaInsets.top)
        .padding(.horizontal, HorizontalPadding)
        
//        .offset(y: offsetY(proxy))
        
        .phaseAnimator(PresentAnimationPhase.allCases, trigger: presentAnimationStep) { content, phase in
            content
                .offset(y: offsetY(proxy, phase: phase))
        } animation: { phase in
            switch phase {
            case .start, .middle: .easeInOut
            case .end: .bouncy
            }
        }
    }
    
    private func offsetY(_ proxy: GeometryProxy) -> CGFloat {
        var offset = -proxy.safeAreaInsets.top
        if !internalIsPresented {
            offset -= OffscreenYOffset
        }
        return offset
    }
    
    private func offsetY(_ proxy: GeometryProxy, phase: PresentAnimationPhase) -> CGFloat {
        var offset = -proxy.safeAreaInsets.top
        if !internalIsPresented {
            switch phase {
            case .start:
                offset -= OffscreenYOffset
            case .middle:
                offset -= (OffscreenYOffset / 2.0)
            case .end:
                offset -= OffscreenYOffset
            }
        }
        return offset
    }

}
