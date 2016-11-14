app.controller('newCase', function ($scope, $http) {
    var newCase = this;
    newCase.councilorNameList = "";
    newCase.zoneList = "";
    newCase.userNameList = "";
    newCase.councilorType = ""
    newCase.caseSubmitList = {
        "Zone": {"ZoneID": ""},
        "UserLogin":{"UserLoginID": ""},
        "Councilor": {"CouncilorNameID":""},
        "contactName": "",
        "address": "",
        "suggestContent": "",
        "suggestDate": "",
        "contactTel": ""
    };
    $('#suggestDate').datetimepicker('setStartDate', '104-01-01');
    var Today = new Date();
    newCase.caseSubmitList.suggestDate = getYyyNowDate();
    $('#suggestDate').datetimepicker('setEndDate', newCase.caseSubmitList.suggestDate);
    newCase.getNewCaseItem = function () {
        $http({
            method: 'GET',
            url: "api/GetPostItem/NewCaseItem",
        }).success(function (data, status, headers, config) {
            newCase.councilorNameList = data.CouncilorName;
            newCase.zoneList = data.Zone;
            newCase.userNameList = data.UserName;
            newCase.caseSubmitList.Councilor.CouncilorNameID = data.CouncilorName[0].CouncilorNameID;
            newCase.caseSubmitList.Zone.ZoneID = data.Zone[0].ZoneID;
            newCase.caseSubmitList.UserLogin.UserLoginID = data.UserName[0].UserLoginID;
            $("#councilorName").select2({
                placeholder: data.CouncilorName[0].Name
            });
            $("#caseOfficer").select2({
                placeholder: data.UserName[0].UserName
            });
            $("#zone").select2({
                placeholder: data.Zone[0].Name
            });
        }).error(function (data, status, headers, config) {
        });
    }
    newCase.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
    }
    newCase.caseSubmit = function () {
        $('#newCase').css("display","none");
        $http({
            method: 'post',
            url: "api/GetPostCase/CaseBaseInster",
            data: newCase.caseSubmitList
        }).success(function (data, status, headers, config) {
            if (data == "ok") {
                document.location.href = "#/caseList/CaseListAll";
                reMenu();
            }
        }).error(function (data, status, headers, config) {
        });
    }
    newCase.getNewCaseItem();
})