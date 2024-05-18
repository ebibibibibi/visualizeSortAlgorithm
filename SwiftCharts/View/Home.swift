import SwiftUI
import Charts

struct Home: View {
    // Environment Scheme
    @Environment(\.colorScheme) var scheme
    // MARK: State Chart Data For Animation Changes
    @State var sampleAnalytics: [SiteView] = sample_analytics
    // MARK: View Properties
    @State var currentTab: String = "バブルソート"
    // MARK: Gesture Properties
    @State var currentActiveItem: SiteView?
    @State var plotWidth: CGFloat = 0
    @State var sortCount: Int = 0
    @State var maxSortCount: Int = 0
    @State var sampleDemoAnalytics: [SiteView] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: New Chart API
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Views")
                            .fontWeight(.semibold)
                        
                        Picker("", selection: $currentTab) {
                            Text("バブルソート")
                                .tag("バブルソート")
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading, 80)
                    }
                    
                    AnimatedChart()
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill((scheme == .dark ? Color.black : Color.white).shadow(.drop(radius: 2)))
                }
                
                Button("OK") {
                    bubbleSortStep()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
            .navigationTitle("Swift Charts")
            
            .onChange(of: sortCount) { newValue in
                print("sortCount changed: \(newValue)")
                print("変化前の値: \(sampleDemoAnalytics)")
                sampleAnalytics = sampleDemoAnalytics
                animateGraph(fromChange: true)
                
                print("変化した値: \(sampleAnalytics)")
                
            }
        }
        .onAppear {
            self.maxSortCount = sampleAnalytics.count
            self.sampleDemoAnalytics = sampleAnalytics // 初期化
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        /// 最大値の取得
        /// Y軸のスケール設定に使用
        let max = sampleAnalytics.max { item1, item2 in
            return item2.views > item1.views
        }?.views ?? 0
        
        /// グラフの描画
        /// item.animate が true の場合にのみ views 値を表示
        Chart {
            ForEach(sampleAnalytics) { item in
                BarMark(
                    x: .value("Hour", item.hour, unit: .hour),
                    y: .value("Views", item.animate ? item.views : 0)
                )
                /// 青色のグラデーションを適応する
                .foregroundStyle(Color("Blue").gradient)
            }
        }
        .chartYScale(domain: 0...(max + 5000))
        .chartOverlay(content: { proxy in
            GeometryReader { innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let location = value.location
                                if let date: Date = proxy.value(atX: location.x) {
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: date)
                                    if let currentItem = sampleAnalytics.first(where: { item in
                                        calendar.component(.hour, from: item.hour) == hour
                                    }) {
                                        self.currentActiveItem = currentItem
                                        self.plotWidth = proxy.plotAreaSize.width
                                    }
                                }
                            }
                            .onEnded { value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .frame(height: 250)
        .onAppear {
            animateGraph()
        }
    }
    
    // MARK: Animating Graph
    func animateGraph(fromChange: Bool = false) {
        for (index, _) in sampleAnalytics.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)) {
                withAnimation(fromChange ? .easeInOut(duration: 0.6) : .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)) {
                    sampleAnalytics[index].animate = true
                }
            }
        }
    }
    
    // MARK: Bubble Sort Step with Animation
    func bubbleSortStep() {
        if sortCount >= maxSortCount {
            return
        }
        print("🥚🪺🍓")
        // 内部ループの実装
        for sortIndex in 0 ..< maxSortCount - sortCount - 1 {
            if sampleDemoAnalytics[sortIndex].views > sampleDemoAnalytics[sortIndex + 1].views {
                withAnimation(.easeInOut) {
                    print("🍓🍓")
                    // 要素の交換
                    print("\(sampleDemoAnalytics[sortIndex].views)と\(sampleDemoAnalytics[sortIndex].hour)")
                    print("\(sampleDemoAnalytics[sortIndex + 1].views)と\(sampleDemoAnalytics[sortIndex+1].hour)")
                    let tempHour = sampleDemoAnalytics[sortIndex].hour
                    sampleDemoAnalytics[sortIndex].hour = sampleDemoAnalytics[sortIndex + 1].hour
                    sampleDemoAnalytics[sortIndex + 1].hour = tempHour
                    let temp = sampleDemoAnalytics[sortIndex]
                    sampleDemoAnalytics[sortIndex] = sampleDemoAnalytics[sortIndex + 1]
                    sampleDemoAnalytics[sortIndex + 1] = temp
                    print("🪺🪺")
                    print("\(sampleDemoAnalytics[sortIndex].views)と\(sampleDemoAnalytics[sortIndex].hour)")
                    print("\(sampleDemoAnalytics[sortIndex + 1].views)と\(sampleDemoAnalytics[sortIndex + 1].hour)")
                    print("🍓🍓")
                    
                }
            }
        }
        sortCount += 1
        print(sampleAnalytics)
    }
}

extension Double {
    var stringFormat: String {
        if self >= 10000 && self < 999999 {
            return String(format: "%.1fK", locale: Locale.current, self / 1000).replacingOccurrences(of: ".0", with: "")
        }
        if self > 999999 {
            return String(format: "%.1fM", locale: Locale.current, self / 1000000).replacingOccurrences(of: ".0", with: "")
        }
        return String(format: "%.0f", locale: Locale.current, self)
    }
}
