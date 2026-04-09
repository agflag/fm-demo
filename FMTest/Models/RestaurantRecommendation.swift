import FoundationModels

@Generable(description: "A restaurant recommendation with detailed information")
struct RestaurantRecommendation {
    @Guide(description: "Restaurant name")
    var name: String

    @Guide(description: "Type of cuisine", .anyOf(["中餐", "日料", "西餐", "韩餐", "东南亚菜", "甜品", "其他"]))
    var cuisine: String

    @Guide(description: "Price level from 1 (cheapest) to 5 (most expensive)", .range(1...5))
    var priceLevel: Int

    @Guide(description: "Quality rating from 1 to 10", .range(1...10))
    var rating: Int

    @Guide(description: "Brief description of the restaurant")
    var description: String

    @Guide(description: "Three must-try dishes", .count(3))
    var mustTryDishes: [String]
}
