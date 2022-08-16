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
    
    long = pos.longitude;
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
}

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
