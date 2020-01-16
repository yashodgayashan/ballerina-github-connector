import ballerina/http;
import ballerina/log;
import ballerina/io;
http:Client clientEndpoint = new ("https://api.github.com");

const string ACCESS_TOKEN = "Bearer 7f4de8d30bc42f371ce52af721f45893b7462343";

listener http:Listener ep0 = new (9080);

@http:ServiceConfig {
    basePath: "/github-connector"
}
service githubConnector on ep0 {

    @http:ResourceConfig {
        methods: ["GET"],
        path: GET_ALL_ISSUES_PATH
    }
    resource function getAllIssues(http:Caller caller, http:Request req, string userName, string repoName) returns error? {

        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->get("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues?state=all", request);
        http:Response res;
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json[]) {
                error? result = caller->respond(check <@untainted>getIssues(contentVal));
            } else {
                log:printInfo("Error Occured");
            }
        } else {
            log:printInfo("this is not http reponse");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-issue/{userName}/{repoName}/{issueNumber}"
    }
    resource function getIssue(http:Caller caller, http:Request req, string userName, string repoName, string issueNumber) returns error? {

        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->get("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues/" + <@untainted>issueNumber.toString(), request);
        http:Response res;
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json) {
                error? result = caller->respond(check <@untainted>getIssue(contentVal));
            } else {
                log:printInfo("Error Occured");
            }
        } else {
            log:printInfo("this is not http reponse");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-issues/{userName}/{repoName}/{personName}"
    }
    resource function getPersonalIssue(http:Caller caller, http:Request req, string userName, string repoName, string personName) returns error? {
        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->get("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues?state?all", request);
        http:Response res;
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json[]) {
                error? result = caller->respond(check <@untainted>getPersonalIssues(contentVal, personName));
            } else {
                log:printInfo("Error Occured");
            }
        } else {
            log:printInfo("this is not http reponse");
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/post-issue/{userName}/{repoName}"
    }
    resource function postIssue(http:Caller caller, http:Request req, string userName, string repoName) returns @untainted error? {
        string? title = req.getQueryParamValue("title");
        string? body = req.getQueryParamValue("body");
        var rest = req.getJsonPayload();
        if rest is json {
            io:println(rest);
            http:Request request = new;
            request.addHeader("Authorization", ACCESS_TOKEN);
            json valu = check rest.body;
            string val = valu.toJsonString();
            io:println(val);
            request.setPayload({"title": check <@untainted>rest.title, "body": <@untainted>val});
            var response = clientEndpoint->post("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues", request);
            http:Response res;
            if (response is http:Response) {
                var contentVal = response.getJsonPayload();
                if (contentVal is json) {
                    error? result = caller->respond(<@untainted>contentVal);
                } else {
                    log:printInfo("Error Occured");
                }
            } else {
                log:printInfo("this is not http reponse");
            }
        }
        // if (title is string && body is string) {
            
        // } else {
        //     log:printInfo("query param is not valid");
        // }
    }

    @http:ResourceConfig {
        methods: ["PUT"],
        path: "/add-collaborator/{userName}/{repoName}/{collaborator}"
    }
    resource function addCollaborator(http:Caller caller, http:Request req, string userName, string repoName, string collaborator) returns error? {
        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->put("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/collaborators/" + <@untainted>collaborator.toString(), request);
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json) {
                error? result = caller->respond(response);
            } else {
                log:printInfo("Error Occured");
            }
        } else {
            log:printInfo("this is not http reponse");
        }
    }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/remove-collaborator/{userName}/{repoName}/{collaborator}"
    }
    resource function removeCollaborator(http:Caller caller, http:Request req, string userName, string repoName, string collaborator) returns error? {
        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->delete("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/collaborators/" + <@untainted>collaborator.toString(), request);
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            error? result = caller->respond(response);
        } else {
            log:printInfo("this is not http reponse");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/get-collaborator/{userName}/{repoName}"
    }
    resource function getCollaborators(http:Caller caller, http:Request req, string userName, string repoName) returns error? {
        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->get("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/collaborators", request);
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json[]) {
                error? result = caller->respond(<@untainted>getCollaborators(contentVal));
            } else {
                log:printInfo("The error with payload");
            }
        } else {
            log:printInfo("this is not http reponse");
        }
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/comment/{userName}/{repoName}/{issueNumber}"
    }
    resource function postComment(http:Caller caller, http:Request req, string userName, string repoName, string issueNumber) returns error? {
        string? body = req.getQueryParamValue("body");
        if (body is string) {
            http:Request request = new;
            request.addHeader("Authorization", ACCESS_TOKEN);
            request.setJsonPayload(<@untainted>{"body": body});
            var response = clientEndpoint->post("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues/" + <@untainted>issueNumber.toString() + "/comments", request);
            if (response is http:Response) {
                var contentVal = response.getJsonPayload();
                if (contentVal is json) {
                    error? result = caller->respond(<@untainted>contentVal);
                } else {
                    log:printInfo("The error with payload");
                }
            } else {
                log:printInfo("this is not http reponse");
            }
        } else {
            log:printError("Error in querry params");
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/comments/{userName}/{repoName}/{issueNumber}"
    }
    resource function getComments(http:Caller caller, http:Request req, string userName, string repoName, string issueNumber) returns error? {
        http:Request request = new;
        request.addHeader("Authorization", ACCESS_TOKEN);
        var response = clientEndpoint->get("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues/" + <@untainted>issueNumber.toString() + "/comments", request);
        if (response is http:Response) {
            var contentVal = response.getJsonPayload();
            if (contentVal is json[]) {
                error? result = caller->respond(check <@untainted>getComments(contentVal));
            } else {
                log:printInfo("The error with payload");
            }
        } else {
            log:printInfo("this is not http reponse");
        }
    }

//repos/:owner/:repo/issues/:issue_number/comments

// add assigns
// add labels
// remove assigness
// remove 
}

