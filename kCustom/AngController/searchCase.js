app.controller('searchCase', function ($scope, $http, $routeParams, $filter) {
    "use strict";
    var searchCase = this;
    var idTemp = "";
    searchCase.nowUrl = "";
    searchCase.minDate = getYyyNowDate();
    searchCase.excelbtn = false;

    //宣告KaiSearch
    searchCase.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'searchCase.myPage',
        maxSize: 5,
        itemsPerPage: 10,
        watch: ["searchKey", "councilorName", "zone", "caseOfficer", "overday"],
        searchDate: ["1", "SuggestDate"],
        orderBy: [$filter('orderBy'), "SuggestDate", true]
    });
    searchCase.excelCol = {
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
    searchCase.myPage.zone = "";
    searchCase.myPage.councilorName = "";
    searchCase.myPage.caseOfficer = ""
    searchCase.myPage.searchKey = "";
    searchCase.myPage.overday = "";

    $('#searchStartDate').datetimepicker('setEndDate', getYyyNowDate());
    $('#searchEndDate').datetimepicker('setEndDate', getYyyNowDate());
    $('#endDate').datetimepicker('setEndDate', getYyyNowDate());

    function getCaseList() {
        $http({
            method: 'GET',
            url: "api/GetPostCase/" + $routeParams.type
        }).success(function (data, status, headers, config) {
            searchCase.myPage.setData(data.CaseBase);
            searchCase.myPage.CouncilorNameList = data.CouncilorName;
            searchCase.myPage.ZoneList = data.Zone;
            searchCase.myPage.CaseOfficerList = data.CaseOfficer;
            searchCase.myPage.startDate = data.minDate;
            searchCase.minDate = searchCase.myPage.startDate;
            $('#searchStartDate').datetimepicker('setStartDate', searchCase.myPage.startDate);
            $('#searchEndDate').datetimepicker('setStartDate', searchCase.myPage.startDate);
            $(".caseListItem").css("display", "");
            $(".caseListItem").animate({ opacity: 1 }, 700);
        }).error(function (data, status, headers, config) {
        });
    }
    getCaseList();
    //上面麵包屑
    if ($routeParams.type == "CaseSearchAll") {
        searchCase.nowUrl = "全部";
    } else if ($routeParams.type == "YearSearch") {
        searchCase.nowUrl = "列入年度計劃";
    } else if ($routeParams.type == "OverDateSearch") {
        searchCase.nowUrl = "逾期案件";
        searchCase.myPage.overday = "逾期";
    } else if ($routeParams.type == "EndSearch") {
        searchCase.nowUrl = "結案";
    } else if ($routeParams.type == "WaitCase") {
        searchCase.nowUrl = "待辦案件";
    }
    //重置搜尋
    searchCase.setSearchNull = function () {
        searchCase.myPage.zone = "";
        searchCase.myPage.councilorName = "";
        searchCase.myPage.caseOfficer = "";
        searchCase.myPage.searchKey = "";
        searchCase.myPage.endDate = getYyyNowDate();
        searchCase.myPage.startDate = searchCase.minDate;
    }
    //收合效果
    searchCase.toggleDetail = function (id) {
        if (id == idTemp) {
            $('#caseDetail' + id).on('hidden.bs.collapse', function () {
                $('#detailTr' + id).css("display", "none");
                $('#caseDetail' + id).off('hidden.bs.collapse');
                idTemp = "";
            })
            $('#detailTr' + id).css("display", "");
            $('#caseDetail' + id).collapse('toggle');
            idTemp = "";
        } else if (idTemp == "") {
            $('#detailTr' + id).css("display", "");
            $('#caseDetail' + id).collapse('show');
            idTemp = id;
        } else if (id != idTemp) {
            $('#caseDetail' + idTemp).on('hidden.bs.collapse', function () {
                $('#detailTr' + idTemp).css("display", "none");
                $('#caseDetail' + idTemp).off('hidden.bs.collapse');
                $('#detailTr' + id).css("display", "");
                $('#caseDetail' + id).collapse('show');
                idTemp = id;
            })
            $('#caseDetail' + idTemp).collapse('hide');
        }
    };
    searchCase.myPage.event('end', function () {
        idTemp = "";
    });

    //出現日曆
    searchCase.dateClick = function (id) {
        $('#' + id).datetimepicker('show');
    }


    $('#setExcelCol').on('hidden.bs.modal', function (e) {
        $('#indexBody').css("overflow-y", "scroll");
    })

    searchCase.setExcel = function () {
        $('#setExcelCol').modal('show')
        $('#indexBody').css("overflow-y", "");
    }

    searchCase.setCol = function (id, choose) {
        var str = "";
        if (choose == 'check') {
            eval('searchCase.excelCol.' + id + '= "uncheck"');
            str = "uncheck";
        } else {
            eval('searchCase.excelCol.' + id + '= "check"');
            str = "check";
        }
        localStorage.setItem('b' + id, str);
    }


    function setCheck() {
        if (localStorage.getItem('bCaseBaseID') != null) {
            searchCase.excelCol.CaseBaseID = localStorage.getItem('bCaseBaseID');
        }
        if (localStorage.getItem('bSuggestDate') != null) {
            searchCase.excelCol.SuggestDate = localStorage.getItem('bSuggestDate');
        }
        if (localStorage.getItem('bSuggestContent') != null) {
            searchCase.excelCol.SuggestContent = localStorage.getItem('bSuggestContent');
        }
        if (localStorage.getItem('bCouncilorName') != null) {
            searchCase.excelCol.CouncilorName = localStorage.getItem('bCouncilorName');
        }
        if (localStorage.getItem('bZone') != null) {
            searchCase.excelCol.Zone = localStorage.getItem('bZone');
        }
        if (localStorage.getItem('bAddress') != null) {
            searchCase.excelCol.Address = localStorage.getItem('bAddress');
        }
        if (localStorage.getItem('bCaseOfficer') != null) {
            searchCase.excelCol.CaseOfficer = localStorage.getItem('bCaseOfficer');
        }
        if (localStorage.getItem('bContactName') != null) {
            searchCase.excelCol.ContactName = localStorage.getItem('bContactName');
        }
        if (localStorage.getItem('bContactTel') != null) {
            searchCase.excelCol.ContactTel = localStorage.getItem('bContactTel');
        }
        if (localStorage.getItem('bExecuteContent') != null) {
            searchCase.excelCol.ExecuteContent = localStorage.getItem('bExecuteContent');
        }
        if (localStorage.getItem('bState') != null) {
            searchCase.excelCol.State = localStorage.getItem('bState');
        }
    }
    setCheck();


    searchCase.getExcel = function () {
        var temp = {};
        searchCase.excelbtn = true;
        if (searchCase.myPage.zone != "") {
            temp.zone = searchCase.myPage.zone;
        } else {
            temp.zone = "";
        }
        if (searchCase.myPage.councilorName != "") {
            temp.councilorName = searchCase.myPage.councilorName;
        } else {
            temp.councilorName = "";
        }
        if (searchCase.myPage.caseOfficer != "") {
            temp.caseOfficer = searchCase.myPage.caseOfficer;
        } else {
            temp.caseOfficer = "";
        }
        temp.searchStartDate = searchCase.myPage.startDate;
        temp.searchEndDate = searchCase.myPage.endDate;
        temp.caseListSearch = searchCase.myPage.searchKey;
        temp.excelType = $routeParams.type;
        temp.excelCol = searchCase.excelCol;
        console.log(temp);
        $http({
            method: 'POST',
            url: "api/GetCaseExcelPro/setConfig",
            data: temp
        }).success(function (data, status, headers, config) {
            window.location.href = "api/GetCaseExcelPro/getExcel";
            searchCase.excelbtn = false;
        }).error(function (data, status, headers, config) {
        });
    }
})