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
                ), //null safety --> ko được để null
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

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth; //logical pixel
  static double screenHeight; //logical pixel
  double aspect;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    screenWidthGlobal = screenWidth; //2; 1.777778
  }
}

double screenWidthGlobal;

class CustomizedButton extends StatelessWidget {
  String text;
  double width, height, radius;
  Color bgColor;
  Color fgColor;
  VoidCallback onPressed;
  double fontSize;
  CustomizedButton(
      {this.text = "Tên nút",
      this.width = 250,
      this.height = 60,
      this.radius = 60,
      this.bgColor = Constants.mainColor,
      this.fgColor = Colors.white,
      this.onPressed,
      this.fontSize = 30});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: width,
        height: height,
        // ignore: deprecated_member_use
        child: RaisedButton(
          disabledColor: Colors.grey,
          color: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, color: fgColor),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class Constants {
  static const String baseUrl =
      "https://phong-kiem-tra-chat-luong-sp.herokuapp.com";
  static const Color mainColor = Color(0xff001D37);
  static const Color secondaryColor = Color(0xff00294D);
  static const Duration timeOutLimitation = Duration(seconds: 10);
}

class MonitorOperatingParamsReli extends StatefulWidget {
  String text1;
  String text2;
  String text3;
  String text4;
  String data1 = "";
  String data2 = "";
  String data3 = "";
  String data4 = "";
  MonitorOperatingParamsReli({
    Key key,
    @required this.text1,
    @required this.text2,
    @required this.text3,
    @required this.text4,
    @required this.data1,
    @required this.data2,
    @required this.data3,
    @required this.data4,
  }) : super(key: key);
  @override
  _MonitorOperatingParamsReliState createState() =>
      new _MonitorOperatingParamsReliState();
}

class _MonitorOperatingParamsReliState
    extends State<MonitorOperatingParamsReli> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              widget.text1,
              //"Thời gian đóng nắp cầu",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              widget.text2,
              //"Thời gian mở nắp cầu",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              widget.text3,
              //"Số lần đóng NBC",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              widget.text4,
              //"Thời gian đóng êm",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        SizedBox(width: SizeConfig.screenWidth * 0.08962),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: SizeConfig.screenWidth * 0.3841,
              height: SizeConfig.screenHeight * 0.03841,
              decoration: BoxDecoration(color: Colors.black26),
              child: Center(child: Text(widget.data1)),
            ),
            Container(
              width: SizeConfig.screenWidth * 0.3841,
              height: SizeConfig.screenHeight * 0.03841,
              decoration: BoxDecoration(color: Colors.black26),
              child: Center(child: Text(widget.data2)),
            ),
            Container(
              width: SizeConfig.screenWidth * 0.3841,
              height: SizeConfig.screenHeight * 0.03841,
              decoration: BoxDecoration(color: Colors.black26),
              child: Center(child: Text(widget.data3)),
            ),
            Container(
              width: SizeConfig.screenWidth * 0.3841,
              height: SizeConfig.screenHeight * 0.03841,
              decoration: BoxDecoration(color: Colors.black26),
              child: Center(child: Text(widget.data4)),
            ),
          ],
        ),
      ],
    );
  }
}
