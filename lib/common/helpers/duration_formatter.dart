String formatSongDuration(num totalSeconds) {
  final seconds = totalSeconds.round();
  final minutesPart = (seconds ~/ 60).toString();
  final secondsPart = (seconds % 60).toString().padLeft(2, '0');
  return '$minutesPart:$secondsPart';
}
