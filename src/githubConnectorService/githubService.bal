import ballerina/http;
import ballerina/io;
import ballerina/log;

http:Client clientEndpoint = new ("https://api.github.com");

listener http:Listener ep0 = new (9080);

@http:ServiceConfig {
    basePath: "/github-connector"
}
service githubConnector on ep0 {

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-issues/{userName}/{repoName}"
    }
    resource function GetRepoes(http:Caller caller, http:Request req, string userName, string repoName) {

        http:Request request = new;
        request.addHeader("Authorization", "Bearer 633c3af459baa9dc01e695a1ef71010bc4a2c757");
        var response = clientEndpoint->get("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues");
        http:Response res;
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json[]) {
                getIssues(contentVal);
                error? result = caller->respond(<@untainted>contentVal[0]);
            } else {
                log:printInfo("Error Occured");
            }
        } else {
            log:printInfo("this is not httop reponse");
        }
    }
}


function getIssues(json[] issueList) {
    foreach json val in issueList {
        map<json> value = <map<json>>val;
        io:println(value.number);
        io:println(value.title);
    }
}
