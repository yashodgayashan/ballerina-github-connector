import ballerina/http;
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
    resource function GetAllIssues(http:Caller caller, http:Request req, string userName, string repoName) returns error? {

        http:Request request = new;
        request.addHeader("Authorization", "Bearer d72e02954614fe74a4a633f77dd9438a061558cc");
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
    resource function GetIssue(http:Caller caller, http:Request req, string userName, string repoName, string issueNumber) returns error? {

        http:Request request = new;
        request.addHeader("Authorization", "Bearer d72e02954614fe74a4a633f77dd9438a061558cc");
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
    resource function GetPersonalIssue(http:Caller caller, http:Request req, string userName, string repoName, string personName) returns error? {
        http:Request request = new;
        request.addHeader("Authorization", "Bearer d72e02954614fe74a4a633f77dd9438a061558cc");
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
    resource function PostIssue(http:Caller caller, http:Request req, string userName, string repoName) returns error? {
        string? title = req.getQueryParamValue("title");
        string? body = req.getQueryParamValue("body");
        if (title is string && body is string) {
            http:Request request = new;
            request.addHeader("Authorization", "Bearer d72e02954614fe74a4a633f77dd9438a061558cc");
            request.setPayload(<@untainted>{"title": title, "body": body});
            var response = clientEndpoint->post("/repos/" + <@untaineted>userName.toString() + "/" + <@untainted>repoName.toString() + "/issues", request);
            http:Response res;
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
        } else {
            log:printInfo("query param is not valid");
        }
    }

}

function getPersonalIssues(json[] issueList, string name) returns json | error {
    json[] issues = [];
    foreach json issue in issueList {
        map<json> issueVal = <map<json>>issue;
        map<json> user = <map<json>>issueVal.user;
        if (user.login != name) {
            continue;
        }
        json labelDetails = check getLabels(<json[]>issueVal.labels);
        json issueInfo = {
            "issueNumber":check issueVal.number,
            "issueTitle":check issueVal.title,
            "issueBody":check issueVal.body,
            "person":check user.login,
            "labels": labelDetails
        };
        issues[issues.length()] = issueInfo;
    }
    return issues;

}

function getIssues(json[] issueList) returns json | error {
    json[] issues = [];
    foreach json issue in issueList {
        map<json> issueVal = <map<json>>issue;
        map<json> user = <map<json>>issueVal.user;
        json labelDetails = check getLabels(<json[]>issueVal.labels);
        json issueInfo = {
            "issueNumber":check issueVal.number,
            "issueTitle":check issueVal.title,
            "issueBody":check issueVal.body,
            "person":check user.login,
            "labels": labelDetails
        };
        issues[issues.length()] = issueInfo;
    }
    return issues;

}


function getLabels(json[] labels) returns json | error {
    json[] labelDetails = [];
    foreach json label in labels {
        map<json> labelVal = <map<json>>label;
        labelDetails[labelDetails.length()] = {"labelName":check labelVal.name, "labelDescription":check labelVal.description};
    }
    return labelDetails;
}


function getAssignees(json[] assignees) returns string[] {
    string[] assigneesList = [];
    foreach json assignee in assignees {
        map<json> assigneeVal = <map<json>>assignee;
        assigneesList[assigneesList.length()] = assigneeVal.login.toString();
    }
    return assigneesList;
}

function getIssue(json issueDetails) returns json | error {
    map<json> user = <map<json>>issueDetails.user;
    json labelDetails = check getLabels(<json[]>issueDetails.labels);
    return {
        "issueNumber":check issueDetails.number,
        "issueTitle":check issueDetails.title,
        "issueBody":check issueDetails.body,
        "issueComments":check issueDetails.comments,
        "issueState":check issueDetails.state,
        "person":check user.login,
        "labels": labelDetails,
        "assignees": getAssignees(<json[]>issueDetails.assignees)
    };
}
