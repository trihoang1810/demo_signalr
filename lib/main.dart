import 'package:demo_signalr/model.dart';
import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:demo_signalr/widget.dart';
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
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Constants.mainColor,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              Text(
                'THÔNG SỐ VẬN HÀNH',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.0128),
              CustomizedButton(
                fontSize: 25,
                width: SizeConfig.screenWidth * 0.5121,
                height: SizeConfig.screenHeight * 0.05121,
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
                text: "Truy xuất",
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.0128),
              Container(
                  decoration: BoxDecoration(border: Border.all()),
                  width: SizeConfig.screenWidth * 0.8962,
                  height: SizeConfig.screenHeight * 0.2561,
                  child: MonitorOperatingParamsReli(
                    text1: "Thời gian đóng nắp cầu",
                    text2: "Thời gian mở nắp cầu",
                    text3: "Số lần đóng nắp cài đặt",
                    text4: "Số lần đóng nắp hiện tại",
                    data1: reliMonitorData.soLanDongNapCaiDat.toString(),
                    data2: reliMonitorData.soLanDongNapHienTai.toString(),
                    data3: reliMonitorData.thoiGianGiuNapDong.toString(),
                    data4: reliMonitorData.thoiGianGiuNapMo.toString(),
                  )),
              SizedBox(height: SizeConfig.screenHeight * 0.0256),
              Text(
                'BẢNG GIÁM SÁT',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SizeConfig.screenHeight * 0.0256),
              Container(
                decoration: BoxDecoration(border: Border.all()),
                width: SizeConfig.screenWidth * 0.8962,
                height: SizeConfig.screenHeight * 0.2176,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: SizeConfig.screenHeight * 0.1280,
                          height: SizeConfig.screenHeight * 0.1280,
                          decoration: new BoxDecoration(
                            color: reliMonitorData.running
                                ? Colors.green
                                : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          "ĐANG CHẠY",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: SizeConfig.screenHeight * 0.1280,
                          height: SizeConfig.screenHeight * 0.1280,
                          decoration: new BoxDecoration(
                            color: reliMonitorData.alarm
                                ? Colors.red
                                : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          "CẢNH BÁO",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initSignalR() async {
    try {
      hubConnection =
          HubConnectionBuilder().withUrl(url).withAutomaticReconnect().build();
      hubConnection.keepAliveIntervalInMilliseconds = 30000;
      hubConnection.serverTimeoutInMilliseconds = 30000;
      hubConnection.onclose((error) => print(error));
      hubConnection.on("MonitorReliability", monitorReliabilityHandlers);
    } catch (e) {
      throw Exception();
    }
  }

  void monitorReliabilityHandlers(List<dynamic> data) {
    setState(() {
      reliMonitorData = ReliMonitorData(
          alarm: Map<String, dynamic>.from(data[0])["alarm"],
          running: Map<String, dynamic>.from(data[0])["running"],
          thoiGianGiuNapDong:
              Map<String, dynamic>.from(data[0])["timeLidClose"],
          thoiGianGiuNapMo: Map<String, dynamic>.from(data[0])["timeLidOpen"],
          soLanDongNapCaiDat:
              Map<String, dynamic>.from(data[0])["numberClosingSp"],
          soLanDongNapHienTai:
              Map<String, dynamic>.from(data[0])["numberClosingPv"]);
    });
  }
}



