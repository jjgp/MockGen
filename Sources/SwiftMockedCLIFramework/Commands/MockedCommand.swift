import Commandant

public struct MockedCommand: CommandProtocol {
    public let verb = "mock"
    public let function = ""
    
    public init() {}
    
    public func run(_ options: NoOptions<CommandantError<()>>) -> Result<(), CommandantError<()>> {
        print("foo")
        return Result.success(())
    }
}
