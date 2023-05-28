class Trip{
  final String driverID;
  final String pickUpLatPos;
  final String pickUpLongPos;
  final String dropOffLatPos;
  final String dropOffLongPos;
  final double pickUpDistance;
  final double dropOffDistance;
  final String destinationLocation;
  final String pickUpLocation;

  const Trip({
    required this.driverID,
    required this.pickUpLatPos,
    required this.pickUpLongPos,
    required this.dropOffLatPos,
    required this.dropOffLongPos,
    required this.pickUpDistance,
    required this.dropOffDistance,
    required this.destinationLocation,
    required this.pickUpLocation
});
}
