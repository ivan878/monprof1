// const String baseUrl = '';
const String userStorage = 'CURRENT_USER';
const String classeStorage = 'CURRENT_CLASS';
const String studentStorage = 'CURRENT_STUDENT';
const String parentStorage = 'CURRENT_PARENT';
const String localToken = 'LOCAL_USER_TOKEN';
const String refreshToken = 'REFRESH_TOKEN';
const String encryptedKey = '7MPyeQ1lUWRr4QJWqBb2M22/BMm3xOwAT/y8w4KuhBk=';

/// Client OAuth « Web » du projet Firebase `prepas-concours`.
///
/// Depuis google_sign_in 7.x, Android passe par Credential Manager et exige ce
/// `serverClientId` pour émettre un idToken. Le plugin sait le lire depuis la
/// ressource `default_web_client_id` générée par le plugin Gradle
/// google-services — mais elle n'est pas produite ici, d'où la valeur explicite.
///
/// Ce n'est pas un secret : il est déjà présent dans google-services.json,
/// embarqué dans l'APK. Valeur issue de `oauth_client` de type 3.
const String googleServerClientId =
    '382795080487-q1lhkqhn4ivrv0au85j6260ipssgeco6.apps.googleusercontent.com';
