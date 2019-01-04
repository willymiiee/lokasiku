import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:simple_permissions/simple_permissions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pendeteksi Lokasi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Aplikasi Pendeteksi Lokasi'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading;
  Placemark _place;

  @override
  void initState() {
    super.initState();
    _loading = false;
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Oops"),
          content: new Text("Mohon aktifkan lokasi anda dan izinkan aplikasi ini untuk mengakses lokasi."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Tutup"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
    });

    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    GeolocationStatus geolocationStatus  = await geolocator.checkGeolocationPermissionStatus();
    PermissionStatus result = await SimplePermissions.requestPermission(Permission.AccessFineLocation);

    if (geolocationStatus == GeolocationStatus.granted && result == PermissionStatus.authorized) {
      Position position = await geolocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

      if (position == null) {
        position = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }

      List<Placemark> placemarks = await geolocator.placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        setState(() {
          _loading = false;
          _place = pos;
        });
      }
    } else {
      setState(() {
        _loading = false;
      });

      _showDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _buildBody()
      ),
      bottomNavigationBar: RaisedButton(
        child: new Text(
          'Ambil lokasi sekarang',
          style: new TextStyle(fontSize: 30)
        ),
        color: Theme.of(context).accentColor,
        elevation: 4.0,
        onPressed: _getLocation,
        splashColor: Colors.blueGrey,
        textColor: Colors.white,
        padding: new EdgeInsets.all(15),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return  new CircularProgressIndicator();
    } else if (_place == null) {
      return Text('');
    } else {
      return Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Lokasi Anda sekarang:',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListTile(
                leading: Text('Alamat :'),
                title: Text(_place.thoroughfare + ' ' + _place.subThoroughfare),
              ),
              ListTile(
                leading: Text('Kelurahan :'),
                title: Text(_place.subLocality),
              ),
              ListTile(
                leading: Text('Kecamatan :'),
                title: Text(_place.locality),
              ),
              ListTile(
                leading: Text('Kabupaten :'),
                title: Text(_place.subAdministratieArea),
              ),
              ListTile(
                leading: Text('Provinsi :'),
                title: Text(_place.administrativeArea),
              ),
              ListTile(
                leading: Text('Kode Pos :'),
                title: Text(_place.postalCode),
              ),
              ListTile(
                leading: Text('Negara :'),
                title: Text(_place.country),
              ),
            ],
          ),
        ],
      );
    }
  }
}
