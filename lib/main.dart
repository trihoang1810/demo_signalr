import 'package:flutter/material.dart';

import 'package:signalr_client/http_connection_options.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/hub_connection_builder.dart';

Future<String> token() async {
  final tokentemp =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJHaWEiLCJqdGkiOiI5MjkyMTZiOC0yYmMzLTQxMWEtOGE0Zi1mMzRhYTcxNDYyZGUiLCJpYXQiOjE2MjM3NTMwMTMsInJvbCI6ImFwaV9hY2Nlc3MiLCJpZCI6IjE1MDNkMWE2LTk3NDYtNDg5Zi1hYWI2LTY2YWVjZmQ3MDA1MSIsIm5iZiI6MTYyMzc1MzAxMywiZXhwIjoxNjIzNzU2NjEzLCJpc3MiOiJ3ZWJBcGkiLCJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjUwMDAvIn0.8MGi4OLXOye8EkzRTKMTfEOttvdBsR_KLULfhjF1o_8";
  return tokentemp;
}

const url = "https://phong-kiem-tra-chat-luong-sp.herokuapp.com/hub/";
ReliMonitorData reliMonitorData;
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  HubConnection hubConnection;
  @override
  void initState() {
    super.initState();
    _initSignalR();
    reliMonitorData = ReliMonitorData(
        thoiGianGiuNapDong: 0,
        thoiGianGiuNapMo: 0,
        soLanDongNapCaiDat: 0,
        soLanDongNapHienTai: 0,
        running: false,
        alarm: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(reliMonitorData.alarm.toString()),
            Text(reliMonitorData.running.toString()),
            Text(reliMonitorData.soLanDongNapCaiDat.toString()),
            Text(reliMonitorData.soLanDongNapHienTai.toString()),
            Text(reliMonitorData.thoiGianGiuNapDong.toString()),
            Text(reliMonitorData.thoiGianGiuNapMo.toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print(hubConnection.state.toString());
          hubConnection.serverTimeoutInMilliseconds = 10000000;
          hubConnection.state == HubConnectionState.Disconnected
              ? await hubConnection.start()
              : await hubConnection.stop();
          print(hubConnection.state.toString());
        },
        tooltip: 'Increment',
        child: hubConnection.state == HubConnectionState.Disconnected
            ? Icon(Icons.play_arrow)
            : Icon(Icons.stop),
      ),
    );
  }

  void _initSignalR() async {
    hubConnection = HubConnectionBuilder()
        .withUrl(url,
            options: HttpConnectionOptions(
                accessTokenFactory: () async => await token()))
        .build();
    hubConnection.onclose((error) => print(error));
    hubConnection.on("MonitorReliability", monitorReliabilityHandlers);
  }

  void monitorReliabilityHandlers(List<Object> data) {
    reliMonitorData = ReliMonitorData(
        soLanDongNapCaiDat: data[0],
        soLanDongNapHienTai: data[1],
        thoiGianGiuNapDong: data[2],
        thoiGianGiuNapMo: data[3],
        running: data[4],
        alarm: data[5]);
  }
}

class ReliMonitorData {
  ReliMonitorData({
    this.thoiGianGiuNapMo,
    this.thoiGianGiuNapDong,
    this.soLanDongNapHienTai,
    this.soLanDongNapCaiDat,
    this.alarm,
    this.running,
  });

  int soLanDongNapCaiDat;
  int soLanDongNapHienTai;
  int thoiGianGiuNapDong;
  int thoiGianGiuNapMo;
  bool alarm;
  bool running;
}
