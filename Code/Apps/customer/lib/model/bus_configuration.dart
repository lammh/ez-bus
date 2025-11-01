class BusConfiguration {
  int? rows;
  int? columns;
  List<List<bool>>? seatGrid;
  List<List<bool>>? bookedSeats;

  BusConfiguration({
    this.rows,
    this.columns,
    this.seatGrid,
    this.bookedSeats,
  });

  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'columns': columns,
      'seat_grid': seatGrid,
      'booked_seats': bookedSeats,
    };
  }

  static BusConfiguration fromJson(Map<String, dynamic> json) {
    return BusConfiguration(
      rows: json['rows'],
      columns: json['columns'],
      seatGrid: List<List<bool>>.from(
          json['seatGrid'].map((x) => List<bool>.from(x.map((x) => x)))),
      // bookedSeats: List<List<bool>>.from(
      //     json['booked_seats'].map((x) => List<bool>.from(x.map((x) => x)))),
    );
  }

  // factory BusConfiguration.sample() {
  //   return BusConfiguration(
  //     rows: 7,
  //     columns: 4,
  //     seatGrid: [
  //       [true, false, false, true],
  //       [true, true, true, true],
  //       [true, false, true, true],
  //       [true, true, true, true],
  //       [true, true, true, true],
  //       [true, true, true, true],
  //       [true, true, true, true],
  //     ],
  //     bookedSeats: [
  //       [true, false, false, false],
  //       [true, false, false, false],
  //       [false, false, true, true],
  //       [true, false, true, true],
  //       [true, true, true, true],
  //       [true, false, false, false],
  //       [true, false, false, false],
  //     ],
  //   );
  // }

}
