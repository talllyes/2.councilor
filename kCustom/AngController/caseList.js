/// <reference path="../angular.js" />
/// <reference path="../Kai-ng-ui.js" />
app.controller('caseList', function ($scope, $http, $routeParams, $filter) {
    var caseList = this;
    var sendCaseBase = "";
    caseList.zoneList = [];
    caseList.councilorNameList = [];
    caseList.userNameList = [];
    caseList.backgroundColor = "";
    caseList.user = $scope.rootBase.user;
    caseList.nowUrl = "";
    caseList.minDate = "";

    caseList.excelType = "0";
    caseList.excelOut = true;
    caseList.excelCol = {
        "CaseBaseID": "check",
        "SuggestDate": "check",
        "SuggestContent": "check",
        "CouncilorName": "check",
        "Zone": "check",
        "Address": "check",
        "CaseOfficer": "check",
        "ContactName": "check",
        "ContactTel": "check",
        "ExecuteContent": "check",
        "State": "check"
    }

    //設定kaiSearch
    caseList.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'caseList.myPage',
        maxSize: 5,
        itemsPerPage: 10,
        watch: ["searchKey", "councilorName", "zone", "caseOfficer"],
        searchDate: ["1", "SuggestDate"],
        orderBy: [$filter('orderBy'), "SuggestDate", true]
    });

    caseList.myPage.zone = "";
    caseList.myPage.councilorName = "";
    caseList.myPage.caseOfficer = ""
    caseList.myPage.searchKey = "";

    $('#searchStartDate').datetimepicker('setEndDate', getYyyNowDate());
    $('#searchEndDate').datetimepicker('setEndDate', getYyyNowDate());
    $('#endDate').datetimepicker('setEndDate', getYyyNowDate());

    //讀取列表
    function getCaseList() {
        $http({
            method: 'GET',
            url: "api/GetPostCase/" + $routeParams.type,
        }).success(function (data, status, headers, config) {
            caseList.myPage.setData(data.CaseBase);
            caseList.myPage.CouncilorNameList = data.CouncilorName;
            caseList.myPage.ZoneList = data.Zone;
            caseList.myPage.CaseOfficerList = data.CaseOfficer;
            caseList.myPage.startDate = data.minDate;
            caseList.minDate = caseList.myPage.startDate;
            $('#searchStartDate').datetimepicker('setStartDate', caseList.myPage.startDate);
            $('#searchEndDate').datetimepicker('setStartDate', caseList.myPage.startDate);
            $(".caseListItem").css("display", "");
            $(".caseListItem").animate({ opacity: 1 }, 700);
        }).error(function (data, status, headers, config) {
        });
    }
    getCaseList();
    //上面麵包屑
    if ($routeParams.type == "CaseListAll") {
        caseList.nowUrl = "全部";
    } else if ($routeParams.type == "My") {
        caseList.nowUrl = "個人待辦";
    } else if ($routeParams.type == "1") {
        caseList.nowUrl = "號誌股";
    } else if ($routeParams.type == "2") {
        caseList.nowUrl = "交控股";
    } else if ($routeParams.type == "OverDate") {
        caseList.nowUrl = "逾期案件";
    } else if ($routeParams.type == "End") {
        caseList.nowUrl = "結案";
    }

    caseList.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
    }

    caseList.setSearchNull = function () {
        caseList.myPage.zone = "";
        caseList.myPage.councilorName = "";
        caseList.myPage.caseOfficer = "";
        caseList.myPage.searchKey = "";
        caseList.myPage.endDate = getYyyNowDate();
        caseList.myPage.startDate = caseList.minDate;
    }

    caseList.editCase = function (type, item) {
        if (type == "edit") {
            if ((item.CaseOfficer.UserLoginID == caseList.user.UserLoginID) || $scope.rootBase.user.Admin == "1" || $scope.rootBase.user.Admin == "2") {
                var showFlag = false;
                var showFlag2 = false;
                caseList.backgroundColor = "background-color:#FAFAFA";
                sendCaseBase = item;
                $(".caseListItem").animate({ opacity: 0 }, 300, function () {
                    $(".caseListItem").css("display", "none");
                    if (showFlag2) {
                        $(".caseEditItem").css("display", "");
                    }
                    showFlag = true;
                });
                $('#endDate').datetimepicker('setStartDate', item.SuggestDate);
                $http({
                    method: 'POST',
                    url: "api/GetPostCase/EditCase",
                    data: item.CaseBaseID
                }).success(function (data, status, headers, config) {
                    caseList.editList = data.CaseBase;
                    if (showFlag) {
                        $(".caseEditItem").css("display", "");
                    }
                    showFlag2 = true;
                    caseList.councilorNameList = data.CouncilorName
                    $("#councilorName").select2({
                        placeholder: data.CaseBase.CouncilorName.Name
                    });
                    caseList.zoneList = data.Zone;
                    $("#zone").select2({
                        placeholder: data.CaseBase.Zone.Name
                    });
                    caseList.userNameList = data.UserName;
                    $("#caseOfficer").select2({
                        placeholder: data.CaseBase.CaseOfficer.UserName
                    });
                    $(".select2-selection__rendered").addClass("text-left");
                }).error(function (data, status, headers, config) {
                });
            }
        } else if (type == "ok") {
            if (yyyToDateTime(caseList.editList.SuggestDate) <= yyyToDateTime(caseList.editList.EndDate) || caseList.editList.EndDate == "") {
                caseList.backgroundColor = "";
                $(".caseEditItem").css("display", "none");
                $(".caseEditItem").css("opacity", 1);
                $http({
                    method: 'POST',
                    url: "api/GetPostCase/CaseBaseUpdate",
                    data: caseList.editList
                }).success(function (data, status, headers, config) {
                    if (data == "ok") {
                        getCaseList();
                        caseList.editList = [];
                    } else {
                        alert(data);
                        $(".caseEditItem").css("display", "");
                    }
                }).error(function (data, status, headers, config) {
                });
            } else {
                alert("結案日期不可小於建議日期！");
            }
        } else if (type == "no") {
            caseList.editList = [];
            caseList.backgroundColor = "";
            $(".caseEditItem").css("display", "none");
            $(".caseEditItem").css("opacity", 1);
            $(".caseListItem").css("display", "");
            $(".caseListItem").animate({ opacity: 1 }, 700);
        }
    }



    caseList.delete = function () {
        if (confirm("是否確定刪除該案件？")) {
            $http({
                method: 'POST',
                url: "api/GetPostCase/CaseBaseDelete",
                data: caseList.editList
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    $(".caseEditItem").css("display", "none");
                    $(".caseEditItem").css("opacity", 1);
                    getCaseList();
                    caseList.editList = [];
                }
            }).error(function (data, status, headers, config) {
                alert("刪除失敗，請連絡資訊室處理。")
            });
        } else {

        }
    }

    $('input').iCheck({
        checkboxClass: 'icheckbox_flat-blue',
        radioClass: 'iradio_flat-blue'
    });

    $('#setExcelCol').on('hidden.bs.modal', function (e) {
        $('#indexBody').css("overflow-y", "scroll");
    })

    function setCheck(id) {
        if (localStorage.getItem(id) != null) {
            $('#' + id).iCheck(localStorage.getItem(id));
            setColCheck(id, localStorage.getItem(id))
        } else {
            $('#' + id).iCheck('check');
            setColCheck(id, 'check')
        }
    }

    //讀取Storage資料
    if (typeof (Storage) !== "undefined") {
        setCheck("bCaseBaseID");
        setCheck("bSuggestDate");
        setCheck("bCouncilorName");
        setCheck("bContactName");
        setCheck("bContactTel");
        setCheck("bZone");
        setCheck("bAddress");
        setCheck("bSuggestContent");
        setCheck("bCaseOfficer");
        setCheck("bExecuteContent");
        setCheck("bState");
    }

    function setColCheck(id, check) {
        if (id == "bCaseBaseID") {
            caseList.excelCol.CaseBaseID = check;
        } else if (id == "bSuggestDate") {
            caseList.excelCol.SuggestDate = check;
        } else if (id == "bCouncilorName") {
            caseList.excelCol.CouncilorName = check;
        } else if (id == "bContactName") {
            caseList.excelCol.ContactName = check;
        } else if (id == "bContactTel") {
            caseList.excelCol.ContactTel = check;
        } else if (id == "bZone") {
            caseList.excelCol.Zone = check;
        } else if (id == "bAddress") {
            caseList.excelCol.Address = check;
        } else if (id == "bSuggestContent") {
            caseList.excelCol.SuggestContent = check;
        } else if (id == "bCaseOfficer") {
            caseList.excelCol.CaseOfficer = check;
        } else if (id == "bExecuteContent") {
            caseList.excelCol.ExecuteContent = check;
        } else if (id == "bState") {
            caseList.excelCol.State = check;
        }
    }


    caseList.setExcel = function (type, id) {
        if (type == "edit") {
            $('#setExcelCol').modal('show')
            $('#indexBody').css("overflow-y", "");
        } else if (type == "choose") {
            if (getColCheck(id) == "check") {
                $('#' + id).iCheck('uncheck');
                localStorage.setItem(id, "uncheck");
                setColCheck(id, "uncheck");
            } else {
                $('#' + id).iCheck('check');
                localStorage.setItem(id, "check");
                setColCheck(id, "check");
            }
        }
    }

    function getColCheck(id) {
        if (id == "bCaseBaseID") {
            return caseList.excelCol.CaseBaseID;
        } else if (id == "bSuggestDate") {
            return caseList.excelCol.SuggestDate;
        } else if (id == "bCouncilorName") {
            return caseList.excelCol.CouncilorName;
        } else if (id == "bContactName") {
            return caseList.excelCol.ContactName;
        } else if (id == "bContactTel") {
            return caseList.excelCol.ContactTel;
        } else if (id == "bZone") {
            return caseList.excelCol.Zone;
        } else if (id == "bAddress") {
            return caseList.excelCol.Address;
        } else if (id == "bSuggestContent") {
            return caseList.excelCol.SuggestContent;
        } else if (id == "bCaseOfficer") {
            return caseList.excelCol.CaseOfficer;
        } else if (id == "bExecuteContent") {
            return caseList.excelCol.ExecuteContent;
        } else if (id == "bState") {
            return caseList.excelCol.State;
        }
    }

    caseList.getExcel = function () {
        var temp = {};
        if (caseList.myPage.zone != "") {
            temp.zone = caseList.myPage.zone;
        } else {
            temp.zone = "";
        }
        if (caseList.myPage.councilorName != "") {
            temp.councilorName = caseList.myPage.councilorName;
        } else {
            temp.councilorName = "";
        }
        if (caseList.myPage.caseOfficer != "") {
            temp.caseOfficer = caseList.myPage.caseOfficer;
        } else {
            temp.caseOfficer = "";
        }
        temp.searchStartDate = caseList.myPage.startDate;
        temp.searchEndDate = caseList.myPage.endDate;
        temp.caseListSearch = caseList.myPage.searchKey;
        temp.excelType = $routeParams.type;
        temp.excelCol = caseList.excelCol;
        $http({
            method: 'POST',
            url: "api/GetCaseExcel/setConfig",
            data: temp
        }).success(function (data, status, headers, config) {
            window.location.href = "api/GetCaseExcel/getExcel";
        }).error(function (data, status, headers, config) {
        });
    }
});


