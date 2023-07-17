import Combine
import SwiftUI

open class Store<Event, Action> {
    private(set) var events = PassthroughSubject<Event, Never>()
    private(set) var actions = PassthroughSubject<Action, Never>()
    
    var bag = Bag()
    
    public init() {
        setupActionHandlers()
    }
    
    public func sendAction(_ action: Action) {
        actions.send(action)
    }
    
    public func sendEvent(_ event: Event) {
        events.send(event)
    }
    
    func setupActionHandlers() {
        actions.sink { [weak self] action in
            guard let self = self else { return }
            self.handleActions(action: action)
        }.store(in: &bag)
    }
    
    public func handleActions(action: Action) {
        
    }
}
