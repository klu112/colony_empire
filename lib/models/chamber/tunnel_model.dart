/// Repräsentiert einen Tunnel zwischen zwei Kammern
class Tunnel {
  final int from;
  final int to;

  const Tunnel({required this.from, required this.to});

  factory Tunnel.fromJson(Map<String, dynamic> json) {
    return Tunnel(from: json['from'] as int, to: json['to'] as int);
  }

  Map<String, dynamic> toJson() {
    return {'from': from, 'to': to};
  }
}
