import 'dart:convert';

import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'BService.dart';

class Service {
  static double? lat, long;
  static Iterable<String> countryList = [];
  // Location location = Location();

  Future<void> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    var pos = await Geolocator.getCurrentPosition();

    lat = pos.latitude;
    // print(lat);
    long = pos.longitude;
    // print(long);
  }

  Future<String> getCity() async {
    await determinePosition();
    Address city =
        await GeoCode().reverseGeocoding(latitude: lat!, longitude: long!);
    return city.city!;
  }

  Future<Weather> getWeather() async {
    var url = Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=b54c6c3ab4d34dcf88f221822221508&q=${lat!.toStringAsFixed(2)},${long!.toStringAsFixed(2)}&aqi=no');

    var req = http.Request('GET', url);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      var w = Weather.fromJson(jsonDecode(resBody));
      // print(w);
      return w;
    } else {
      print(res.reasonPhrase);
    }
    return Weather();
  }

  Future<Weather> getWeatherCity(String city) async {
    var url = Uri.parse(
        'http://api.weatherapi.com/v1/current.json?key=b54c6c3ab4d34dcf88f221822221508&q=$city&aqi=no');

    var req = http.Request('GET', url);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      var w = Weather.fromJson(jsonDecode(resBody));
      // print(w);
      return w;
    } else {
      print(res.reasonPhrase);
    }
    return Weather();
  }

  Future<bool> getPermissions() async {
    PermissionStatus stat = await Permission.location.request();
    return false;
  }

  Future<void> getCities() async {
    var url = Uri.parse('https://countriesnow.space/api/v0.1/countries');

    var req = http.Request('GET', url);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();
    List<String> s = [];
    if (res.statusCode >= 200 && res.statusCode < 300) {
      List<dynamic> body = jsonDecode(resBody)['data'];
      for (var v in body) {
        s.addAll(Data.fromJson(v).cities!);
      }
      s.sort();
      countryList = s;
    } else {
      print(res.reasonPhrase);
    }
  }

  // Future<Request> getWeather(String city) async {
  //   print('city $city');
  //   var url = Uri.parse(
  //       'https://api.openweathermap.org/data/2.5/weather?q=$city&APPID=d45cab7342d0f8772ef2ce145f5ea447');

  //   var req = http.Request('GET', url);

  //   var res = await req.send();
  //   final resBody = await res.stream.bytesToString();

  //   if (res.statusCode >= 200 && res.statusCode < 300) {
  //     List<dynamic> body = jsonDecode(resBody)['weather'];
  //     // print(body);
  //     List<Weather> w = [];
  //     for (var v in body) {
  //       // print(v);
  //       w.add(Weather.fromJson(v));
  //     }
  //     // print(w[0].icon);
  //     var requ =
  //         Request(weather: w, main: Main.fromJson(jsonDecode(resBody)['main']));
  //     // print(requ);
  //     return Request(
  //         weather: w, main: Main.fromJson(jsonDecode(resBody)['main']));
  //   } else {
  //     print(res.reasonPhrase);
  //   }
  //   return Request();
  // }
}

// class Request {
//   List<Weather>? weather;
//   Main? main;
//   Request({
//     this.weather,
//     this.main,
//   });
// }

// class Main {
//   double? temp;
//   double? feelsLike;
//   double? tempMin;
//   double? tempMax;
//   int? pressure;
//   int? humidity;
//   Main({
//     this.temp,
//     this.feelsLike,
//     this.tempMin,
//     this.tempMax,
//     this.pressure,
//     this.humidity,
//   });

//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};

//     if (temp != null) {
//       result.addAll({'temp': temp});
//     }
//     if (feelsLike != null) {
//       result.addAll({'feelsLike': feelsLike});
//     }
//     if (tempMin != null) {
//       result.addAll({'tempMin': tempMin});
//     }
//     if (tempMax != null) {
//       result.addAll({'tempMax': tempMax});
//     }
//     if (pressure != null) {
//       result.addAll({'pressure': pressure});
//     }
//     if (humidity != null) {
//       result.addAll({'humidity': humidity});
//     }

//     return result;
//   }

//   factory Main.fromMap(Map<String, dynamic> map) {
//     return Main(
//       temp: map['temp']?.toDouble(),
//       feelsLike: map['feelsLike']?.toDouble(),
//       tempMin: map['tempMin']?.toDouble(),
//       tempMax: map['tempMax']?.toDouble(),
//       pressure: map['pressure']?.toInt(),
//       humidity: map['humidity']?.toInt(),
//     );
//   }

//   Main.fromJson(Map<String, dynamic> json) {
//     temp = json['temp'];
//     print(temp);
//     feelsLike = json['feelsLike'];
//     print(feelsLike);
//     tempMin = json['tempMin'];
//     print(tempMin);
//     tempMax = json['tempMax'];
//     print(tempMax);
//     pressure = json['pressure'];
//     print(pressure);
//     humidity = json['humidity'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['temp'] = this.temp;
//     data['feelsLike'] = this.feelsLike;
//     data['tempMin'] = this.tempMin;
//     data['tempMax'] = this.tempMax;
//     data['pressure'] = this.pressure;
//     data['humidity'] = this.humidity;
//     return data;
//   }
// }

// class Weather {
//   int? id;
//   String? main;
//   String? description;
//   String? icon;
//   Weather({
//     this.id,
//     this.main,
//     this.description,
//     this.icon,
//   });

//   Weather copyWith({
//     int? id,
//     String? main,
//     String? description,
//     String? icon,
//   }) {
//     return Weather(
//       id: id ?? this.id,
//       main: main ?? this.main,
//       description: description ?? this.description,
//       icon: icon ?? this.icon,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     final result = <String, dynamic>{};

//     if (id != null) {
//       result.addAll({'id': id});
//     }
//     if (main != null) {
//       result.addAll({'main': main});
//     }
//     if (description != null) {
//       result.addAll({'description': description});
//     }
//     if (icon != null) {
//       result.addAll({'icon': icon});
//     }

//     return result;
//   }

//   factory Weather.fromMap(Map<String, dynamic> map) {
//     return Weather(
//       id: map['id']?.toInt(),
//       main: map['main'],
//       description: map['description'],
//       icon: map['icon'],
//     );
//   }
//   Weather.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     main = json['main'];
//     description = json['description'];
//     icon = json['icon'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['main'] = this.main;
//     data['description'] = this.description;
//     data['icon'] = this.icon;
//     return data;
//   }
// }

class Data {
  String? iso2;
  String? iso3;
  String? country;
  List<String>? cities;

  Data({this.iso2, this.iso3, this.country, this.cities});

  Data.fromJson(Map<String, dynamic> json) {
    iso2 = json['iso2'];
    iso3 = json['iso3'];
    country = json['country'];
    cities = json['cities'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['iso2'] = this.iso2;
    data['iso3'] = this.iso3;
    data['country'] = this.country;
    data['cities'] = this.cities;
    return data;
  }
}
