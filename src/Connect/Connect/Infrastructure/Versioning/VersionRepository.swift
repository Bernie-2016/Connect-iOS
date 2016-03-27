import CBGPromise

typealias VersionFuture = Future<Version, VersionRepositoryError>
typealias VersionPromise = Promise<Version, VersionRepositoryError>

enum VersionRepositoryError: ErrorType {
    case DeserializerError(VersionDeserializerError)
    case InvalidJSON(jsonObject: AnyObject)
    case ErrorInJSONClient(JSONClientError)
    case UnknownError(ErrorType)
}

extension VersionRepositoryError: Equatable {}

func == (lhs: VersionRepositoryError, rhs: VersionRepositoryError) -> Bool {
    switch (lhs, rhs) {
    case (.InvalidJSON, .InvalidJSON):
        return true // punt on this for now.
    case (.ErrorInJSONClient(let lhsJSONClientError), .ErrorInJSONClient(let rhsJSONClientError)):
        return lhsJSONClientError == rhsJSONClientError
    default:
        return lhs._domain == rhs._domain && lhs._code == rhs._code
    }
}

protocol VersionRepository {
    func fetchCurrentVersion() -> VersionFuture
}

class StockVersionRepository: VersionRepository {
    private let jsonClient: JSONClient
    private let versionDeserializer: VersionDeserializer
    private let urlProvider: URLProvider

    init(jsonClient: JSONClient,
         versionDeserializer: VersionDeserializer,
         urlProvider: URLProvider) {
        self.jsonClient = jsonClient
        self.versionDeserializer = versionDeserializer
        self.urlProvider = urlProvider
    }

    func fetchCurrentVersion() -> VersionFuture {
        let promise = VersionPromise()

        let jsonFuture = jsonClient.JSONPromiseWithURL(urlProvider.versionURL(), method: "GET", bodyDictionary: nil)

        jsonFuture.then { jsonObject in
            guard let jsonDictionary = jsonObject as? Dictionary<String, AnyObject> else {
                promise.reject(.InvalidJSON(jsonObject: jsonObject))
                return
            }

            var version: Version!

            do {
                version = try self.versionDeserializer.deserializeVersion(jsonDictionary)
            } catch VersionDeserializerError.MissingAttribute(let attribute) {
                promise.reject(.DeserializerError(.MissingAttribute(attribute)))
                return
            } catch {
                promise.reject(.UnknownError(error))
                return
            }

            promise.resolve(version)
        }

        jsonFuture.error { receivedError in
            promise.reject(.ErrorInJSONClient(receivedError))
        }

        return promise.future
    }
}
