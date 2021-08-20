import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

const url = "https://phong-kiem-tra-chat-luong-sp.herokuapp.com/hub";

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
  List list = ['a', 'b', 'c', 'd', 'e', 'f'];
  @override
  void initState() {
    super.initState();
    _initSignalR();
    reliMonitorData = ReliMonitorData(
        thoiGianGiuNapDong: "0",
        thoiGianGiuNapMo: "0",
        soLanDongNapCaiDat: "0",
        soLanDongNapHienTai: "0",
        running: false.toString(),
        alarm: false.toString());
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
            Text(list[0].toString()),
            Text(list[1].toString()),
            Text(list[2].toString()),
            Text(list[3].toString()),
            Text(list[4].toString()),
            Text(list[5].toString()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          print('--> đang tìm kết nối');
          print('Kết nối là ${hubConnection.state}');
          hubConnection.state == HubConnectionState.disconnected
              ? await hubConnection
                  .start()
                  .onError((error, stackTrace) => print(error))
              : await hubConnection.stop();
          print('--> kết nối thành công?');
          print('Kết nối hiện tại là ${hubConnection.state}');
        },
        tooltip: 'Connect',
        child: hubConnection.state == HubConnectionState.disconnected
            ? Icon(Icons.play_arrow)
            : Icon(Icons.stop),
      ),
    );
  }

  void _initSignalR() async {
    hubConnection =
        HubConnectionBuilder().withUrl(url).withAutomaticReconnect().build();
    hubConnection.keepAliveIntervalInMilliseconds = 30000;
    hubConnection.serverTimeoutInMilliseconds = 30000;
    hubConnection.onclose((error) => print(error));
    hubConnection.on("MonitorReliability", _monitorReliabilityHandlers);
  }

  void _monitorReliabilityHandlers(List<Object> data) {
    print(data.length);
    print(data.first);
    reliMonitorData = ReliMonitorData(
      soLanDongNapCaiDat: data[0].toString(),
      soLanDongNapHienTai: data[1].toString(),
      thoiGianGiuNapDong: data[2].toString(),
      thoiGianGiuNapMo: data[3].toString(),
      running: data[4].toString(),
      alarm: data[5].toString(),
    );
    print(reliMonitorData.soLanDongNapCaiDat);
    setState(() {
      list.clear();
      list.add(reliMonitorData.alarm.toString());
      list.add(reliMonitorData.running.toString());
      list.add(reliMonitorData.soLanDongNapCaiDat.toString());
      list.add(reliMonitorData.soLanDongNapHienTai.toString());
      list.add(reliMonitorData.thoiGianGiuNapDong.toString());
      list.add(reliMonitorData.thoiGianGiuNapMo.toString());
    });
    print('thanh cong');
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

  String soLanDongNapCaiDat;
  String soLanDongNapHienTai;
  String thoiGianGiuNapDong;
  String thoiGianGiuNapMo;
  String alarm;
  String running;
}
