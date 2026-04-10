class CreateSosRequest {
  const CreateSosRequest({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
    this.capturedAt,
    this.clientRequestId,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime? capturedAt;
  final String? clientRequestId;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
        if (capturedAt != null)
          'capturedAt': capturedAt!.toUtc().toIso8601String(),
        if (clientRequestId != null) 'clientRequestId': clientRequestId,
      };
}

class GuardInfo {
  const GuardInfo({required this.id, required this.name, this.lat, this.lng});

  factory GuardInfo.fromJson(Map<String, dynamic> json) {
    return GuardInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String name;
  final double? lat;
  final double? lng;
}

class CreateSosResponse {
  const CreateSosResponse({required this.incidentId, this.guard});

  factory CreateSosResponse.fromJson(Map<String, dynamic> json) {
    final guardJson = json['guard'] as Map<String, dynamic>?;
    return CreateSosResponse(
      incidentId: json['incidentId'] as String,
      guard: guardJson != null ? GuardInfo.fromJson(guardJson) : null,
    );
  }

  final String incidentId;
  final GuardInfo? guard;
}
