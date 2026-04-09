import FoundationModels

@Generable(description: "A structured analysis of a movie review")
struct MovieReview {
    @Guide(description: "The movie title mentioned in the review")
    var title: String

    @Guide(description: "Star rating from 1 to 5", .range(1...5))
    var rating: Int

    @Guide(description: "Overall sentiment", .anyOf(["positive", "negative", "neutral"]))
    var sentiment: String

    @Guide(description: "Three key themes from the review", .count(3))
    var themes: [String]

    @Guide(description: "A one-sentence summary")
    var summary: String
}
