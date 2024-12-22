//
//  BackgroundIntent.swift
//  Runner
//
//  Created by hoshizora-rin on 2024/9/19.
//

import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.zhushenwudi.lovelivemusicplayer"
private var lastLyricLine1: String = ""
private var lastLyricLine2: String = ""

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ExampleEntry {
        ExampleEntry(
            date: Date(),
            widgetFamily: context.family,
            songName: "",
            songArtist: "",
            isFavorite: false,
            isPlaying: false,
            playText: "",
            lyricLine1: "",
            lyricLine2: "",
            currentLine: 1,
            isShutdown: true,
            bgColor: "255,255,255"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ExampleEntry) -> Void) {
        let data = UserDefaults.init(suiteName: widgetGroupId)
        let songName = data?.string(forKey: "songName") ?? ""
        let songArtist = data?.string(forKey: "songArtist") ?? ""
        let isFavorite = data?.bool(forKey: "songFavorite") ?? false
        let isPlaying = data?.bool(forKey: "isPlaying") ?? false
        let playText = data?.string(forKey: "playText") ?? ""
        let lyricLine1 = data?.string(forKey: "lyricLine1")
        let lyricLine2 = data?.string(forKey: "lyricLine2")
        let currentLine = data?.integer(forKey: "currentLine") ?? 1
        let isShutdown = data?.bool(forKey: "isShutdown") ?? true
        let bgColor = data?.string(forKey: "bgColor") ?? "255,255,255"
        
        // 更新全局变量
        if let line1 = lyricLine1 {
            lastLyricLine1 = line1
        }
        if let line2 = lyricLine2 {
            lastLyricLine2 = line2
        }
        
        completion(ExampleEntry(
            date: Date(),
            widgetFamily: context.family,
            songName: songName,
            songArtist: songArtist,
            isFavorite: isFavorite,
            isPlaying: isPlaying,
            playText: playText,
            lyricLine1: lastLyricLine1,
            lyricLine2: lastLyricLine2,
            currentLine: currentLine,
            isShutdown: isShutdown,
            bgColor: bgColor
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct ExampleEntry: TimelineEntry {
    let date: Date
    let widgetFamily: WidgetFamily
    let songName: String
    let songArtist: String
    let isFavorite: Bool
    let isPlaying: Bool
    let playText: String
    let lyricLine1: String
    let lyricLine2: String
    let currentLine: Int
    let isShutdown: Bool
    let bgColor: String
}

struct HomeWidgetExampleEntryView: View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName: widgetGroupId)
    var isWhiteBackground = true
    
    init(entry: Provider.Entry, isWhiteBackground: Bool) {
        self.entry = entry
        self.isWhiteBackground = isWhiteBackground
    }

    var body: some View {
        GeometryReader { geometry in
            let cdSize: CGFloat = 140
            let coverSize: CGFloat = cdSize * 0.55
            let coverAndCdDiffSize: CGFloat = (cdSize - coverSize) / 2
            let playButtonAndCdDiffSize: CGFloat = (cdSize - 34) / 2 // width:18 + padding:8x2
            let offsetX = calcCdOffsetX(entry: entry, geometry: geometry)
            let offsetY = calcCdOffsetY(entry: entry, geometry: geometry)
            let lyricMaxWidth = geometry.size.width - cdSize
            let bgColor = calcBgColor(entry: entry)
            let playText = calcPlayText(entry: entry)
            
            ZStack {
                // 填充整个布局颜色
                if isWhiteBackground {
                    Rectangle()
                        .fill(
                            AngularGradient(
                                gradient: Gradient(
                                    colors: [
                                        Color(red: 229/255, green: 233/255, blue: 235/255),
                                        Color(red: 219/255, green: 223/255, blue: 225/255),
                                        bgColor
                                    ]
                                ),
                                center: .topLeading,
                                angle: .degrees(180 + 45)
                            )
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Rectangle()
                        .fill(Color(red: 49/255, green: 49/255, blue: 49/255))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                
                // 绘制右上角唱片
                ZStack(alignment: .topTrailing) {
                    Image(isWhiteBackground ? "cd_white" : "cd_black")
                        .resizable()
                        .scaledToFit()
                        .frame(width: cdSize, height: cdSize)
                        .clipped()
                        .offset(x: offsetX, y: offsetY)
                        .animation(.easeInOut, value: entry.isPlaying)
                    
                    if let image = loadImageFromFile() {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: coverSize, height: coverSize)
                            .clipShape(Circle())
                            .clipped()
                            .offset(x: -coverAndCdDiffSize + offsetX, y: coverAndCdDiffSize + offsetY)
                            .animation(.easeInOut, value: entry.isPlaying)
                    }
                    
                    if #available(iOSApplicationExtension 17, *) {
                        let intent = BackgroundIntent(url: URL(string: "homeWidgetExample://toggle_play"))
                        Button(intent: intent) {
                            Image(systemName: entry.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                        .offset(x: -playButtonAndCdDiffSize + offsetX, y: playButtonAndCdDiffSize + offsetY)
                    }
                }
                
                // 绘制左侧一列歌曲信息
                VStack(alignment: .leading) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .clipped()
                        .padding(.bottom, 5)
                    
                    if entry.widgetFamily == .systemMedium {
                        Text(entry.lyricLine1)
                            .font(.system(size: 15))
                            .foregroundColor(
                                entry.currentLine == 1 ? (
                                    isWhiteBackground ? .black : .white
                                ) : Color(
                                    red: 0.7,
                                    green: 0.7,
                                    blue: 0.7,
                                    opacity: 0.7
                                )
                            )
                            .frame(
                                maxWidth: entry.isPlaying ? .infinity : lyricMaxWidth,
                                alignment: .leading
                            )
                            .padding(.leading, -5)
                            .padding(.trailing, 20)

                        Text(entry.lyricLine2)
                            .font(.system(size: 15))
                            .foregroundColor(
                                entry.currentLine == 2 ? (
                                    isWhiteBackground ? .black : .white
                                ) : Color(
                                    red: 0.7,
                                    green: 0.7,
                                    blue: 0.7,
                                    opacity: 0.7
                                )
                            )
                            .frame(
                                maxWidth: entry.isPlaying ? .infinity : lyricMaxWidth, alignment: .leading)
                            .padding(.leading, -5)
                            .padding(.trailing, 10)
                    }
                    
                    Spacer()
                    
                    Text(playText)
                        .font(.system(size: 10))
                        .bold()
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 3)
                    
                    Text(entry.songName)
                        .font(.system(size: 12))
                        .bold()
                        .foregroundColor(
                            isWhiteBackground ? .black : .white
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(50)
                        .padding(.bottom, 2)
                    
                    Text(entry.songArtist)
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 30)
                        
                }
                .padding()
                
                // 绘制♥️型
                VStack {
                    Spacer()
                    if #available(iOSApplicationExtension 17, *) {
                        let intent = BackgroundIntent(url: URL(string: "homeWidgetExample://toggle_love"))
                        Button(intent: intent) {
                            Image(entry.isFavorite ? "FavoriteClick" : "FavoriteUnClick")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                        .padding(8)
                    } else {
                        Image(entry.isFavorite ? "FavoriteClick" : "FavoriteUnClick")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .padding(8)
                    }
                }
                
                // 当处于停止状态时只能跳转打开APP
                if entry.isShutdown {
                    Link(destination: URL(string: "llmp://")!) { Color.clear }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    func calcCdOffsetX(entry: ExampleEntry, geometry: GeometryProxy) -> CGFloat {
        var offset = 0.0
        switch(entry.widgetFamily) {
            case WidgetFamily.systemSmall:
                offset = (geometry.size.width - 70) / 2
                break
            case WidgetFamily.systemMedium:
                offset = (geometry.size.width - 152) / 2 + (entry.isPlaying ? 40 : 0)
                break
            default:
                break
        }
        return offset
    }
    
    func calcCdOffsetY(entry: ExampleEntry, geometry: GeometryProxy) -> CGFloat {
        var offset = 0.0
        switch(entry.widgetFamily) {
            case WidgetFamily.systemSmall:
                offset = (70 - geometry.size.height) / 2
            case WidgetFamily.systemMedium:
                offset = (152 - geometry.size.height) / 2 - (entry.isPlaying ? 40 : 0)
            default:
                break
        }
        return offset
    }
    
    func calcBgColor(entry: ExampleEntry) -> Color {
        var intColors: [Double] = [230.0, 215.0, 210.0]
        if entry.bgColor.contains(",") {
            intColors = entry.bgColor.components(separatedBy: ",").compactMap(Double.init)
        }
        return Color(
            red: Double(intColors[0]) / 255,
            green: Double(intColors[1]) / 255,
            blue: Double(intColors[2]) / 255
        )
    }
    
    func loadImageFromFile() -> UIImage? {
        let fileURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: widgetGroupId
        )?.appendingPathComponent("sharedImage.png")
        return UIImage(contentsOfFile: fileURL!.path)
    }
    
    func calcPlayText(entry: ExampleEntry) -> String {
        var playTextArr: [String] = ["播放中", "已暂停"]
        if entry.playText.contains(",") {
            playTextArr = entry.playText.components(separatedBy: ",")
        }
        return entry.isPlaying ? playTextArr[0] : playTextArr[1]
    }
}

struct HomeWidgetExampleWhite: Widget {
    let kind = "HomeWidgetExampleWhite"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { (entry) in
            HomeWidgetExampleEntryView(entry: entry, isWhiteBackground: true)
                .containerBackground(.fill.tertiary, for: .widget)
        }
            .configurationDisplayName("LLMP音乐组件")
            .contentMarginsDisabled()
            .supportedFamilies([.systemSmall, .systemMedium])
            .description("LoveLive!媒体播放器")
    }
}

struct HomeWidgetExampleBlack: Widget {
    let kind = "HomeWidgetExampleBlack"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { (entry) in
            
            HomeWidgetExampleEntryView(entry: entry, isWhiteBackground: false)
                .containerBackground(.fill.tertiary, for: .widget)
        }
            .configurationDisplayName("LLMP音乐组件")
            .contentMarginsDisabled()
            .supportedFamilies([.systemSmall, .systemMedium])
            .description("LoveLive!媒体播放器")
    }
}

#Preview(as: .systemSmall) {
    HomeWidgetExampleWhite()
} timeline: {
    ExampleEntry(
        date: Date(),
        widgetFamily: WidgetFamily.systemSmall,
        songName: "Song Name",
        songArtist: "Song Artist",
        isFavorite: true,
        isPlaying: true,
        playText: "playing,paused",
        lyricLine1: "",
        lyricLine2: "",
        currentLine: 1,
        isShutdown: true,
        bgColor: "255,255,255"
    )
}
