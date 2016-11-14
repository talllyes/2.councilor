app.controller('jobTitleManager', function ($scope, $http, $routeParams, $filter) {
    var jobTitleManager = this;
    var editBefore = "";
    jobTitleManager.addUserFlag = true;
    jobTitleManager.nowEditFlag = true;

    jobTitleManager.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'jobTitleManager.myPage',
        watch: ["searchKey", "searchState"],
        searchColumn: ["Name"],
        maxSize: 5,
        itemsPerPage: 10,
        outPut: 2
    });

    jobTitleManager.myPage.searchState = "啟用";
    jobTitleManager.StateList = [{ State: "1", Name: "啟用" }, { State: "0", Name: "停用" }];

    function getUserList() {
        $http({
            method: 'GET',
            url: "api/GetPostManager/JobTitleList",
        }).success(function (data, status, headers, config) {
            jobTitleManager.myPage.setData(data);
            $(".councilorListItem").animate({ opacity: 1 });
        }).error(function (data, status, headers, config) {
        });
    }
    getUserList();
    jobTitleManager.addCouncilor = function (type) {
        if (type == "edit") {
            jobTitleManager.addUserFlag = false;
            jobTitleManager.nowEditFlag = false;
            jobTitleManager.addJobTitleList = "";
            $('#addUser').collapse('show');
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/AddJobTitle",
                data: jobTitleManager.addJobTitleList
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    $(".councilorListItem").css({ "opacity": 0 });
                    $(".councilorListItem").animate({ opacity: 1 }, 1000);
                    jobTitleManager.nowEditFlag = true;
                    jobTitleManager.addUserFlag = true;
                    $('#addUser').collapse('hide');
                    getUserList();
                } else {
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            $('#addUser').collapse('hide');
            jobTitleManager.addUserFlag = true;
            jobTitleManager.nowEditFlag = true;
        }
    }
    jobTitleManager.editUser = function (type, userLoginID, item) {
        if (type == "edit") {
            jobTitleManager.nowEditFlag = false;
            editBefore = angular.copy(item);
            $('.editUser' + userLoginID).addClass("kai-display");
            $('.editUserC' + userLoginID).removeClass("kai-display");
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/EasyUpdateJobTitle",
                data: item
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    jobTitleManager.nowEditFlag = true;
                    $('.editUserC' + userLoginID).addClass("kai-display");
                    $('.editUser' + userLoginID).removeClass("kai-display");
                } else {
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            jobTitleManager.nowEditFlag = true;
            angular.copy(editBefore, item);
            $('.editUserC' + userLoginID).addClass("kai-display");
            $('.editUser' + userLoginID).removeClass("kai-display");
        }
    }
    jobTitleManager.setClassErr = function (data, item, value) {
        if (typeof (data) == "undefined") {
            eval('item.' + value + "= true");
        } else {
            eval('item.' + value + "= false");
        }
    }
    jobTitleManager.tips = function (id, type) {
        if (type) {
            $("#" + id).tooltip('show');
        } else {
            $("#" + id).tooltip('hide');
        }
    };
})


