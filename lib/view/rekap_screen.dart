// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:intl/intl.dart';
import 'package:godus/viewModel/rekap_view_model.dart';
import 'package:provider/provider.dart';
import 'package:godus/utils/utils.dart';
import 'package:godus/models/rekap.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RekapScreen extends StatefulWidget {
  const RekapScreen({super.key});

  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen> {
  late List<ExpandedTileController> _controllers;
  // TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    // initialize controller
    _controllers =
        List.generate(12, (index) => ExpandedTileController(isExpanded: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.only(top: 70, bottom: 110),
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                for (var i = 1; i <= 12; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ExpandedTile(
                      controller: _controllers[i - 1],
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      theme: const ExpandedTileThemeData(
                        headerColor: Color.fromARGB(255, 39, 95, 168),
                        headerRadius: 24.0,
                        headerPadding: EdgeInsets.all(22.0),
                        headerSplashColor: Color(0xFF215CA8),
                        contentBackgroundColor:
                            Color.fromARGB(255, 44, 116, 209),
                        contentPadding: EdgeInsets.all(24.0),
                        contentRadius: 12.0,
                      ),
                      title: Container(
                        alignment: Alignment.center,
                        child: Text(
                          DateFormat('MMMM', 'id_ID')
                              .format(DateTime(2022, i))
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: FutureBuilder<List<Rekap>>(
                        future: viewModel.getDataByMonth(i),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else if (snapshot.data!.isEmpty) {
                            return const Text(
                              "Data rekap tidak ada",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            );
                          } else {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'No',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nama',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Harga',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Status Pengantaran',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Edit',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows:
                                    snapshot.data!.asMap().entries.map((entry) {
                                  final int index = entry.key + 1;
                                  final Rekap rekap = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          index.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          rekap.namaPembeli ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          rekap.harga != null
                                              ? 'Rp${NumberFormat.decimalPattern().format(rekap.harga!)}'
                                              : '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          alignment: Alignment.center,
                                          child: ElevatedButton(
                                            onPressed:
                                                // rekap
                                                //             .idStatusPengantaran ==
                                                //         1
                                                //     ? () async {
                                                //         PanaraConfirmDialog
                                                //             .showAnimatedGrow(
                                                //           context,
                                                //           title: "Konfirmasi",
                                                //           message:
                                                //               "Apakah Anda Ingin Mengubah Status Pengantaran?",
                                                //           confirmButtonText: "Iya",
                                                //           cancelButtonText: "Tidak",
                                                //           onTapCancel: () {
                                                //             Navigator.pop(context);
                                                //           },
                                                //           onTapConfirm: () async {
                                                //             await viewModel
                                                //                 .ubahStatusPengantaran(
                                                //                     context,
                                                //                     rekap.id!);
                                                //             Navigator.pop(context);
                                                //             setState(() {});
                                                //           },
                                                //           panaraDialogType:
                                                //               PanaraDialogType
                                                //                   .normal,
                                                //         );
                                                //       }
                                                //     :
                                                null, // Tidak ada fungsi onPressed jika status sudah "Done"
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty
                                                      .resolveWith<Color>(
                                                (states) {
                                                  // Periksa nilai status pengantaran dan atur warna latar belakang sesuai
                                                  if (rekap
                                                          .idStatusPengantaran ==
                                                      1) {
                                                    return Colors
                                                        .red; // Jika status 1, warna merah
                                                  } else {
                                                    return Colors
                                                        .green; // Jika status 2, warna hijau
                                                  }
                                                },
                                              ),
                                            ),
                                            child: Text(
                                              rekap.idStatusPengantaran == 1
                                                  ? 'On Going'
                                                  : 'Done',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          onPressed: () {
                                            _showModalBottomSheetEdit(
                                                context, rekap.id!);
                                          },
                                          icon: const Icon(Icons.edit),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        debugPrint("tapped!!");
                      },
                      onLongTap: () {
                        debugPrint("long tapped!!");
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            // Panggil metode untuk menampilkan modal bottom sheet
            _showModalBottomSheet(context);
          },
          backgroundColor: const Color.fromARGB(255, 44, 116, 209),
          shape: const CircleBorder(),
          elevation: 6.0,
          child: const Icon(Icons.add, color: Colors.white, size: 36.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }

  // MODAL SHEET

  void _showModalBottomSheet(BuildContext context) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheetContent(context, viewModel);
      },
    );
  }

  // Method untuk membangun konten modal bottom sheet
  Widget _buildBottomSheetContent(
      BuildContext context, RekapViewModel viewModel) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFDADADA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        height: screenHeight * 0.776,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Tambah Pembeli',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                color: Color(0xFF4D4D4D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: viewModel.namaPembeliController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color(0xFF4D4D4D),
                ),
                labelText: 'Nama Pembeli',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.jumlahKambingController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/YoaG.png', // Ganti dengan path gambar Anda
                  width: screenWidth * 0.0558, // Ganti dengan lebar yang sesuai
                  height:
                      screenHeight * 0.0427, // Ganti dengan tinggi yang sesuai
                ),
                labelText: 'Jumlah Kambing',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: viewModel.hargaController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF4D4D4D),
                ),
                labelText: 'Harga',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              controller: viewModel.tanggalController,
              onTap: () {
                _selectDate(context);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4D4D4D),
                ),
                labelText: 'Tanggal',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              controller: viewModel.alamatController,
              onTap: () {
                _showAlamatWidget(context);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Color(0xFF4D4D4D),
                ),
                hintText: 'Alamat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    viewModel.clearAllControllers();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    elevation: 8,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: screenWidth * 0.060772727),
                    child: const Text(
                      'BATAL',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    // Periksa apakah ada yang kosong
                    if (viewModel.namaPembeliController.text.isEmpty ||
                        viewModel.jumlahKambingController.text.isEmpty ||
                        viewModel.hargaController.text.isEmpty ||
                        viewModel.tanggalController.text.isEmpty ||
                        viewModel.alamatController.text.isEmpty) {
                      Utils.showErrorSnackBar(
                        Overlay.of(context),
                        "Data Tidak Boleh Kosong",
                      );
                    } else {
                      // Semua field terisi, maka dapat melanjutkan
                      await viewModel.simpanPembeli(context);
                      viewModel.clearAllControllers();
                      Navigator.pop(context);
                      setState(
                          () {}); // Tutup dialog setelah mendapatkan lat-long
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF215CA8),
                    elevation: 8,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: screenWidth * 0.060772727),
                    child: const Text(
                      'SIMPAN',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      // Format tanggal yang dipilih dengan format 'dd-MM-yyyy'
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);

      // Menetapkan nilai tanggal yang dipilih dengan format yang diinginkan ke dalam controller
      viewModel.tanggalController.text = formattedDate;
    }
  }

  void _showAlamatWidget(BuildContext context) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // lebar dialog
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child:
                            buildTextField(viewModel.dusunController, "Dusun"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(viewModel.rtController, "RT"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(viewModel.rwController, "RW"),
                      ),
                    ],
                  ),
                  buildTextField(viewModel.jalanController, "Jalan"),
                  buildTextField(viewModel.desaController, "Desa"),
                  buildTextField(viewModel.kecamatanController, "Kecamatan"),
                  buildTextField(viewModel.kabupatenController, "Kabupaten"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // viewModel.clearAlamatControllers();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          elevation: 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011547619,
                              horizontal: screenWidth * 0.0265),
                          child: Text(
                            'BATAL',
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: screenWidth * 0.0337,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Periksa apakah ada yang kosong
                          if (viewModel.dusunController.text.isEmpty ||
                              viewModel.rtController.text.isEmpty ||
                              viewModel.rwController.text.isEmpty ||
                              viewModel.jalanController.text.isEmpty ||
                              viewModel.desaController.text.isEmpty ||
                              viewModel.kecamatanController.text.isEmpty ||
                              viewModel.kabupatenController.text.isEmpty) {
                            Utils.showErrorSnackBar(
                              Overlay.of(context),
                              "Data Tidak Boleh Kosong",
                            );
                          } else {
                            await viewModel.getLatlongPembeli();
                            _showMapWidget(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF215CA8),
                          elevation: 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011547619,
                              horizontal: screenWidth * 0.0265),
                          child: Text(
                            'SIMPAN',
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: screenWidth * 0.0337,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // viewmap tambah data

  void _showMapWidget(BuildContext context) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Set Lokasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: screenHeight * 0.3947, //ubah bagian sini
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(viewModel.latitude ?? 0, viewModel.longitude ?? 0),
                zoom: 17,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("alamat"),
                  position:
                      LatLng(viewModel.latitude ?? 0, viewModel.longitude ?? 0),
                  draggable: true,
                  onDragEnd: (LatLng newPosition) {
                    viewModel.latitude = newPosition.latitude;
                    viewModel.longitude = newPosition.longitude;
                  },
                ),
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final formattedLocation =
                    'Lat:${viewModel.latitude}, Lng:${viewModel.longitude}';

                // Perbarui alamat controller dengan lokasi yang diformat
                setState(() {
                  viewModel.alamatController.text = formattedLocation;
                });

                // Tutup dialog atau layar saat ini
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF215CA8),
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4D4D4D),
            fontFamily: 'Poppins',
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFA7A7A7),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xFFA7A7A7),
              width: 2.5,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // MODAL Sheet EDIT

  void _showModalBottomSheetEdit(BuildContext context, int id) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheetContentEdit(context, viewModel, id);
      },
    );
  }

  Widget _buildBottomSheetContentEdit(
      BuildContext context, RekapViewModel viewModel, int id) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    viewModel.getDataPembeli(id);
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFDADADA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        height: screenHeight * 0.776,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Tambah Pembeli',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                color: Color(0xFF4D4D4D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: viewModel.namaPembeliEditController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color(0xFF4D4D4D),
                ),
                labelText: 'Nama Pembeli',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: viewModel.jumlahKambingEditController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Image.asset(
                  'assets/YoaG.png', // Ganti dengan path gambar Anda
                  width: screenWidth * 0.0558, // Ganti dengan lebar yang sesuai
                  height:
                      screenHeight * 0.0427, // Ganti dengan tinggi yang sesuai
                ),
                labelText: 'Jumlah Kambing',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: viewModel.hargaEditController,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.attach_money,
                  color: Color(0xFF4D4D4D),
                ),
                labelText: 'Harga',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              controller: viewModel.tanggalEditController,
              onTap: () {
                _selectDateEdit(context);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4D4D4D),
                ),
                labelText: 'Tanggal',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontFamily: 'Poppins',
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              controller: viewModel.alamatEditController,
              onTap: () {
                _showAlamatWidgetEdit(context);
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.location_on,
                  color: Color(0xFF4D4D4D),
                ),
                hintText: 'Alamat',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 1.5, // Warna border saat tidak aktif
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFA7A7A7),
                    width: 2.5, // Warna border saat aktif
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    PanaraConfirmDialog.showAnimatedGrow(
                      context,
                      title: "Konfirmasi",
                      message: "Apakah Anda Yakin Ingin Menghapus Data?",
                      confirmButtonText: "Yakin",
                      cancelButtonText: "Tidak",
                      onTapCancel: () {
                        Navigator.pop(context);
                      },
                      onTapConfirm: () async {
                        await viewModel.hapusDataRekap(context, id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        setState(() {});
                      },
                      panaraDialogType: PanaraDialogType.custom,
                      color: Colors.red,
                    );
                    // viewModel.clearAllControllers();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 8,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: screenWidth * 0.060772727),
                    child: const Text(
                      'HAPUS',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    // Periksa apakah ada yang kosong
                    if (viewModel.namaPembeliEditController.text.isEmpty ||
                        viewModel.jumlahKambingEditController.text.isEmpty ||
                        viewModel.hargaEditController.text.isEmpty ||
                        viewModel.tanggalEditController.text.isEmpty ||
                        viewModel.alamatEditController.text.isEmpty) {
                      Utils.showErrorSnackBar(
                        Overlay.of(context),
                        "Data Tidak Boleh Kosong",
                      );
                    } else {
                      // Semua field terisi, maka dapat melanjutkan
                      await viewModel.updateRekap(context, id);
                      // viewModel.clearAllControllers();
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF215CA8),
                    elevation: 8,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: screenWidth * 0.060772727),
                    child: const Text(
                      'EDIT',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateEdit(BuildContext context) async {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      // Format tanggal yang dipilih dengan format 'dd-MM-yyyy'
      String formattedDate = DateFormat('dd-MM-yyyy').format(picked);

      // Menetapkan nilai tanggal yang dipilih dengan format yang diinginkan ke dalam controller
      viewModel.tanggalEditController.text = formattedDate;
    }
  }

  void _showAlamatWidgetEdit(BuildContext context) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // lebar dialog
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: buildTextField(
                            viewModel.dusunEditController, "Dusun"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(viewModel.rtEditController, "RT"),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildTextField(viewModel.rwEditController, "RW"),
                      ),
                    ],
                  ),
                  buildTextField(viewModel.jalanEditController, "Jalan"),
                  buildTextField(viewModel.desaEditController, "Desa"),
                  buildTextField(
                      viewModel.kecamatanEditController, "Kecamatan"),
                  buildTextField(
                      viewModel.kabupatenEditController, "Kabupaten"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // viewModel.clearAlamatControllers();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          elevation: 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011547619,
                              horizontal: screenWidth * 0.0265),
                          child: Text(
                            'BATAL',
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: screenWidth * 0.0337,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Periksa apakah ada yang kosong
                          if (viewModel.dusunEditController.text.isEmpty ||
                              viewModel.rtEditController.text.isEmpty ||
                              viewModel.rwEditController.text.isEmpty ||
                              viewModel.jalanEditController.text.isEmpty ||
                              viewModel.desaEditController.text.isEmpty ||
                              viewModel.kecamatanEditController.text.isEmpty ||
                              viewModel.kabupatenEditController.text.isEmpty) {
                            Utils.showErrorSnackBar(
                              Overlay.of(context),
                              "Data Tidak Boleh Kosong",
                            );
                          } else {
                            // Semua field terisi, maka dapat melanjutkan
                            await viewModel.getLatlongPembeliEdit();
                            // Utils.showSuccessSnackBar(
                            //   Overlay.of(context),
                            //   "Alamat Berhasil Disimpan",
                            // ); // Tunggu sampai mendapatkan lat-long
                            // Navigator.pop(
                            //     context);
                            _showMapWidgetEdit(
                                context); // Tutup dialog setelah mendapatkan lat-long
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF215CA8),
                          elevation: 8,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.011547619,
                              horizontal: screenWidth * 0.0265),
                          child: Text(
                            'SIMPAN',
                            style: TextStyle(
                              color: const Color(0xFFFFFFFF),
                              fontSize: screenWidth * 0.0337,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMapWidgetEdit(BuildContext context) {
    final viewModel = Provider.of<RekapViewModel>(context, listen: false);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Set Lokasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: screenHeight * 0.3947, //ubah bagian sini
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(viewModel.latitude ?? 0, viewModel.longitude ?? 0),
                zoom: 17,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("alamat"),
                  position:
                      LatLng(viewModel.latitude ?? 0, viewModel.longitude ?? 0),
                  draggable: true,
                  onDragEnd: (LatLng newPosition) {
                    viewModel.latitude = newPosition.latitude;
                    viewModel.longitude = newPosition.longitude;
                  },
                ),
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final formattedLocation =
                    'Lat:${viewModel.latitude}, Lng:${viewModel.longitude}';

                setState(() {
                  viewModel.alamatEditController.text = formattedLocation;
                });

                // Tutup dialog atau layar saat ini
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF215CA8),
                elevation: 8,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.011547619,
                    horizontal: screenWidth * 0.0265),
                child: Text(
                  'SIMPAN',
                  style: TextStyle(
                    color: const Color(0xFFFFFFFF),
                    fontSize: screenWidth * 0.0337,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
