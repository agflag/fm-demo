# Foundation Models Demo

Apple Foundation Models 框架全能力演示 App，覆盖 iOS 26 / iPadOS 26 上的端侧大模型 API。

> **运行要求：** Xcode 26+，真机需启用 Apple Intelligence。模拟器可编译但无法调用模型。

## 功能演示

| # | 功能 | 核心 API | 文件 |
|---|------|----------|------|
| 1 | 可用性检查 | `SystemLanguageModel.default`, `.availability`, `.tokenCount(for:)` | `AvailabilityView.swift` |
| 2 | 文本生成 | `LanguageModelSession`, `session.respond(to:)` | `TextGenerationView.swift` |
| 3 | 流式输出 | `session.streamResponse(to:)`, `AsyncSequence` | `StreamingView.swift` |
| 4 | 结构化输出 | `@Generable`, `session.respond(to:generating:)` | `StructuredOutputView.swift` |
| 5 | 引导生成 | `@Guide(.range, .anyOf, .count)` | `GuidedGenerationView.swift` |
| 6 | 工具调用 | `Tool` 协议, `Transcript` | `ToolCallingView.swift` |
| 7 | 多轮对话 | Session 上下文保持, `Transcript` 查看 | `MultiTurnChatView.swift` |
| 8 | 动态提示词 | `@PromptBuilder` 条件组合 | `PromptBuilderView.swift` |
| 9 | 性能测试 | `session.prewarm()`, `GenerationOptions` | `PerformanceView.swift` |
| 10 | 内容标注 | `SystemLanguageModel(useCase: .contentTagging)` | `ContentTaggingView.swift` |

## 项目结构

```
FMTest/
├── FMTestApp.swift                 # App 入口
├── ContentView.swift               # NavigationSplitView 主导航
│
├── Models/                         # @Generable 数据模型
│   ├── MovieReview.swift           #   电影评论分析
│   ├── ContactInfo.swift           #   联系人信息提取
│   ├── ContentTags.swift           #   内容标签 (emotion/category/keywords)
│   └── RestaurantRecommendation.swift  #   餐厅推荐 (多种 @Guide 约束)
│
├── Tools/                          # Tool 协议实现
│   ├── WeatherTool.swift           #   天气查询 (模拟数据)
│   └── CalculatorTool.swift        #   四则运算
│
├── Components/                     # 可复用 UI 组件
│   └── FlowLayout.swift           #   自动换行流式布局
│
└── Views/                          # 各功能演示页面
    ├── AvailabilityView.swift
    ├── TextGenerationView.swift
    ├── StreamingView.swift
    ├── StructuredOutputView.swift
    ├── GuidedGenerationView.swift
    ├── ToolCallingView.swift
    ├── MultiTurnChatView.swift
    ├── PromptBuilderView.swift
    ├── PerformanceView.swift
    └── ContentTaggingView.swift
```

## 快速开始

1. 使用 Xcode 26+ 打开 `FMTest.xcodeproj`
2. 选择真机目标设备 (需支持 Apple Intelligence)
3. Build & Run
4. 从左侧导航栏选择功能进行测试

## 关键概念速查

### @Generable — 结构化输出

```swift
@Generable(description: "电影评论分析")
struct MovieReview {
    @Guide(description: "评分", .range(1...5))
    var rating: Int

    @Guide(description: "情感", .anyOf(["positive", "negative", "neutral"]))
    var sentiment: String
}

let response = try await session.respond(to: text, generating: MovieReview.self)
let review = response.content  // MovieReview 实例
```

### Tool — 工具调用

```swift
struct WeatherTool: Tool {
    let name = "getWeather"
    let description = "查询城市天气"

    @Generable struct Arguments {
        @Guide(description: "城市名") var city: String
    }

    func call(arguments: Arguments) async throws -> String {
        return fetchWeather(for: arguments.city)
    }
}

let session = LanguageModelSession(tools: [WeatherTool()])
```

### @PromptBuilder — 动态提示词

```swift
let response = try await session.respond {
    "推荐旅行目的地"
    if hasBudget { "预算 \(budget) 元" }
    if hasSeason { "季节: \(season)" }
}
```

## 参考资料

- [Apple Foundation Models Documentation](https://developer.apple.com/documentation/FoundationModels)
