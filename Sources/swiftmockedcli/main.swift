import Commandant
import Dispatch
import SwiftMockedCLIFramework

DispatchQueue.global().async {
    let registry = CommandRegistry<CommandantError<()>>()
    let explicitCommand = MockedCommand()
    registry.register(explicitCommand)
    
    registry.main(defaultVerb: explicitCommand.verb) { error in
        // TODO: Some sort of logging
    }
}

dispatchMain()
