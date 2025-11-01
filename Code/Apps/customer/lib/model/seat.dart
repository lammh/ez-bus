// Seat status enum
enum SeatStatus {
  available,
  selected,
  booked,
  notExist,
}

class Seat {
  int row;
  int column;
  SeatStatus status;
  int numberOfColumns;

  //seatNumber
  int? seatNumber;

  Seat({
    required this.row,
    required this.column,
    required this.status,
    required this.numberOfColumns,
  }) {
    seatNumber = row * numberOfColumns + column + 1;
  }

  bool get isSelectable => status == SeatStatus.available;

  // Convert Seat object to JSON
  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'column': column,
      'status': status
          .toString()
          .split('.')
          .last,
      'maxRow': numberOfColumns,
    };
  }

  // Create Seat object from JSON
  static Seat fromJson(Map<String, dynamic> json) {
    return Seat(
      row: json['row'],
      column: json['column'],
      status: SeatStatus.values.firstWhere((e) =>
      e.toString() == 'SeatStatus.${json['status']}'),
      numberOfColumns: json['maxRow'],
    );
  }

  //convert to string for display
  @override
  String toString() {
    String printData = '';
    if (status == SeatStatus.available) {
      printData = 'Available';
    } else if (status == SeatStatus.selected) {
      printData = 'Selected';
    } else if (status == SeatStatus.booked) {
      printData = 'Booked';
    } else if (status == SeatStatus.notExist) {
      printData = 'Not Exist';
    }
    if(seatNumber != null) {
      printData += ' - Seat Number: $seatNumber';
    }
    return 'Row: ${row+1} - Column: ${column+1} - Status: $printData';
  }
}