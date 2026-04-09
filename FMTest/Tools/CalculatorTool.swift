import FoundationModels

struct CalculatorTool: Tool {
    let name = "calculate"
    let description = "Perform a mathematical calculation with two numbers"

    @Generable(description: "Calculator arguments")
    struct Arguments {
        @Guide(description: "First number")
        var a: Double

        @Guide(description: "Second number")
        var b: Double

        @Guide(description: "Math operation to perform", .anyOf(["add", "subtract", "multiply", "divide"]))
        var operation: String
    }

    func call(arguments: Arguments) async throws -> String {
        let result: Double
        switch arguments.operation {
        case "add": result = arguments.a + arguments.b
        case "subtract": result = arguments.a - arguments.b
        case "multiply": result = arguments.a * arguments.b
        case "divide":
            guard arguments.b != 0 else { return "Error: Division by zero" }
            result = arguments.a / arguments.b
        default:
            return "Unknown operation: \(arguments.operation)"
        }
        return "\(arguments.a) \(arguments.operation) \(arguments.b) = \(result)"
    }
}
