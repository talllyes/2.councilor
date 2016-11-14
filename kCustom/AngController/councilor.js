var app = angular.module('councilorApp', ['ngRoute', 'ui.bootstrap', 'ngSanitize']);
app.controller('councilor', function ($scope, $http) {
    var rootBase = this;
    rootBase.user = "";
    rootBase.index = "template/master.html";
    rootBase.aaa = "mailManager";
    rootBase.caseNum = "";
    rootBase.spuerWarn = true;
    rootBase.edit = { "Name": "", "Password": "" };

    rootBase.logout = function () {
        $http({
            method: 'GET',
            url: "api/login/logout",
        }).success(function (data, status, headers, config) {
            document.location.href = "login";
        }).error(function (data, status, headers, config) {
        });
    }
    rootBase.super = function () {
        if (rootBase.spuerWarn) {
            alert("本區為進階設定，非一般管理權限，請謹慎使用！");
            rootBase.spuerWarn = false;
        }
    }
    rootBase.editMy = function (type) {
        if (type == "edit") {
            rootBase.edit.Name = rootBase.user.UserName;
            rootBase.edit.Password = "";
            rootBase.edit.Password2 = "";
            $('#editMyAD').modal('show');
            $('#indexBody').css("overflow-y", "");
        } else if (type == "ok") {
            $http({
                method: 'POST',
                url: "api/GetPostManager/UpdateMyAD",
                data: rootBase.edit
            }).success(function (data, status, headers, config) {
                if (data == "ok") {
                    $('#editMyAD').modal('hide');
                    rootBase.user.UserName = rootBase.edit.Name;
                } else {
                    alert(data);
                }
            }).error(function (data, status, headers, config) {
            });
        }
    }
    $('#editMyAD').on('hidden.bs.modal', function (e) {
        $('#indexBody').css("overflow-y", "scroll");
    })
    $http({
        method: 'GET',
        url: "api/login/check",
    }).success(function (data, status, headers, config) {
        if (data == "no") {
            document.location.href = "login";
        } else {
            rootBase.user = data;
        }
    }).error(function (data, status, headers, config) {
    });
    $(document).on('click', 'li', function (event) {
        var head = document.getElementsByTagName('HEAD')[0];
        var sc = document.createElement('script');
        sc.src = 'kCustom/AngController/mailManager.js';
        head.appendChild(sc);
        $http({
            method: 'GET',
            url: "api/login/check",
        }).success(function (data, status, headers, config) {
            if (data == "no") {
                document.location.href = "login";
            } else {
                rootBase.user = data;
            }
        }).error(function (data, status, headers, config) {
        });
    });
});