import FoundationModels

struct WeatherTool: Tool {
    let name = "getWeather"
    let description = "Get the current weather for a given city"

    @Generable(description: "Arguments for weather query")
    struct Arguments {
        @Guide(description: "The city name to query weather for")
        var city: String
    }

    func call(arguments: Arguments) async throws -> String {
        // Simulated weather data for demo purposes
        let conditions = ["晴天 25°C", "多云 22°C", "小雨 18°C", "阴天 20°C", "晴朗 30°C"]
        let humidity = Int.random(in: 40...90)
        let condition = conditions.randomElement() ?? "晴天 25°C"
        return "\(arguments.city): \(condition), 湿度 \(humidity)%"
    }
}
