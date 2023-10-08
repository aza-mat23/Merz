public class RestClient {
    private String BASE_URL = '';
    private String RESOURCE_PATH = '';

    public RestClient(String baseurl, String resourcepath) {
        this.BASE_URL = baseurl;
        this.RESOURCE_PATH = resourcepath;
    }

    public HttpResponse doGet(String endpoint, Map<String, String> query) {
        String base = BASE_URL + RESOURCE_PATH + endpoint;
        String queryParams = !query.isEmpty() ? '?' + this.buildQueryString(query) : '';
        String url = base + queryParams;
        System.debug('::::::::::::::::::: RestClient > GET: ' + url);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('charset', 'UTF-8');
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    public HttpResponse doPost(String endpoint, String requestBody) {
        String url = BASE_URL + RESOURCE_PATH + endpoint;
        System.debug('::::::::::::::::::: RestClient > POST: ' + url);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/xml');
        request.setHeader('charset', 'UTF-8');
        request.setBody(requestBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }

    public String parseResponse(HttpResponse response) {
        String result;
        if (response.getStatusCode() == 200) {
            System.debug('::::::::::::::::::: parseResponse > success: ' + response.getStatusCode());
            result = response.getBody();
        } else {
            System.debug('::::::::::::::::::: parseResponse > error ' + response.getStatusCode());
            result = 'API call failed with status code: ' + response.getStatusCode();
        }
        return result;
    }

    private String buildQueryString(Map<String, String> queryParams) {
        String queryString = '';
        for (String key : queryParams.keySet()) {
            if (!String.isEmpty(queryString)) {
                queryString += '&';
            }
            queryString += key + '=' + EncodingUtil.urlEncode(queryParams.get(key), 'UTF-8');
        }
        return queryString;
    }
}