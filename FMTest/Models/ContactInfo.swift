import FoundationModels

@Generable(description: "Contact information extracted from unstructured text")
struct ContactInfo {
    @Guide(description: "Person's full name")
    var name: String

    @Guide(description: "Email address if mentioned")
    var email: String?

    @Guide(description: "Phone number if mentioned")
    var phone: String?

    @Guide(description: "Company or organization name")
    var company: String?

    @Guide(description: "Job title or role")
    var role: String?
}
