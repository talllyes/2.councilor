/// <reference path="../Kai-ng-ui.js" />
/// <reference path="../angular.js" />
app.controller('zoneManager', function ($scope, $http, $routeParams, $filter) {
    var zoneManager = this;
    zoneManager.addUserFlag = true;
    zoneManager.nowEditFlag = true;
    zoneManager.addCouncilorList = "";
    zoneManager.passwordTemp = "";
    zoneManager.zoneOrderBefore = "";
    zoneManager.zoneListSearch = "";
    zoneManager.councilorType = "";

    zoneManager.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'zoneManager.myPage',
        watch: ["searchKey", "searchState"],
        searchColumn: ["Name"],
        maxSize: 5,
        itemsPerPage: 8
    });

    zoneManager.myPage.searchState = "啟用";
    zoneManager.StateList = [{ State: "1", Name: "啟用" }, { State: "0", Name: "停用" }];

    function getUserList() {
        $http({
            method: 'GET',
            url: "api/GetPostManager/ZoneList",
        }).success(function (data, status, headers, config) {
            zoneManager.myPage.setData(data);
            $(".councilorListItem").animate({ opacity: 1 });
        }).error(function (data, status, headers, config) {
        });
    }
    getUserList();
    zoneManager.addCouncilor = function (type) {
        if (type == "edit") {
            zoneManager.addUserFlag = false;
            zoneManager.nowEditFlag = false;
            zoneManager.addCouncilorList = {
                "Name": "",
                "State": "1"
            };
            $('#addUser').collapse('show');
        } else if (type == "ok") {
            if ($scope.addForm.$valid) {
                $http({
                    method: 'POST',
                    url: "api/GetPostManager/AddZone",
                    data: zoneManager.addCouncilorList
                }).success(function (data, status, headers, config) {
                    if (data == "ok") {
                        $(".councilorListItem").css({ "opacity": 0 });
                        $(".councilorListItem").animate({ opacity: 1 }, 1000);
                        zoneManager.nowEditFlag = true;
                        $('#addUser').collapse('hide');
                        zoneManager.addUserFlag = true;
                        getUserList();
                    } else {
                        alert("該地區已存在。");
                    }
                }).error(function (data, status, headers, config) {
                });
            } else {
                alert("尚有欄位未填。");
            }
        } else if (type == "no") {
            zoneManager.nowEditFlag = true;
            $('#addUser').collapse('hide');
            zoneManager.addUserFlag = true;
        }
    }
    zoneManager.editUser = function (type, userLoginID, item) {
        if (type == "edit") {
            zoneManager.nowEditFlag = false;
            zoneManager.zoneOrderBefore = item.ZoneOrder;
            zoneManager.nameBefore = item.Name;
            zoneManager.state = item.State;
            $('.editUser' + userLoginID).addClass("kai-display");
            $('.editUserC' + userLoginID).removeClass("kai-display");
        } else if (type == "ok") {
            if (item.ZoneOrder > 0) {
                var submitTemp = angular.copy(item);
                if (zoneManager.zoneOrderBefore == item.ZoneOrder) {
                    submitTemp.ZoneOrder = 0;
                } else {
                    $(".councilorListItem").css({ "opacity": 0 });
                    submitTemp.ZoneOrderBefore = zoneManager.zoneOrderBefore;
                }
                var flag = true;
                if (item.Name == "") {
                    flag = false;
                }
                if (flag) {
                    $http({
                        method: 'POST',
                        url: "api/GetPostManager/UpdateZone",
                        data: submitTemp
                    }).success(function (data, status, headers, config) {
                        if (data == "ok") {
                            $(".councilorListItem").animate({ opacity: 1 }, 1000);
                            zoneManager.nowEditFlag = true;
                            $('.editUserC' + userLoginID).addClass("kai-display");
                            $('.editUser' + userLoginID).removeClass("kai-display");
                            if (submitTemp.ZoneOrder != 0) {
                                zoneManager.getUserList();
                            }
                        } else {
                            alert("該區域已存在。");
                        }
                    }).error(function (data, status, headers, config) {
                    });
                } else {
                    alert("尚有欄位未填。");
                }
            } else {
                alert("順序須大於0！")
            }
        } else if (type == "no") {
            zoneManager.nowEditFlag = true;
            item.Name = zoneManager.nameBefore;
            item.State = zoneManager.state;
            item.ZoneOrder = zoneManager.zoneOrderBefore;
            $('.editUserC' + userLoginID).addClass("kai-display");
            $('.editUser' + userLoginID).removeClass("kai-display");
        } else if (type == "delete") {
            $(".councilorListItem").css({ "opacity": 0 });
            $http({
                method: 'POST',
                url: "api/GetPostManager/DeleteZone",
                data: item.ZoneID
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    $(".councilorListItem").animate({ opacity: 1 }, 1000);
                    zoneManager.nowEditFlag = true;
                    $('.editUserC' + userLoginID).addClass("kai-display");
                    $('.editUser' + userLoginID).removeClass("kai-display");
                    zoneManager.getUserList();
                }
            }).error(function (data, status, headers, config) {
            });
        }
    }
})
