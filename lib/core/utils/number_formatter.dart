extension NumberFormatting on int {
  String toKFormat() {
    if (this >= 1000) {
      return (this / 1000).toStringAsFixed(1);
    }
    return toString();
  }
}
