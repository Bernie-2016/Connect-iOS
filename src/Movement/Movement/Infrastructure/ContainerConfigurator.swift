import Swinject

protocol ContainerConfigurator {
    static func configureContainer(container: Container)
}
