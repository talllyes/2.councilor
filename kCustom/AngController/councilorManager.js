app.controller('councilorManager', function ($scope, $http, $routeParams, $filter) {
    var councilorManager = this;
    var editBefore = "";
    councilorManager.addUserFlag = true;
    councilorManager.nowEditFlag = true;

    councilorManager.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'councilorManager.myPage',
        watch: ["searchKey", "searchState"],
        searchColumn: ["Name"],
        maxSize: 5,
        itemsPerPage: 10,
        outPut: 2
    });

    councilorManager.myPage.searchState = "啟用";
    councilorManager.StateList = [{ State: "1", Name: "啟用" }, { State: "0", Name: "停用" }];

    function getUserList() {
        $http({
            method: 'GET',
            url: "api/GetPostManager/CouncilorList",
        }).success(function (data, status, headers, config) {
            councilorManager.myPage.setData(data);
            $(".councilorListItem").animate({ opacity: 1 });
        }).error(function (data, status, headers, config) {
        });
    }
    getUserList();
    councilorManager.addCouncilor = function (type) {
        if (type == "edit") {
            councilorManager.addUserFlag = false;
            councilorManager.nowEditFlag = false;
            councilorManager.addCouncilorList = {
                "CouncilorTypeID": "1",
                "State": "1"
            };
            $('#addUser').collapse('show');
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/AddCouncilor",
                data: councilorManager.addCouncilorList
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    $(".councilorListItem").css({ "opacity": 0 });
                    $(".councilorListItem").animate({ opacity: 1 }, 1000);
                    councilorManager.nowEditFlag = true;
                    councilorManager.addUserFlag = true;

                    $('#addUser').collapse('hide');
                    getUserList();
                } else {
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            $('#addUser').collapse('hide');
            councilorManager.addUserFlag = true;
            councilorManager.nowEditFlag = true;
        }
    }

    councilorManager.editUser = function (type, userLoginID, item) {
        if (type == "edit") {
            councilorManager.nowEditFlag = false;
            editBefore = angular.copy(item);
            $('.editUser' + userLoginID).addClass("kai-display");
            $('.editUserC' + userLoginID).removeClass("kai-display");
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/EasyUpdateCouncilor",
                data: item
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    councilorManager.nowEditFlag = true;
                    $('.editUserC' + userLoginID).addClass("kai-display");
                    $('.editUser' + userLoginID).removeClass("kai-display");
                } else {
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            councilorManager.nowEditFlag = true;
            angular.copy(editBefore, item);
            $('.editUserC' + userLoginID).addClass("kai-display");
            $('.editUser' + userLoginID).removeClass("kai-display");
        }
    }
    councilorManager.setClassErr = function (data, item, value) {
        if (typeof (data) == "undefined") {
            eval('item.' + value + "= true");
        } else {
            eval('item.' + value + "= false");
        }
    }
    councilorManager.tips = function (id, type) {
        if (type) {
            $("#" + id).tooltip('show');
        } else {
            $("#" + id).tooltip('hide');
        }
    };
})


