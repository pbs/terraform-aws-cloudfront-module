// CloudFront functions support ES 5.1
// See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/functions-javascript-runtime-features.html

function stripTrailingSlashes(uri) {
	return uri.replace(/\/$/, '');
}

function handler(event) {
  var request = event.request;
  var cleanedUri = stripTrailingSlashes(request.uri);
  request.uri = cleanedUri;
  return request;
}
