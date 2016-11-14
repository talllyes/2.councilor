app.controller('userManager', function ($scope, $http, $routeParams) {
    var userManager = this;
    var beforeEditTemp;
    userManager.addUserFlag = true;
    userManager.nowEditFlag = true;
    userManager.addUserList = "";
    userManager.myPage = new kaiSearch({
        controllerScope: $scope,
        controllerName: 'userManager.myPage',
        watch: ["searchKey", "searchState"],
        maxSize: 5,
        itemsPerPage: 10
    });

    userManager.myPage.searchState = "啟用";
    userManager.StateList = [{ State: "1", Name: "啟用" }, { State: "0", Name: "停用" }];
    userManager.AdminList = [{ Admin: "1", Name: "是" }, { Admin: "0", Name: "否" }, { Admin: "2", Name: "super" }];
    userManager.UnitList = [{ Unit: "1", Name: "號誌股" }, { Unit: "2", Name: "交控股" }];
    userManager.OfficerList = [{ Officer: "1", Name: "是" }, { Officer: "0", Name: "否" }];
    userManager.JobTitleList = [];
    function getUserList() {
        $http({
            method: 'GET',
            url: "api/GetPostManager/UserList",
        }).success(function (data, status, headers, config) {
            userManager.myPage.setData(data.UserList);
            userManager.JobTitleList = data.JobTitle;
            $(".userListItem").animate({ opacity: 1 });
        }).error(function (data, status, headers, config) {
        });
    }
    getUserList();
    userManager.addUser = function (type) {
        if (type == "edit") {
            $("#newjobs").tooltip('hide');
            $("#newPassword").tooltip('hide');
            $("#newname").tooltip('hide');
            $("#email").tooltip('hide');
            $('#addUser').collapse('show');
            userManager.addUserFlag = false;
            userManager.nowEditFlag = false;
            userManager.addUserList = {
                "JobTitle": "1",
                "Unit": "1",
                "Admin": "0",
                "Officer": "1"
            };
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/PostAddUser",
                data: userManager.addUserList
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    userManager.nowEditFlag = true;
                    userManager.addUserFlag = true;
                    $(".userListItem").css({ "opacity": 0 });
                    $(".userListItem").animate({ opacity: 1 }, 1000);
                    $('#addUser').collapse('hide');
                    getUserList();
                } else {
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            userManager.nowEditFlag = true;
            userManager.addUserFlag = true;
            $('#addUser').collapse('hide');
        }
    }

    userManager.editUser = function (type, userLoginID, item) {
        if (type == "edit") {
            item.Password = "";
            userManager.nowEditFlag = false;
            beforeEditTemp = angular.copy(item);
            $('.editUser' + userLoginID).addClass("kai-display");
            $('.editUserC' + userLoginID).removeClass("kai-display");
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/EasyUpdateUser",
                data: item
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    $(".userListItem").animate({ opacity: 1 }, 1000);
                    $('.editUserC' + userLoginID).addClass("kai-display");
                    $('.editUser' + userLoginID).removeClass("kai-display");
                    userManager.nowEditFlag = true;
                } else {
                    userManager.nowEditFlag = false;
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        } else if (type == "no") {
            userManager.nowEditFlag = true;
            angular.copy(beforeEditTemp, item);
            $('.editUserC' + userLoginID).addClass("kai-display");
            $('.editUser' + userLoginID).removeClass("kai-display");
        }
    }

    //錯誤紅框框
    userManager.setClassErr = function (data, item, value) {
        if (typeof (data) == "undefined") {
            eval('item.' + value + "= true");
        } else {
            eval('item.' + value + "= false");
        }
    }
    userManager.tips = function (id, type) {
        if (type) {
            $("#" + id).tooltip('show');
        } else {
            $("#" + id).tooltip('hide');
        }
    };
})