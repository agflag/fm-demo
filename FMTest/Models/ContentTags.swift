import FoundationModels

@Generable(description: "Content analysis tags extracted from text")
struct ContentTags {
    @Guide(description: "Main topic of the content")
    var topic: String

    @Guide(description: "Emotional tone", .anyOf(["开心", "难过", "愤怒", "平静", "兴奋", "担忧", "期待"]))
    var emotion: String

    @Guide(description: "Key keywords from the content", .maximumCount(5))
    var keywords: [String]

    @Guide(description: "Content category", .anyOf(["新闻", "观点", "教程", "故事", "评测", "其他"]))
    var category: String

    @Guide(description: "Importance level from 1 to 10", .range(1...10))
    var importance: Int
}
