class APIEndpoint {
  static const String selectAndDownload =
      'http://127.0.0.1:8000/api_endpoint/search_and_download/{bounding_x1}:{bounding_y1}/{bounding_x2}:{bounding_y2}/{bounding_x3}:{bounding_y3}/{bounding_x4}:{bounding_y4}'; // x: longitude, y: latitude
  static const String downloadSelectedImage =
      'http://127.0.0.1:8000/api_endpoint/download_raw_by_id/{id_list}'; // id_list format: 1:3:15:26:33:......:66
  static const String coregImageFetch =
      'http://127.0.0.1:8000/api_endpoint/coreg_image_fetch';
  static const String coregSubmit =
      'http://127.0.0.1:8000/api_endpoint/coreg_submit/{master}/{slave}/{master_swath}/{slave_swath}';
  static const String createInterferogramImageFetch =
      'http://127.0.0.1:8000/api_endpoint/interf_image_fetch';
  static const String interferogramSubmit =
      'http://127.0.0.1:8000/api_endpoint/interf_image_generate/{master_slave_pair}';
  static const String deburstImageFetch =
      'http://127.0.0.1:8000/api_endpoint/deburst_image_fetch';
  static const String deburstSubmit =
      'http://127.0.0.1:8000/api_endpoint/deburst_image_generate/{image_name}';
  static const String topographicPhaseRemovalImageFetch =
      'http://127.0.0.1:8000/api_endpoint/tpr_image_fetch';
  static const String topographicPhaseRemovalSubmit =
      'http://127.0.0.1:8000/api_endpoint/tpr_image_generate/{image_name}';
  static const String multilookingImageFetch =
      'http://127.0.0.1:8000/api_endpoint/multilooking_image_fetch';
  static const String multilookingSubmit =
      'http://127.0.0.1:8000/api_endpoint/multilooking_image_generate/{image_name}/{multilooking_times}';
  static const String goldsteinPhaseFilteringImageFetch =
      'http://127.0.0.1:8000/api_endpoint/gpf_image_fetch';
  static const String goldsteinPhaseFilteringSubmit =
      'http://127.0.0.1:8000/api_endpoint/gpf_image_generate/{image_name}';
  static const String phaseUnwrappingImageFetch =
      'http://127.0.0.1:8000/api_endpoint/phase_unwrapping_image_fetch';
  static const String phaseUnwrappingSubmit =
      'http://127.0.0.1:8000/api_endpoint/phase_unwrapping_image_generate/{image_name}';
  static const String phaseToDisplacementImageFetch =
      'http://127.0.0.1:8000/api_endpoint/p2d_image_fetch';
  static const String phaseToDisplacementSubmit =
      'http://127.0.0.1:8000/api_endpoint/p2d_image_generate/{image_name}';
  static const String rangeDopplerTerrainCorrectionImageFetch =
      'http://127.0.0.1:8000/api_endpoint/rdc_image_fetch';
  static const String rangeDopplerTerrainCorrectionSubmit =
      'http://127.0.0.1:8000/api_endpoint/rdc_image_generate/{image_name}';
  static const String currentDownloadingItems =
      'http://127.0.0.1:8000/api_endpoint/downloading_items';
  static const String cancelDownloadByTimeStamp =
      'https://run.mocky.io/v3/96c75cb4-9a36-43ef-be20-d9f02a3c09e5/{time_stamp}';
      static const String getWorkspaceItems='http://127.0.0.1:8000/api_endpoint/workspace';
  static const String deleteWorkspaceEntry='https://run.mocky.io/v3/686a9a73-c5b1-47c5-9f50-f40925b05339/{id}';
}
