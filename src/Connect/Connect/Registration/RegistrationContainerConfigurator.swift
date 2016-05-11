import Swinject

class RegistrationContainerConfigurator: ContainerConfigurator {
    class func configureContainer(container: Container) {
        container.register(VoterRegistrationController.self) { resolver in
            return VoterRegistrationController(tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!)
        }
    }
}
