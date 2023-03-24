import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class BTPrinter extends StatefulWidget {
  //get data from our products page using a variable

  const BTPrinter({super.key}); //passing it to the class constructor

  @override
  State<BTPrinter> createState() => _BTPrinterState();
}

class _BTPrinterState extends State<BTPrinter> {
  //1. creating some few variables to work with

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  //list of bluetooth devices
  List<BluetoothDevice> _devices = [];

  //messages regarding bt devices
  String _devicesMessage = '';



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {initPrinter()});
  }

  //function to start scanning for available bt devices
  Future<void> initPrinter() async {
    bluetoothPrint.startScan(timeout: const Duration(seconds: 3));
    if (!mounted) return;
    bluetoothPrint.scanResults.listen(
      //scanning for all available devices
      (val) {
        if (!mounted) return;
        setState(() {
          // filling our devices array with the found devices
          _devices = val;
          print(val);
        });
        if (_devices.isEmpty) {
          setState(() {
            _devicesMessage = "No Devices Found";
            print(val);
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //showing all our devices
       appBar: AppBar(
          title: const Text('Select Printer'),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                initPrinter();// Call initPrinter when the refresh button is pressed
              },
            ),
          ],
        ),

        body: _devices.isEmpty //checking if devices is empty
            ? Center(
                child: Text(_devicesMessage),
              )
            : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context,i) {
                  return ListTile(
                    leading: const Icon(Icons.print),
                    title: Text('${_devices[i].name}'),
                    subtitle: Text('${_devices[i].address}}'),
                    onTap: () {
                      _startPrinting(_devices[i]);
                    },
                  );
                },
              ));
  }

//function to integrate the app with the bt printers
  Future<void> _startPrinting(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);

      List<LineText> list = [];
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Biryani Bites',
          weight: 2,
          width: 2,
          height: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Gopabandhu Chaka, Unit -- 8 Bhubasenswar',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Contact No: +91 99999999',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'GSTIN No: 23DKJFVR445GVVKE',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Customer Name: Mr. Pradeep Bisai',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Invoice Number: 14722',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content:
              'Invoice Date: ${DateFormat('MM/dd/yyyy').format(DateTime.now())}',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '------------------------------------------------',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '------------------------------------------------',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Thanks You!',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: 'Powered By BuyByeQ',
          weight: 0,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: '',
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
  }
}
