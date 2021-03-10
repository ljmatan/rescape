abstract class BarcodeProcessing {
  static double weight(String barcode) {
    String input = barcode.substring(7);
    input = input.substring(0, input.length - 1);
    if (input.startsWith('0')) input = input.substring(1);
    if (input.startsWith('0')) input = input.substring(1);
    if (input.startsWith('0')) input = input.substring(1);

    final double convertedValue = double.parse(input) / 1000;

    return convertedValue;
  }
}
