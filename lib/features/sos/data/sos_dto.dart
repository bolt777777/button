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

class CreateSosResponse {
  const CreateSosResponse({required this.incidentId});

  factory CreateSosResponse.fromJson(Map<String, dynamic> json) {
    return CreateSosResponse(incidentId: json['incidentId'] as String);
  }

  final String incidentId;
}
