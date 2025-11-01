import 'package:ezbus/connection/response/trip_search_response.dart';
import 'package:flutter/material.dart';
import 'package:ezbus/gui/widgets/app_bar.dart';
import 'package:ezbus/utils/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../model/bus_configuration.dart';
import '../../model/seat.dart';
import '../../utils/config.dart';
import '../languages/language_constants.dart';

import '../../model/bus.dart';
class SeatSelectionScreen extends StatefulWidget {
  final TripSearchResult? tripSearchResult;
  const SeatSelectionScreen({super.key, this.tripSearchResult});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> with SingleTickerProviderStateMixin {
  Seat? _selectedSeat;

  late List<List<Seat>> _seats = [];
  BusConfiguration? _configuration;

  @override
  void initState() {
    super.initState();
    _configuration = widget.tripSearchResult?.trip?.bus?.busConfiguration ?? BusConfiguration();
    _initializeSeats();
  }

  void _initializeSeats() {
    if (_configuration == null) return;
    _seats = List.generate(_configuration!.rows!, (rowIndex) {
      return List.generate(_configuration!.columns!, (colIndex) {
        bool exists = _configuration!.seatGrid![rowIndex][colIndex];
        //check bookedSeatsNumbers
        bool isBooked = exists && (widget.tripSearchResult?.bookedSeatsNumbers?.contains(rowIndex * _configuration!.columns! + colIndex + 1) ?? false);

        return Seat(
          row: rowIndex,
          column: colIndex,
          status: !exists
              ? SeatStatus.notExist
              : isBooked
              ? SeatStatus.booked
              : SeatStatus.available, numberOfColumns: _configuration!.columns!,
        );
      });
    });
  }

  void _selectSeat(Seat seat) {
    if (!seat.isSelectable) return;

    setState(() {
      if (_selectedSeat != null) {
        _selectedSeat!.status = SeatStatus.available;
      }

      if (_selectedSeat == seat) {
        _selectedSeat = null;
      } else {
        seat.status = SeatStatus.selected;
        _selectedSeat = seat;
      }
    });
  }

  String _getSelectedSeatsText() {
    if (_selectedSeat == null) return "";
    return "Seat-${_selectedSeat!.seatNumber} - row-${_selectedSeat!.row + 1} - col-${_selectedSeat!.column + 1}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
          context, translation(context)?.selectYourSeat ?? 'Select Your Seat'),
      body: //scroll
      Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 20.h, left: 10.h, right: 10.h, bottom: MediaQuery.of(context).size.height * 0.25),
              child: _buildSeatGrid(),
            ),
          ),
          // Bottom bar with selected seats and price
          _selectedSeat != null ? 
          Positioned(
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.25,
              padding: EdgeInsets.all(8.h),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.h),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Selected Seat',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _selectedSeat!.status = SeatStatus.available;
                                _selectedSeat = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _getSelectedSeatsText(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            //pop and pass selected seat
                            Navigator.pop(context, _selectedSeat);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: Colors.deepPurple
                                .withOpacity(0.3),
                          ),
                          child: const Text('PROCEED'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget _buildSeatGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _configuration!.columns!,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
      ),
      itemCount: _configuration!.rows! * _configuration!.columns!,
      itemBuilder: (context, index) {
        final row = index ~/ _configuration!.columns!;
        final col = index % _configuration!.columns!;
        final seat = _seats[row][col];

        if (seat.status == SeatStatus.notExist) {
          return const SizedBox(); // Empty space for non-existent seats
        }

        return GestureDetector(
          onTap: () => _selectSeat(seat),
          child: _buildSeat(seat),
        );
      },
    );
  }

  Widget _buildSeat(Seat seat) {
    Color seatColor;
    Color borderColor;
    Color textColor;

    switch (seat.status) {
      case SeatStatus.available:
        seatColor = Colors.white;
        borderColor = Colors.grey.shade400;
        textColor = Colors.black;
        break;
      case SeatStatus.selected:
        seatColor = AppTheme.primary;
        borderColor = Colors.red;
        textColor = Colors.white;
        break;
      case SeatStatus.booked:
        seatColor = Colors.grey.shade300;
        borderColor = Colors.grey.shade400;
        textColor = Colors.black54;
        break;
      case SeatStatus.notExist:
        return const SizedBox();
    }

    return Container(
      decoration: BoxDecoration(
        color: seatColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          seat.seatNumber.toString(),
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}