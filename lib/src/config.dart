class Config {
  /* Replace your sire url and api keys */

  //String url = 'https://guhaasmart.com';

  String url = 'http://35.226.27.186/wp-wcfm';
  String consumerKey = 'ck_09bee13907f36b8b74e4e7b3a512ec3bca127da0';
  String consumerSecret = 'cs_afacac21e1a562dfe17e188474d438bc2e0fe4e1';

/*  String url = 'http://35.226.27.186/wp-wcmp';
  String consumerKey = 'ck_c5bc75689839ab4a8e05affeffa9dbacd4e878d9';
  String consumerSecret = 'cs_5cf146330c46e4c1803712390e79f1262f0e7b2d';*/

/*
  String url = 'http://localhost:8888/newwcfm';
  String consumerKey = 'ck_621921c59423ca5f8ceb69b2c0d4953cebeba29e';
  String consumerSecret = 'cs_57313cf7d08434f8894699c7fe57d204eb8af467';*/

  String mapApiKey = 'AIzaSyBOD-xQ7u3BkkpolP5e-ykNvV4MUcA7Nmg';

  static Config _singleton = new Config._internal();

  factory Config() {
    return _singleton;
  }

  Config._internal();

  Map<String, dynamic> appConfig = Map<String, dynamic>();

  Config loadFromMap(Map<String, dynamic> map) {
    appConfig.addAll(map);
    return _singleton;
  }

  dynamic get(String key) => appConfig[key];

  bool getBool(String key) => appConfig[key];

  int getInt(String key) => appConfig[key];

  double getDouble(String key) => appConfig[key];

  String getString(String key) => appConfig[key];

  void clear() => appConfig.clear();

  @Deprecated("use updateValue instead")
  void setValue(key, value) => value.runtimeType != appConfig[key].runtimeType
      ? throw ("wrong type")
      : appConfig.update(key, (dynamic) => value);

  void updateValue(String key, dynamic value) {
    if (appConfig[key] != null &&
        value.runtimeType != appConfig[key].runtimeType) {
      throw ("The persistent type of ${appConfig[key].runtimeType} does not match the given type ${value.runtimeType}");
    }
    appConfig.update(key, (dynamic) => value);
  }

  void addValue(String key, dynamic value) =>
      appConfig.putIfAbsent(key, () => value);

  add(Map<String, dynamic> map) => appConfig.addAll(map);
}
