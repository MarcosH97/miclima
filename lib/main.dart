import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:miclima/BService.dart';
import 'package:miclima/Service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    getLocation();
    Service().getCities();
    super.initState();
  }

  final controller = TextEditingController();
  static bool celsius = true;
  static String city = 'loading...';
  String searcher = '';
  static String icon = '';
  static double tempc = 0;
  static double tempf = 0;
  static double feels = 0;
  static Weather weather = Weather();
  bool show = true;

  getLocation() async {
    var requ = null;
    var s = await Service().getCity().then((value) {
      getWeather();
      return value;
    });
    setState(() {
      city = s;
    });
  }

  getWeather() async {
    weather = await Service().getWeather();
    setState(() {
      tempc = weather.current!.tempC!;
      tempf = weather.current!.tempF!;
      icon = 'http:' + weather.current!.condition!.icon!;
      show = false;
    });
    // print(weather.current!.tempC);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                show = true;
              });
              return getLocation();
            },
            backgroundColor: Colors.grey,
            child: Icon(Icons.refresh),
          ),
          backgroundColor: Colors.black,
          body: RefreshIndicator(
            onRefresh: () {
              setState(() {
                show = true;
              });
              return getLocation();
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (show) LinearProgressIndicator(),
                  SizedBox(height: 10),
                  Autocomplete<String>(
                    onSelected: (option) async {
                      setState(() {
                        show = true;
                      });
                      weather = await Service().getWeatherCity(option);
                      setState(() {
                        city = option;
                        tempc = weather.current!.tempC!;
                        tempf = weather.current!.tempF!;
                        icon = 'http:' + weather.current!.condition!.icon!;
                        show = false;
                        // controller.text = '';
                        option = '';
                      });
                    },
                    optionsBuilder: (textEditingValue) {
                      return Service.countryList
                          .where((element) =>
                              element.startsWith(textEditingValue.text))
                          .toList();
                    },
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        onSubmitted: (value) async {
                          setState(() {
                            show = true;
                          });
                          weather = await Service().getWeatherCity(value);
                          setState(() {
                            city = value;
                            tempc = weather.current!.tempC!;
                            tempf = weather.current!.tempF!;
                            icon = 'http:' + weather.current!.condition!.icon!;
                            show = false;
                            // controller.text = '';
                            textEditingController.text = '';
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Colors.white)),
                          label: Text('Search City', style: TextStyle(color: Colors.grey),),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(100),
                              borderSide: BorderSide(color: Colors.white)),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  show = true;
                                });
                                getLocation();
                              },
                              icon: const Icon(
                                Icons.location_on,
                                size: 42,
                                color: Colors.white,
                              )),
                          Text(
                            city,
                            style: TextStyle(color: Colors.white, fontSize: 50),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Latitude: ${weather.current != null ? weather.location!.lat! : '...'}',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                              'Longitude: ${weather.current != null ? weather.location!.lon! : '...'}',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    child: Text(
                      '${celsius ? tempc.toStringAsFixed(1) : tempf.toStringAsFixed(1)}º${celsius ? 'C' : 'F'}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                          fontWeight: FontWeight.w200),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => setState(() {
                      celsius = !celsius;
                    }),
                  ),
                  Container(
                    height: 64,
                    width: 64,
                    child: Image.network(
                      icon,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        return loadingProgress == null
                            ? child
                            : Container(
                                width: 50,
                                height: 50,
                                child: const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.blue)),
                              );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 64,
                        height: 64,
                        child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.blue)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    weather.current != null
                        ? weather.current!.condition!.text!
                        : '...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: ListTile(
                        title: Text('Humidity:',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            '${weather.current != null ? weather.current!.humidity! : '...'}%',
                            style: TextStyle(color: Colors.grey)),
                      )),
                      Expanded(
                          child: ListTile(
                        title: Text('Feels Like:',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            '${weather.current != null ? (celsius ? weather.current!.feelslikeC! : weather.current!.feelslikeF!) : '...'}º${celsius ? 'C' : 'F'}',
                            style: TextStyle(color: Colors.grey)),
                      )),
                      Expanded(
                          child: ListTile(
                        title: Text('Wind:',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            '${weather.current != null ? weather.current!.windKph! : '...'}km/h',
                            style: TextStyle(color: Colors.grey)),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
